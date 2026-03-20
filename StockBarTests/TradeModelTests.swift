//
//  TradeModelTests.swift
//  StockBarTests
//
//  Tests for core domain models (Trade, Position, TradingInfo),
//  P&L calculations, and data persistence via UserDefaults.
//

import XCTest
@testable import StockBar

final class TradeModelTests: XCTestCase {

    // MARK: - Position Validation

    func testPositionValidNumericInput() {
        let pos = Position(unitSize: "100", positionAvgCost: "150.50")
        XCTAssertEqual(pos.unitSize, 100.0)
        XCTAssertEqual(pos.positionAvgCost, 150.50)
    }

    func testPositionInvalidUnitSizeDefaultsToOne() {
        let pos = Position(unitSize: "abc", positionAvgCost: "150.00")
        XCTAssertEqual(pos.unitSize, 1.0)
        XCTAssertEqual(pos.unitSizeString, "1")
    }

    func testPositionEmptyAvgCostIsNaN() {
        let pos = Position(unitSize: "10", positionAvgCost: "")
        XCTAssertTrue(pos.positionAvgCost.isNaN)
    }

    func testPositionUnitSizeSetterValidation() {
        var pos = Position(unitSize: "10", positionAvgCost: "100")
        pos.unitSizeString = "not_a_number"
        XCTAssertEqual(pos.unitSizeString, "1", "Invalid input should reset to 1")
        pos.unitSizeString = "50"
        XCTAssertEqual(pos.unitSizeString, "50")
        XCTAssertEqual(pos.unitSize, 50.0)
    }

    func testPositionFractionalUnits() {
        let pos = Position(unitSize: "0.5", positionAvgCost: "40000")
        XCTAssertEqual(pos.unitSize, 0.5)
        XCTAssertEqual(pos.positionAvgCost, 40000.0)
    }

    // MARK: - Trade Encode/Decode (Persistence)

