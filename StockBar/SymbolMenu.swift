//
//  SymbolMenu.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Cocoa
func dailyPNLNumber(_ tradingInfo: TradingInfo, _ position: Position)->Double {
    return (tradingInfo.currentPrice - tradingInfo.prevClosePrice)*position.unitSize
}
func dailyPNL(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let pnlString = String(format: "%+.2f", dailyPNLNumber(tradingInfo, position))
    return "Daily PnL: " + (tradingInfo.currency ?? "") + " " + pnlString
}
fileprivate func totalPNL(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let pnl = (tradingInfo.currentPrice - position.positionAvgCost)*position.unitSize
    let pnlString = String(format: "%+.2f", pnl)
    return "Total PnL: " + (tradingInfo.currency ?? "") + " " + pnlString
}
fileprivate func totalPositionCost(_ tradingInfo: TradingInfo, _ position: Position)->String {
    return "Position Cost: " + (tradingInfo.currency ?? "") + " " + String(format: "%.2f", position.unitSize*position.positionAvgCost)
}
fileprivate func currentPositionValue(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let positionValue = tradingInfo.currentPrice*position.unitSize
    let positionString = String(format: "%.2f", positionValue)
    return "Market Value: " + (tradingInfo.currency ?? "") + " " + positionString
}

final class SymbolMenu: NSMenu {
    init(tradingInfo: TradingInfo, position: Position) {
        super.init(title: String())
        self.addItem(withTitle: tradingInfo.shortName, action: nil, keyEquivalent: "")
        self.addItem(NSMenuItem.separator())
        self.addItem(withTitle: tradingInfo.getPrice(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: tradingInfo.getChangePct(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: tradingInfo.getLongChange(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: tradingInfo.getTimeInfo(), action: nil, keyEquivalent: "")
        self.addItem(NSMenuItem.separator())
        self.addItem(withTitle: dailyPNL(tradingInfo, position), action: nil, keyEquivalent: "")
        self.addItem(withTitle: totalPNL(tradingInfo, position), action: nil, keyEquivalent: "")
        self.addItem(withTitle: "Units: \(position.unitSize)", action: nil, keyEquivalent: "")
        self.addItem(withTitle: "Avg Position Cost: \(tradingInfo.currency ?? "") \(position.positionAvgCost)", action: nil, keyEquivalent: "")
        self.addItem(withTitle: totalPositionCost(tradingInfo, position), action: nil, keyEquivalent: "")
        self.addItem(withTitle: currentPositionValue(tradingInfo, position), action: nil, keyEquivalent: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
