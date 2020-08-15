//
//  TickerMenu.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Cocoa
func dailyPNLNumber(_ tradingInfo: TradingInfo, _ position: Position)->Double {
    let unitSize = Double(position.unitSize) ?? .nan
    return (tradingInfo.currentPrice - tradingInfo.prevClosePrice)*unitSize
}
func dailyPNL(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let pnlString = String(format: "%+.2f", dailyPNLNumber(tradingInfo, position))
    return "DailyPnL: " + (tradingInfo.currency ?? "Price") + " " + pnlString
}
fileprivate func totalPNL(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let unitSize = Double(position.unitSize) ?? .nan
    let avgCost = Double(position.positionAvgCost) ?? .nan
    let pnl = (tradingInfo.currentPrice - avgCost)*unitSize
    let pnlString = String(format: "%+.2f", pnl)
    return "TotalPnL: " + (tradingInfo.currency ?? "Price") + " " + pnlString
}
fileprivate func totalPositionCost(_ position: Position)->String {
    let unitSize = Double(position.unitSize) ?? .nan
    let avgCost = Double(position.positionAvgCost) ?? .nan
    return "Position cost: "+String(format: "%.2f", unitSize*avgCost)
}
fileprivate func currentPositionValue(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let unitSize = Double(position.unitSize) ?? .nan
    let positionValue = tradingInfo.currentPrice*unitSize
    let positionString = String(format: "%.2f", positionValue)
    return "Market value: " + (tradingInfo.currency ?? "Price") + " " + positionString
}

final class SymbolMenu: NSMenu {
    init(tradingInfo: TradingInfo, position: Position) {
        super.init(title: String())
        self.addItem(withTitle: tradingInfo.getPrice(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: tradingInfo.getChangePct(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: tradingInfo.getLongChange(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: tradingInfo.getTimeInfo(), action: nil, keyEquivalent: "")
        self.addItem(NSMenuItem.separator())
        self.addItem(withTitle: dailyPNL(tradingInfo, position), action: nil, keyEquivalent: "")
        self.addItem(withTitle: totalPNL(tradingInfo, position), action: nil, keyEquivalent: "")
        self.addItem(withTitle: "Units: \(position.unitSize)", action: nil, keyEquivalent: "")
        self.addItem(withTitle: "Avg Position Cost: \(position.positionAvgCost)", action: nil, keyEquivalent: "")
        self.addItem(withTitle: totalPositionCost(position), action: nil, keyEquivalent: "")
        self.addItem(withTitle: currentPositionValue(tradingInfo, position), action: nil, keyEquivalent: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