    func testTradeEncodeDecode() throws {
        let original = Trade(name: "AAPL", position: Position(unitSize: "100", positionAvgCost: "150.00"))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Trade.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func testMultipleTradesEncodeDecode() throws {
        let trades = [
            Trade(name: "AAPL", position: Position(unitSize: "100", positionAvgCost: "150.00")),
            Trade(name: "BTC-USD", position: Position(unitSize: "0.5", positionAvgCost: "40000")),
            Trade(name: "USDJPY=X", position: Position(unitSize: "10000", positionAvgCost: "110")),
        ]
        let data = try JSONEncoder().encode(trades)
        let decoded = try JSONDecoder().decode([Trade].self, from: data)
        XCTAssertEqual(decoded, trades)
    }

    // MARK: - TradingInfo Formatting

    func testTradingInfoPriceFormat() {
        let info = TradingInfo(currentPrice: 150.256, prevClosePrice: 148.5, currency: "USD")
        XCTAssertEqual(info.getPrice(), "USD 150.256")
    }

    func testTradingInfoChangePositive() {
        let info = TradingInfo(currentPrice: 150.25, prevClosePrice: 148.50)
        XCTAssertEqual(info.getChange(), "+1.75")
    }

    func testTradingInfoChangeNegative() {
        let info = TradingInfo(currentPrice: 146.50, prevClosePrice: 148.50)
        XCTAssertEqual(info.getChange(), "-2.00")
    }

    func testTradingInfoChangePct() {
        let info = TradingInfo(currentPrice: 150.0, prevClosePrice: 100.0)
        XCTAssertEqual(info.getChangePct(), "+50.0000%")
    }

    func testTradingInfoNilCurrencyFallback() {
        let info = TradingInfo(currentPrice: 100.0, prevClosePrice: 99.0, currency: nil)
        XCTAssertTrue(info.getPrice().hasPrefix("Price"))
    }

    // MARK: - P&L Calculations

    func testDailyPNLPositive() {
        let info = TradingInfo(currentPrice: 152.0, prevClosePrice: 150.0, currency: "USD")
        let pos = Position(unitSize: "100", positionAvgCost: "140.00")
        XCTAssertEqual(dailyPNLNumber(info, pos), 200.0, accuracy: 0.01)
    }

    func testDailyPNLNegative() {
        let info = TradingInfo(currentPrice: 148.0, prevClosePrice: 150.0, currency: "USD")
        let pos = Position(unitSize: "100", positionAvgCost: "140.00")
        XCTAssertEqual(dailyPNLNumber(info, pos), -200.0, accuracy: 0.01)
    }

    func testDailyPNLStringFormat() {
        let info = TradingInfo(currentPrice: 152.0, prevClosePrice: 150.0, currency: "USD")
        let pos = Position(unitSize: "100", positionAvgCost: "140.00")
        let result = dailyPNL(info, pos)
        XCTAssertTrue(result.contains("Daily PnL"))
        XCTAssertTrue(result.contains("USD"))
        XCTAssertTrue(result.contains("+200.00"))
    }

    func testDailyPNLFractionalShares() {
        let info = TradingInfo(currentPrice: 50000.0, prevClosePrice: 49000.0, currency: "USD")
        let pos = Position(unitSize: "0.5", positionAvgCost: "30000")
        XCTAssertEqual(dailyPNLNumber(info, pos), 500.0, accuracy: 0.01)
    }

    func testDailyPNLZeroChange() {
        let info = TradingInfo(currentPrice: 100.0, prevClosePrice: 100.0, currency: "USD")
        let pos = Position(unitSize: "50", positionAvgCost: "90")
        XCTAssertEqual(dailyPNLNumber(info, pos), 0.0, accuracy: 0.01)
    }

    // MARK: - Total P&L

    func testTotalPNLProfit() {
        let info = TradingInfo(currentPrice: 180.0, prevClosePrice: 175.0, currency: "USD")
        let pos = Position(unitSize: "100", positionAvgCost: "150.00")
        let result = totalPNL(info, pos)
        XCTAssertTrue(result.contains("Total PnL"))
        XCTAssertTrue(result.contains("USD"))
        XCTAssertTrue(result.contains("+3000.00"))
    }

    func testTotalPNLLoss() {
        let info = TradingInfo(currentPrice: 140.0, prevClosePrice: 145.0, currency: "USD")
        let pos = Position(unitSize: "50", positionAvgCost: "160.00")
        let result = totalPNL(info, pos)
        XCTAssertTrue(result.contains("-1000.00"))
    }

    // MARK: - Position Cost & Market Value

    func testTotalPositionCost() {
        let info = TradingInfo(currentPrice: 180.0, prevClosePrice: 175.0, currency: "USD")
        let pos = Position(unitSize: "100", positionAvgCost: "150.00")
        let result = totalPositionCost(info, pos)
        XCTAssertTrue(result.contains("Position Cost"))
        XCTAssertTrue(result.contains("USD"))
        XCTAssertTrue(result.contains("15000.00"))
    }

    func testCurrentPositionValue() {
        let info = TradingInfo(currentPrice: 180.0, prevClosePrice: 175.0, currency: "USD")
        let pos = Position(unitSize: "100", positionAvgCost: "150.00")
        let result = currentPositionValue(info, pos)
        XCTAssertTrue(result.contains("Market Value"))
        XCTAssertTrue(result.contains("USD"))
        XCTAssertTrue(result.contains("18000.00"))
    }

    func testCurrentPositionValueFractionalShares() {
        let info = TradingInfo(currentPrice: 50000.0, prevClosePrice: 49000.0, currency: "USD")
        let pos = Position(unitSize: "0.5", positionAvgCost: "30000")
        let result = currentPositionValue(info, pos)
        XCTAssertTrue(result.contains("25000.00"))
    }

    // MARK: - Helper Functions

    func testEmptyTrades() {
        let trades = emptyTrades(size: 3)
        XCTAssertEqual(trades.count, 3)
        for trade in trades {
            XCTAssertEqual(trade.name, "")
            XCTAssertEqual(trade.position.unitSize, 1.0)
        }
    }

    func testEmptyRealTimeTrade() {
        let rt = emptyRealTimeTrade()
        XCTAssertEqual(rt.trade.name, "")
        XCTAssertTrue(rt.realTimeInfo.currentPrice.isNaN)
    }

    // MARK: - DataModel Persistence

    private let testKey = DataModel.userTradesKey
    private var savedData: Data?

    override func setUp() {
        super.setUp()
        savedData = UserDefaults.standard.data(forKey: testKey)
    }

    override func tearDown() {
        if let savedData = savedData {
            UserDefaults.standard.set(savedData, forKey: testKey)
        } else {
            UserDefaults.standard.removeObject(forKey: testKey)
        }
        super.tearDown()
    }

    func testDataModelLoadsFromUserDefaults() throws {
        let trades = [
            Trade(name: "AAPL", position: Position(unitSize: "100", positionAvgCost: "150.00")),
            Trade(name: "GOOG", position: Position(unitSize: "50", positionAvgCost: "2800.00")),
        ]
        let data = try JSONEncoder().encode(trades)
        UserDefaults.standard.set(data, forKey: testKey)

        let model = DataModel()

        XCTAssertEqual(model.realTimeTrades.count, 2)
        XCTAssertEqual(model.realTimeTrades[0].trade.name, "AAPL")
        XCTAssertEqual(model.realTimeTrades[0].trade.position.unitSize, 100.0)
        XCTAssertEqual(model.realTimeTrades[1].trade.name, "GOOG")
    }

    func testDataModelWithNoSavedData() {
        UserDefaults.standard.removeObject(forKey: testKey)

        let model = DataModel()

        XCTAssertEqual(model.realTimeTrades.count, 1)
        XCTAssertEqual(model.realTimeTrades[0].trade.name, "")
    }

    func testDataModelWithCorruptedData() {
        UserDefaults.standard.set("not json".data(using: .utf8), forKey: testKey)

        let model = DataModel()

        XCTAssertEqual(model.realTimeTrades.count, 1, "Corrupted data should fall back to defaults")
        XCTAssertEqual(model.realTimeTrades[0].trade.name, "")
    }

    func testSaveAndReloadRoundTrip() throws {
        let trades = [
            Trade(name: "BTC-USD", position: Position(unitSize: "0.5", positionAvgCost: "40000")),
            Trade(name: "USDJPY=X", position: Position(unitSize: "10000", positionAvgCost: "110")),
        ]

        let data = try JSONEncoder().encode(trades)
        UserDefaults.standard.set(data, forKey: testKey)

        let model = DataModel()

        XCTAssertEqual(model.realTimeTrades.count, 2)
        XCTAssertEqual(model.realTimeTrades[0].trade.name, "BTC-USD")
        XCTAssertEqual(model.realTimeTrades[0].trade.position.unitSize, 0.5)
        XCTAssertEqual(model.realTimeTrades[1].trade.name, "USDJPY=X")
        XCTAssertEqual(model.realTimeTrades[1].trade.position.unitSize, 10000.0)
    }
}
