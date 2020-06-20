//
//  StockMenuBarController.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Foundation
import Cocoa


class StockMenuBarController {
    init () {
        constructMainItem()
        updateTickerItemsFromPrefs()
        setupPrefsObservers()
        self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(fetchAllQuote),                                                                              userInfo: nil, repeats: true)
    }
    private let statusBar = StockStatusBar()
    private lazy var prefs = Preferences()
    private lazy var timer = Timer()
    private lazy var prefPopover = PreferencePopover()
    private lazy var mainMenuItems = [NSMenuItem(title: "Refresh", action: #selector(fetchAllQuote), keyEquivalent: ""),
                                      NSMenuItem.separator(),
                                      NSMenuItem(title: "Preference", action: #selector(togglePopover), keyEquivalent: ""),
                                      NSMenuItem(title:  "Exit", action: #selector(quitApp), keyEquivalent: "q")]
}

extension StockMenuBarController {
    func constructMainItem() {
        for item in mainMenuItems {
            item.target = self
        }
        self.statusBar.constructMainItemMenu(items: mainMenuItems)
    }
    private func updateTickerItemsFromPrefs() {
        statusBar.removeAllTickerItems()
        for id in prefs.nonEmptyTickers() {
            statusBar.constructTickerItems(tickerId: id)
        }
        fetchAllQuote()
    }
    private func fetchQuoteAndUpdateItem(item: NSStatusItem?) {
        if (item == nil) {
            return
        }
        if (item!.button == nil) {
            return
        }
        let button = item!.button
        let tickerId = button!.alternateTitle
        let url = URL( string: ("https://query1.finance.yahoo.com/v8/finance/chart/" + tickerId + "?interval=1d") )!
        let fetchStockQuote = URLSession.shared.dataTask(with: url) { ( data, response, error ) in
            let jsonDecoder = JSONDecoder()
            // TODO(HF) error not handled
            if let data = data, let overview = try?jsonDecoder.decode(Overview.self, from: data) {
                DispatchQueue.main.async {
                    let chart = overview.chart;
                    if let msg = chart.error {
                        // Error occured
                        if let errorMenu = item!.menu as? TickerErrorMenu {
                            errorMenu.updateErrorMenu(error: msg)
                        }
                        else {
                            button!.title = button!.alternateTitle
                            item!.menu = TickerErrorMenu(errorMsg: msg.errorDescription)
                        }
                    }
                    else if let results = chart.result {
                        let metaInfo = results[0].meta
                        button!.title = metaInfo.symbol + metaInfo.getChange()
                        if let tickerMenu = item!.menu as? TickerMenu {
                            tickerMenu.updateTickerMenu(metaInfo: metaInfo)
                        }
                        else {
                            item!.menu = TickerMenu(metaInfo: metaInfo)
                        }
                        
                    }
                }
            }
            else {
            }
        }
        fetchStockQuote.resume()
    }

    @objc private func fetchAllQuote() {
        for tickerItem in self.statusBar.tickerItems() {
            fetchQuoteAndUpdateItem(item: tickerItem)
        }
    }
    @objc private func quitApp() {
        NSApp.terminate(self)
    }
    
    @objc func togglePopover(_ sender: Any?) {
        showPopover(sender: sender)
    }

    func showPopover(sender: Any?) {
        if let button = self.statusBar.mainItem()?.button {
            prefPopover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    func setupPrefsObservers() {
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil, queue: nil) {
          (notification) in
                                                self.updateTickerItemsFromPrefs()
        }
    }
}
