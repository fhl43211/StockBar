//
//  Trade.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-08-01.

import Foundation

struct Trade : Codable, Equatable {
    var name : String
    var position : Position
}

struct Position : Codable, Equatable {
    var unitSizeString : String {
        get {
            return self._unitSize;
        }
        set(newUnitSize) {
            if (Double(newUnitSize) != nil) {
                _unitSize = newUnitSize;
            }
            else {
                _unitSize = "1";
            }
        }
    }
    var unitSize : Double {
        get {
            return Double(unitSizeString) ?? 1
        }
    }
    var positionAvgCostString : String
    var positionAvgCost : Double {
        get {
            return Double(positionAvgCostString) ?? .nan
        }
    }
    private var _unitSize : String
    init(unitSize : String, positionAvgCost : String)
    {
        self._unitSize = "1"
        self.positionAvgCostString = positionAvgCost
        self.unitSizeString = unitSize
    }
    
}

// MARK: - P&L Calculations

func dailyPNLNumber(_ tradingInfo: TradingInfo, _ position: Position)->Double {
    return (tradingInfo.currentPrice - tradingInfo.prevClosePrice)*position.unitSize
}
func dailyPNL(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let pnlString = String(format: "%+.2f", dailyPNLNumber(tradingInfo, position))
    return "Daily PnL: " + (tradingInfo.currency ?? "") + " " + pnlString
}
func totalPNL(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let pnl = (tradingInfo.currentPrice - position.positionAvgCost)*position.unitSize
    let pnlString = String(format: "%+.2f", pnl)
    return "Total PnL: " + (tradingInfo.currency ?? "") + " " + pnlString
}
func totalPositionCost(_ tradingInfo: TradingInfo, _ position: Position)->String {
    return "Position Cost: " + (tradingInfo.currency ?? "") + " " + String(format: "%.2f", position.unitSize*position.positionAvgCost)
}
func currentPositionValue(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let positionValue = tradingInfo.currentPrice*position.unitSize
    let positionString = String(format: "%.2f", positionValue)
    return "Market Value: " + (tradingInfo.currency ?? "") + " " + positionString
}

struct TradingInfo {
    var currentPrice : Double = .nan
    var prevClosePrice : Double = .nan
    
    var currency : String? = nil
    var regularMarketTime: Int = 0
    var exchangeTimezoneName: String = ""
    var shortName: String = ""
    func getPrice()->String {
        return (currency ?? "Price") + " " + String(format: "%.3f", currentPrice)
    }
    func getChange()->String {
        return String(format: "%+.2f",currentPrice - prevClosePrice)
    }
    func getLongChange()->String {
        return String(format: "%+.4f",currentPrice - prevClosePrice)
    }
    func getChangePct()->String {
        guard prevClosePrice != 0 else { return "+0.0000%" }
        return String(format: "%+.4f", 100*(currentPrice - prevClosePrice)/prevClosePrice)+"%"
    }
    func getTimeInfo()->String {
        let date = Date(timeIntervalSince1970: TimeInterval(regularMarketTime))
        let tradeTimeZone = TimeZone(identifier: exchangeTimezoneName)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm zzz"
        dateFormatter.timeZone = tradeTimeZone
        return dateFormatter.string(from: date)
    }
}
