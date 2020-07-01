//
//  StockStatusBar.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Foundation
import Combine
import Cocoa

class StockStatusBar: NSStatusBar {
    override init() {
        super.init()
        mainStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        mainStatusItem?.button?.title = "StockBar"
    }
    func constructMainItemMenu(items : [NSMenuItem]) {
        let menu = NSMenu()
        for item in items {
            menu.addItem(item)
        }
        mainStatusItem?.menu = menu
    }
    func removeAllTickerItems() {
        tickerStatusItems = []
    }
    func constructTickerItems(tickerId : String) {
        tickerStatusItems.append(StockStatusItemController(tickerId: tickerId))
    }
    func tickerItems() -> [StockStatusItemController] {
        return tickerStatusItems
    }
    func mainItem() -> NSStatusItem? {
        return mainStatusItem
    }
    private var mainStatusItem : NSStatusItem?
    private var tickerStatusItems : [StockStatusItemController] = []
}

class StockStatusItemController {
    init(tickerId : String) {
        item.button?.title = tickerId
        item.button?.alternateTitle = tickerId
    }
    var item: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var cancellable: AnyCancellable?
}
