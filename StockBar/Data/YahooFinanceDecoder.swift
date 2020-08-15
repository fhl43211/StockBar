//
//  YahooFinanceDecoder.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Foundation

struct Overview: Codable {
    let chart: ChartClass
}

struct ChartClass: Codable {
    let result: [Result]?
    let error: Error?
}

struct Result: Codable {
    let meta: Meta
}

struct Meta: Codable {
    let currency : String?
    let symbol: String
    let regularMarketTime: Int
    let exchangeTimezoneName: String
    let regularMarketPrice: Double
    let chartPreviousClose: Double
    func getPrice()->String {
        return (currency ?? "Price") + " " + String(format: "%.2f", regularMarketPrice)
    }
    func getChange()->String {
        return String(format: "%+.2f",regularMarketPrice - chartPreviousClose)
    }
    func getLongChange()->String {
        return String(format: "%+.4f",regularMarketPrice - chartPreviousClose)
    }
    func getChangePct()->String {
        return String(format: "%+.4f", 100*(regularMarketPrice - chartPreviousClose)/chartPreviousClose)+"%"
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
    let errorDescription: String

    enum CodingKeys: String, CodingKey {
        case errorDescription = "description"
    }
}

