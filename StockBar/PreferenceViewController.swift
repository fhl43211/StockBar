//
//  PreferenceViewController.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Cocoa
import Combine
import SwiftUI

class PreferenceHostingController: NSHostingController<PreferenceView> {
    private let data: DataModel

    init(data: DataModel) {
        self.data = data
        super.init(rootView: PreferenceView(userdata: data))
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        saveNewPrefs()
    }

    func saveNewPrefs() {
        do {
            let trades = data.realTimeTrades.map { $0.trade }
            let encodedData = try JSONEncoder().encode(trades)
            UserDefaults.standard.set(encodedData, forKey: "usertrades")
        } catch {
            print("Failed to save preferences: \(error.localizedDescription)")
        }
    }
}
