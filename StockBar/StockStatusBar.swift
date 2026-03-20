//
//  StockStatusBar.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Foundation
import Combine
import Cocoa

class StockStatusBar {
    private let mainStatusItem: NSStatusItem
    private var symbolStatusItems: [UUID: StockStatusItemController] = [:]

    init() {
        mainStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        mainStatusItem.button?.title = "StockBar"
    }
    func constructMainItemMenu(items : [NSMenuItem]) {
        let menu = NSMenu()
        for item in items {
            menu.addItem(item)
        }
        mainStatusItem.menu = menu
    }
    func updateSymbolItems(from realTimeTrades: [RealTimeTrade]) {
        let newIDs = Set(realTimeTrades.map { $0.id })
        let oldIDs = Set(symbolStatusItems.keys)

        // Remove items that no longer exist
        for id in oldIDs.subtracting(newIDs) {
            symbolStatusItems.removeValue(forKey: id)
        }
        // Add items that are new
        for trade in realTimeTrades where !oldIDs.contains(trade.id) {
            symbolStatusItems[trade.id] = StockStatusItemController(realTimeTrade: trade)
        }
    }
    func mainItem() -> NSStatusItem {
        return mainStatusItem
    }
}

class StockStatusItemController {
    init(realTimeTrade : RealTimeTrade) {
        item.button?.title = realTimeTrade.trade.name
        item.button?.alternateTitle = realTimeTrade.trade.name
        // Set the toggle ButtonType to enable alternateTitle display
        item.button?.setButtonType(NSButton.ButtonType.toggle)
        // For a single trade, when any of the symbol, unit size, avg cost position, real time info changes,
        // update the detail menu and the button title.
        cancellable = Publishers.CombineLatest(realTimeTrade.sharedPassThroughTrade.merge(with: realTimeTrade.$trade.share()),
                                               realTimeTrade.$realTimeInfo.share())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (trade, trading) in
                self?.item.button?.title = trade.name + String(format: "%+.2f", dailyPNLNumber(trading, trade.position))
                self?.item.button?.alternateTitle = trade.name
                self?.item.menu = SymbolMenu(tradingInfo: trading, position: trade.position)
        }
    }
    var item: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var cancellable: AnyCancellable?
}
