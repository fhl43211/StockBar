//
//  StockMenuBarController.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Foundation
import Combine
import Cocoa


class StockMenuBarController {
    init (data: DataModel) {
        self.data = data
        self.statusBar = StockStatusBar()
        self.prefPopover = PreferencePopover(data: data)
        constructMainItem()
        // Every time the vector of $realTimeTrades changes (e.g. a new symbol is inserted anywhere or a symbol is deleted),
        //  this resets all the symbol items of the menubar
        self.cancellables = self.data.$realTimeTrades
            .receive(on: DispatchQueue.main)
            .sink { [weak self] realTimeTrades in
                self?.updateSymbolItemsFromUserData(realTimeTrades: realTimeTrades)
        }
        // Fetch immediately on launch, which also starts the 60s refresh timer
        sendAllTradesToSubscriber()
    }
    private var cancellables : AnyCancellable?
    private let statusBar : StockStatusBar
    private let data : DataModel
    private var prefPopover : PreferencePopover
    private lazy var timer = Timer()
    private lazy var mainMenuItems = [NSMenuItem(title: "Refresh", action: #selector(sendAllTradesToSubscriber), keyEquivalent: ""),
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
    private func updateSymbolItemsFromUserData(realTimeTrades: [RealTimeTrade]) {
        statusBar.updateSymbolItems(from: realTimeTrades)
    }
    // Trigger the quotes update for all symbols from URLSession.
    // This happens either when manually pressing the Refresh button
    // or every 60 seconds specified in StockMenuBarController.timer
    @objc private func sendAllTradesToSubscriber() {
        // Reset timer so manual refresh and timer-triggered refresh don't overlap
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.sendAllTradesToSubscriber()
        }
        self.data.realTimeTrades.forEach { each in
            each.sendTradeToPublisher()
        }
    }
    @objc private func quitApp() {
        NSApp.terminate(self)
    }
    
    @objc func togglePopover(_ sender: Any?) {
        showPopover(sender: sender)
    }

    func showPopover(sender: Any?) {
        if let button = self.statusBar.mainItem().button {
            prefPopover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
