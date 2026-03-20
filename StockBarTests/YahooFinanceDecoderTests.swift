//
//  YahooFinanceDecoderTests.swift
//  StockBarTests
//
//  Tests for Yahoo Finance API JSON response decoding - the most critical path.
//  If decoding breaks, the entire app is non-functional.
//

import XCTest
@testable import StockBar

final class YahooFinanceDecoderTests: XCTestCase {

    // MARK: - JSON Decoding

    func testDecodeValidResponse() throws {
        let json = """
        {
            "chart": {
                "result": [{
                    "meta": {
                        "currency": "USD",
                        "symbol": "AAPL",
                        "shortName": "Apple Inc.",
                        "regularMarketTime": 1679000000,
                        "exchangeTimezoneName": "America/New_York",
                        "regularMarketPrice": 150.25,
                        "chartPreviousClose": 148.50
                    }
                }],
                "error": null
            }
        }
        """.data(using: .utf8)!

        let quote = try JSONDecoder().decode(YahooFinanceQuote.self, from: json)

        let meta = try XCTUnwrap(quote.chart?.result?.first?.meta)
        XCTAssertEqual(meta.symbol, "AAPL")
        XCTAssertEqual(meta.currency, "USD")
        XCTAssertEqual(meta.shortName, "Apple Inc.")
        XCTAssertEqual(meta.regularMarketPrice, 150.25)
        XCTAssertEqual(meta.regularMarketPreviousClose, 148.50)
        XCTAssertEqual(meta.regularMarketTime, 1679000000)
        XCTAssertEqual(meta.exchangeTimezoneName, "America/New_York")
    }

    func testDecodeErrorResponse() throws {
        let json = """
        {
            "chart": {
                "result": null,
                "error": {
                    "description": "No data found, symbol may be delisted"
                }
            }
        }
        """.data(using: .utf8)!

        let quote = try JSONDecoder().decode(YahooFinanceQuote.self, from: json)

        XCTAssertNil(quote.chart?.result)
        XCTAssertEqual(quote.chart?.error?.description, "No data found, symbol may be delisted")
    }

    func testDecodeNullChart() throws {
        let json = """
        { "chart": null }
        """.data(using: .utf8)!

        let quote = try JSONDecoder().decode(YahooFinanceQuote.self, from: json)
        XCTAssertNil(quote.chart)
    }

    func testDecodeWithoutChartPreviousClose() throws {
        let json = """
        {
            "chart": {
                "result": [{
                    "meta": {
                        "currency": "JPY",
                        "symbol": "9626.T",
                        "shortName": "Some Corp",
                        "regularMarketTime": 1679000000,
                        "exchangeTimezoneName": "Asia/Tokyo",
                        "regularMarketPrice": 5000.0
                    }
                }],
                "error": null
            }
        }
        """.data(using: .utf8)!

        let quote = try JSONDecoder().decode(YahooFinanceQuote.self, from: json)
        let meta = try XCTUnwrap(quote.chart?.result?.first?.meta)

        XCTAssertNil(meta.chartPreviousClose)
        XCTAssertEqual(meta.regularMarketPreviousClose, 0.0,
                       "Missing chartPreviousClose should default to 0.0")
    }

    func testDecodeMultipleResults() throws {
        let json = """
        {
            "chart": {
                "result": [
                    {
                        "meta": {
                            "currency": "USD",
                            "symbol": "AAPL",
                            "shortName": "Apple Inc.",
                            "regularMarketTime": 1679000000,
                            "exchangeTimezoneName": "America/New_York",
                            "regularMarketPrice": 150.25,
                            "chartPreviousClose": 148.50
                        }
                    },
                    {
                        "meta": {
                            "currency": "USD",
                            "symbol": "GOOG",
                            "shortName": "Alphabet Inc.",
                            "regularMarketTime": 1679000000,
                            "exchangeTimezoneName": "America/New_York",
                            "regularMarketPrice": 2800.00,
                            "chartPreviousClose": 2750.00
                        }
                    }
                ],
                "error": null
            }
        }
        """.data(using: .utf8)!

        let quote = try JSONDecoder().decode(YahooFinanceQuote.self, from: json)
        XCTAssertEqual(quote.chart?.result?.count, 2)
        XCTAssertEqual(quote.chart?.result?[0].meta.symbol, "AAPL")
        XCTAssertEqual(quote.chart?.result?[1].meta.symbol, "GOOG")
    }

    // MARK: - Meta Formatting

    func testMetaPriceFormat() throws {
        let meta = try makeMeta(price: 150.25, prevClose: 148.50, currency: "USD")
        XCTAssertEqual(meta.getPrice(), "USD 150.25")
    }

    func testMetaChangePositive() throws {
        let meta = try makeMeta(price: 150.25, prevClose: 148.50, currency: "USD")
        XCTAssertEqual(meta.getChange(), "+1.75")
    }

    func testMetaChangeNegative() throws {
        let meta = try makeMeta(price: 146.50, prevClose: 148.50, currency: "USD")
        XCTAssertEqual(meta.getChange(), "-2.00")
    }

    func testMetaChangePct() throws {
        let meta = try makeMeta(price: 150.0, prevClose: 100.0, currency: "USD")
        XCTAssertEqual(meta.getChangePct(), "+50.0000%")
    }

    func testMetaNilCurrencyFallback() throws {
        let meta = try makeMeta(price: 100.0, prevClose: 99.0, currency: nil)
        XCTAssertTrue(meta.getPrice().hasPrefix("Price"))
    }

    // MARK: - Helpers

    private func makeMeta(price: Double, prevClose: Double, currency: String?) throws -> Meta {
        var jsonDict: [String: Any] = [
            "symbol": "TEST",
            "shortName": "Test",
            "regularMarketTime": 1679000000,
            "exchangeTimezoneName": "America/New_York",
            "regularMarketPrice": price,
            "chartPreviousClose": prevClose
        ]
        if let currency = currency {
            jsonDict["currency"] = currency
        }
        let data = try JSONSerialization.data(withJSONObject: jsonDict)
        return try JSONDecoder().decode(Meta.self, from: data)
    }
}
