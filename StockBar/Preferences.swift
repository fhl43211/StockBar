//
//  Preferences.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Foundation

class Preferences {
    func nonEmptyTickers() -> [String] {
        var tickers : [String] = []
        if (prefTicker0 != "") {
            tickers.append(prefTicker0)
        }
        if (prefTicker1 != "") {
            tickers.append(prefTicker1)
        }
        if (prefTicker2 != "") {
            tickers.append(prefTicker2)
        }
        if (prefTicker3 != "") {
            tickers.append(prefTicker3)
        }
        if (prefTicker4 != "") {
            tickers.append(prefTicker4)
        }
        return tickers
    }
    var prefTicker0: String {
      get {
          guard let tickerName = UserDefaults.standard.string(forKey: "Ticker0") else {
              return ""
          }
          return tickerName
      }
      set {
        UserDefaults.standard.set(newValue, forKey: "Ticker0")
      }
    }
    
    var prefTicker1: String {
      get {
        guard let tickerName = UserDefaults.standard.string(forKey: "Ticker1") else {
            return ""
        }
        return tickerName
      }
      set {
        UserDefaults.standard.set(newValue, forKey: "Ticker1")
      }
    }
    
    var prefTicker2: String {
      get {
        guard let tickerName = UserDefaults.standard.string(forKey: "Ticker2") else {
            return ""
        }
        return tickerName
      }
      set {
        UserDefaults.standard.set(newValue, forKey: "Ticker2")
      }
    }
    
    var prefTicker3: String {
      get {
        guard let tickerName = UserDefaults.standard.string(forKey: "Ticker3") else {
            return ""
        }
        return tickerName
      }
      set {
        UserDefaults.standard.set(newValue, forKey: "Ticker3")
      }
    }

    var prefTicker4: String {
      get {
        guard let tickerName = UserDefaults.standard.string(forKey: "Ticker4") else {
            return ""
        }
        return tickerName
      }
      set {
        UserDefaults.standard.set(newValue, forKey: "Ticker4")
      }
    }
}
