//
//  CombineDataFlowTests.swift
//  StockBarTests
//
//  Integration tests for the Combine reactive pipeline:
//  Trade change -> debounce -> filter -> API fetch -> decode -> update realTimeInfo
//  Uses MockURLProtocol to intercept network requests.
//

import XCTest
import Combine
@testable import StockBar

@available(macOS 11.0, *)
final class CombineDataFlowTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.requestHandler = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testRealTimeTradeUpdatesOnPublish() {
        let mockJSON = Self.makeQuoteJSON(
            symbol: "AAPL", currency: "USD", price: 175.50, prevClose: 173.00,
            shortName: "Apple Inc.", timezone: "America/New_York"
        )

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, mockJSON)
        }

        let rt = RealTimeTrade(
            trade: Trade(name: "AAPL", position: Position(unitSize: "100", positionAvgCost: "150")),
            realTimeInfo: TradingInfo()
        )

        let expectation = XCTestExpectation(description: "RealTimeInfo updated with mock data")

        rt.$realTimeInfo
            .dropFirst()
            .sink { info in
                if !info.currentPrice.isNaN {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        rt.sendTradeToPublisher()

        wait(for: [expectation], timeout: 10.0)

        XCTAssertEqual(rt.realTimeInfo.currentPrice, 175.50, accuracy: 0.01)
        XCTAssertEqual(rt.realTimeInfo.prevClosePrice, 173.00, accuracy: 0.01)
        XCTAssertEqual(rt.realTimeInfo.currency, "USD")
    }

    func testEmptySymbolIsFiltered() {
        MockURLProtocol.requestHandler = { _ in
            XCTFail("Should not make a network request for an empty symbol")
            return (HTTPURLResponse(), Data())
        }

        let rt = RealTimeTrade(
            trade: Trade(name: "", position: Position(unitSize: "1", positionAvgCost: "")),
            realTimeInfo: TradingInfo()
        )

        rt.sendTradeToPublisher()

        // Inverted expectation: should NOT be fulfilled (i.e. no request made)
        let noRequest = XCTestExpectation(description: "No network request")
        noRequest.isInverted = true
        wait(for: [noRequest], timeout: 2.0)
    }

    func testAPIErrorReturnsEmptyTradingInfo() {
        let errorJSON = """
        { "chart": { "result": null, "error": { "description": "Not Found" } } }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, errorJSON)
        }

        let rt = RealTimeTrade(
            trade: Trade(name: "INVALID", position: Position(unitSize: "1", positionAvgCost: "")),
            realTimeInfo: TradingInfo(currentPrice: 999, prevClosePrice: 999)
        )

        let expectation = XCTestExpectation(description: "TradingInfo reset on error response")

        rt.$realTimeInfo
            .dropFirst()
            .sink { info in
                if info.currentPrice.isNaN {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        rt.sendTradeToPublisher()

        wait(for: [expectation], timeout: 10.0)
        XCTAssertTrue(rt.realTimeInfo.currentPrice.isNaN)
    }

    func testCorrectURLConstruction() {
        let expectedSymbol = "BTC-USD"
        let urlChecked = XCTestExpectation(description: "URL contains symbol and interval")

        MockURLProtocol.requestHandler = { request in
            let urlString = request.url!.absoluteString
            XCTAssertTrue(urlString.contains(expectedSymbol), "URL should contain \(expectedSymbol)")
            XCTAssertTrue(urlString.contains("interval=1d"), "URL should contain interval=1d")
            urlChecked.fulfill()

            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, "{\"chart\": null}".data(using: .utf8)!)
        }

        let rt = RealTimeTrade(
            trade: Trade(name: expectedSymbol, position: Position(unitSize: "1", positionAvgCost: "")),
            realTimeInfo: TradingInfo()
        )

        rt.sendTradeToPublisher()
        wait(for: [urlChecked], timeout: 10.0)
    }

    func testMultipleSymbolsUpdateIndependently() {
        let aaplJSON = Self.makeQuoteJSON(
            symbol: "AAPL", currency: "USD", price: 175.0, prevClose: 173.0,
            shortName: "Apple Inc.", timezone: "America/New_York"
        )
        let btcJSON = Self.makeQuoteJSON(
            symbol: "BTC-USD", currency: "USD", price: 50000.0, prevClose: 49000.0,
            shortName: "Bitcoin USD", timezone: "UTC"
        )

        MockURLProtocol.requestHandler = { request in
            let urlString = request.url!.absoluteString
            let data = urlString.contains("BTC-USD") ? btcJSON : aaplJSON
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, data)
        }

        let aapl = RealTimeTrade(
            trade: Trade(name: "AAPL", position: Position(unitSize: "10", positionAvgCost: "150")),
            realTimeInfo: TradingInfo()
        )
        let btc = RealTimeTrade(
            trade: Trade(name: "BTC-USD", position: Position(unitSize: "0.5", positionAvgCost: "30000")),
            realTimeInfo: TradingInfo()
        )

        let aaplExpectation = XCTestExpectation(description: "AAPL updated")
        let btcExpectation = XCTestExpectation(description: "BTC updated")

        aapl.$realTimeInfo
            .dropFirst()
            .sink { info in if !info.currentPrice.isNaN { aaplExpectation.fulfill() } }
            .store(in: &cancellables)

        btc.$realTimeInfo
            .dropFirst()
            .sink { info in if !info.currentPrice.isNaN { btcExpectation.fulfill() } }
            .store(in: &cancellables)

        aapl.sendTradeToPublisher()
        btc.sendTradeToPublisher()

        wait(for: [aaplExpectation, btcExpectation], timeout: 10.0)

        XCTAssertEqual(aapl.realTimeInfo.currentPrice, 175.0, accuracy: 0.01)
        XCTAssertEqual(btc.realTimeInfo.currentPrice, 50000.0, accuracy: 0.01)
    }

    // MARK: - Helpers

    private static func makeQuoteJSON(
        symbol: String, currency: String, price: Double, prevClose: Double,
        shortName: String, timezone: String
    ) -> Data {
        return """
        {
            "chart": {
                "result": [{
                    "meta": {
                        "currency": "\(currency)",
                        "symbol": "\(symbol)",
                        "shortName": "\(shortName)",
                        "regularMarketTime": 1679000000,
                        "exchangeTimezoneName": "\(timezone)",
                        "regularMarketPrice": \(price),
                        "chartPreviousClose": \(prevClose)
                    }
                }],
                "error": null
            }
        }
        """.data(using: .utf8)!
    }
}

// MARK: - Mock URL Protocol

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        let (response, data) = handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
