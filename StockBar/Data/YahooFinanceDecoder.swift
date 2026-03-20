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
    let error: ChartError?
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
    
    var regularMarketPreviousClose: Double {
        return chartPreviousClose ?? 0.0
    }
}

struct ChartError: Codable {
    let description: String
}

