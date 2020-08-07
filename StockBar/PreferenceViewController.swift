//
//  PreferenceViewController.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Cocoa
import Combine
import SwiftUI
class PreferenceHostingController : NSHostingController<PreferenceView> {
    init() {
        super.init(rootView: PreferenceView(userdata: UserData.sharedInstance))
    }
    @objc required dynamic init?(coder: NSCoder) {
        super.init(coder: coder, rootView: PreferenceView(userdata: UserData.sharedInstance))
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        saveNewPrefs()
    }
    func saveNewPrefs() {
        let trades = UserData.sharedInstance.realTimeTrades.map {
            $0.trade
        }
        let encodedData : Data = try! JSONEncoder().encode(trades)
        UserDefaults.standard.set( encodedData, forKey: "usertrades")
//        for iter in (0..<UserData.sharedInstance.realTimeTrades.count) {
//            UserData.sharedInstance.realTimeTrades[iter].sendTradeToPublisher()
//        }
    }
}
