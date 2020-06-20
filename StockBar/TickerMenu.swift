//
//  TickerMenu.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Cocoa

final class TickerMenu: NSMenu {
    init(metaInfo: Meta) {
        super.init(title: String())
        self.addItem(withTitle: metaInfo.getPrice(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: metaInfo.getChangePct(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: metaInfo.getLongChange(), action: nil, keyEquivalent: "")
        self.addItem(withTitle: metaInfo.getTimeInfo(), action: nil, keyEquivalent: "")
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
