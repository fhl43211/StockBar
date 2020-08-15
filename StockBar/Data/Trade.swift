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
    var unitSize : String
    var positionAvgCost : String
}

struct TradingInfo {
    var currentPrice : Double = .nan
    var prevClosePrice : Double = .nan
    
    var currency : String? = nil
    var regularMarketTime: Int = 0
    var exchangeTimezoneName: String = ""
    func getPrice()->String {
        return (currency ?? "Price") + " " + String(format: "%.2f", currentPrice)
    }
    func getChange()->String {
        return String(format: "%+.2f",currentPrice - prevClosePrice)
    }
    func getLongChange()->String {
        return String(format: "%+.4f",currentPrice - prevClosePrice)
    }
    func getChangePct()->String {
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
