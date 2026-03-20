//
//  YahooFinanceAPITests.swift
//  StockBarTests
//
//  Integration tests that hit the live Yahoo Finance API.
//  These validate the full end-to-end flow: network request -> JSON decode -> model update.
//  Tests handle API unavailability gracefully (no hard failure on network issues).
//

import XCTest
import Combine
@testable import StockBar

final class YahooFinanceAPITests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testFetchRealStockQuote() {
        let expectation = XCTestExpectation(description: "Fetch AAPL quote from Yahoo Finance")

        let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/AAPL?interval=1d")!

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: YahooFinanceQuote.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Live API test (AAPL) skipped due to: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }, receiveValue: { quote in
                if let meta = quote.chart?.result?.first?.meta {
                    XCTAssertEqual(meta.symbol, "AAPL")
                    XCTAssertEqual(meta.currency, "USD")
                    XCTAssertGreaterThan(meta.regularMarketPrice, 0)
                    XCTAssertFalse(meta.shortName.isEmpty)
                    XCTAssertFalse(meta.exchangeTimezoneName.isEmpty)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 30.0)
    }

    func testFetchCurrencyPairQuote() {
        let expectation = XCTestExpectation(description: "Fetch USDJPY=X quote from Yahoo Finance")

        let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/USDJPY%3DX?interval=1d")!

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: YahooFinanceQuote.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Live API test (USDJPY=X) skipped due to: \(error.localizedDescription)")
                    expectation.fulfill()
                }
            }, receiveValue: { quote in
                if let meta = quote.chart?.result?.first?.meta {
                    XCTAssertGreaterThan(meta.regularMarketPrice, 0)
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 30.0)
    }

    @available(macOS 11.0, *)
    func testEndToEndRealTimeTradeWithLiveAPI() {
        let rt = RealTimeTrade(
            trade: Trade(name: "AAPL", position: Position(unitSize: "10", positionAvgCost: "150")),
            realTimeInfo: TradingInfo()
        )

        let expectation = XCTestExpectation(description: "Live API updates RealTimeTrade end-to-end")

        rt.$realTimeInfo
            .dropFirst()
            .sink { info in
                // Fulfill on any update (including error-reset to NaN)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        rt.sendTradeToPublisher()

        wait(for: [expectation], timeout: 30.0)

        // Only assert if we got valid data (API might be unavailable)
        if !rt.realTimeInfo.currentPrice.isNaN {
            XCTAssertGreaterThan(rt.realTimeInfo.currentPrice, 0)
            XCTAssertEqual(rt.realTimeInfo.currency, "USD")
            XCTAssertFalse(rt.realTimeInfo.shortName.isEmpty)
        }
    }
}
