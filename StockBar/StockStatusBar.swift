//
//  StockStatusBar.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Foundation
import Combine
import Cocoa

class StockStatusBar: NSStatusBar {
    let userdata = UserData.sharedInstance
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
//        tickerStatusItems.forEach { controller in
//            controller.cancellable?.cancel()
//        }
        tickerStatusItems = []
    }
    func constructTickerItems(realTimeTrade : RealTimeTrade) {
        tickerStatusItems.append(StockStatusItemController(realTimeTrade: realTimeTrade))
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
    init(realTimeTrade : RealTimeTrade) {
        item.button?.title = realTimeTrade.trade.name
        item.button?.alternateTitle = realTimeTrade.trade.name
        cancellable = Publishers.CombineLatest(realTimeTrade.sharedPassThroughTrade
            .merge(with: realTimeTrade.$trade.share()
            //.debounce(for: .seconds(1), scheduler: RunLoop.main)
//            .removeDuplicates {
//                $0.name == $1.name
//        }
        ), realTimeTrade.$realTimeInfo)
            //.debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] (trade, trading) in
                self?.item.button?.title = trade.name + String(format: "%+.2f", dailyPNLNumber(trading, trade.position))
                self?.item.button?.alternateTitle = trade.name
                self?.item.menu = TickerMenu(tradingInfo: trading, position: trade.position)
        }
    }
    var item: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var cancellable: AnyCancellable?
}
