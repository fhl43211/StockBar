//
//  YahooFinanceDecoder.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Foundation

struct YahooFinanceQuote: Codable {
    let chart: Chart?
}

struct Chart: Codable {
    let result: [ChartResult]?
    let error: Error?
}

struct ChartResult: Codable {
    let meta: Meta
}

struct Meta: Codable {
    let currency : String?
    let symbol: String
    let shortName: String
    let regularMarketTime: Int
    let exchangeTimezoneName: String
    let regularMarketPrice: Double
    let chartPreviousClose: Double?
    
    enum CodingKeys: String, CodingKey {
        case currency, symbol, shortName, regularMarketTime, exchangeTimezoneName, regularMarketPrice, chartPreviousClose
    }
    
    var regularMarketPreviousClose: Double {
        return chartPreviousClose ?? 0.0
    }
    
    func getPrice()->String {
        return (currency ?? "Price") + " " + String(format: "%.2f", regularMarketPrice)
    }
    func getChange()->String {
        return String(format: "%+.2f",regularMarketPrice - regularMarketPreviousClose)
    }
    func getLongChange()->String {
        return String(format: "%+.4f",regularMarketPrice - regularMarketPreviousClose)
    }
    func getChangePct()->String {
        return String(format: "%+.4f", 100*(regularMarketPrice - regularMarketPreviousClose)/regularMarketPreviousClose)+"%"
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

struct Error: Codable {
    let description: String
}

