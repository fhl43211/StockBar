//
//  TickerMenu.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Cocoa
func dailyPNL(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let unitSize = Double(position.unitSize) ?? 0
    let pnl = (tradingInfo.currentPrice - tradingInfo.prevClosePrice)*unitSize
    let pnlString = String(format: "%.2f", pnl)
    return "DailyPnL: " + (tradingInfo.currency ?? "Price") + " " + pnlString
}
fileprivate func totalPNL(_ tradingInfo: TradingInfo, _ position: Position)->String {
    let unitSize = Double(position.unitSize) ?? 0
    let avgCost = Double(position.positionAvgCost) ?? 0
    let pnl = (tradingInfo.currentPrice - avgCost)*unitSize
    let pnlString = String(format: "%.2f", pnl)
    return "TotalPnL: " + (tradingInfo.currency ?? "Price") + " " + pnlString
}

final class TickerMenu: NSMenu {
    init(tradingInfo: TradingInfo, position: Position) {
        super.init(title: String())
        self.addItem(withTitle: tradingInfo.getPrice(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: tradingInfo.getChangePct(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: tradingInfo.getLongChange(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: tradingInfo.getTimeInfo(), action: nil, keyEquivalent: "")
        self.addItem(NSMenuItem.separator())
        self.addItem(withTitle: dailyPNL(tradingInfo, position), action: nil, keyEquivalent: "")
        self.addItem(withTitle: totalPNL(tradingInfo, position), action: nil, keyEquivalent: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTickerMenu(metaInfo: Meta) {
        self.item(at: 0)!.title = metaInfo.getPrice()
        self.item(at: 1)!.title = metaInfo.getChangePct()
        self.item(at: 2)!.title = metaInfo.getLongChange()
        self.item(at: 3)!.title = metaInfo.getTimeInfo()
    }
}

final class TickerErrorMenu: NSMenu {
    init(errorMsg: String) {
        super.init(title: String())
        self.addItem(withTitle: errorMsg, action: nil, keyEquivalent: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateErrorMenu(error: Error) {
        self.item(at: 0)!.title = error.errorDescription
    }
}
