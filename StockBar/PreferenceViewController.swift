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
        super.init(rootView: PreferenceView())
    }
    @objc required dynamic init?(coder: NSCoder) {
        super.init(coder: coder, rootView: PreferenceView())
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
        for iter in (0..<UserData.sharedInstance.realTimeTrades.count) {
            UserData.sharedInstance.realTimeTrades[iter].sendTradeToPublisher()
        }
    }
}
class PreferenceViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        showExistingPrefs()
    }
    
    private var prefs = Preferences()
    
    @IBOutlet weak var tickerBox0: NSTextField!
    @IBOutlet weak var tickerBox1: NSTextField!
    @IBOutlet weak var tickerBox2: NSTextField!
    @IBOutlet weak var tickerBox3: NSTextField!
    @IBOutlet weak var tickerBox4: NSTextField!
    
    func showExistingPrefs() {
        self.tickerBox0.stringValue = prefs.prefTicker0
        self.tickerBox1.stringValue = prefs.prefTicker1
        self.tickerBox2.stringValue = prefs.prefTicker2
        self.tickerBox3.stringValue = prefs.prefTicker3
        self.tickerBox4.stringValue = prefs.prefTicker4
    }
    
    func saveNewPrefs() {
        prefs.prefTicker0 = self.tickerBox0.stringValue
        prefs.prefTicker1 = self.tickerBox1.stringValue
        prefs.prefTicker2 = self.tickerBox2.stringValue
        prefs.prefTicker3 = self.tickerBox3.stringValue
        prefs.prefTicker4 = self.tickerBox4.stringValue
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                        object: nil)
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        saveNewPrefs()
    }
}

extension PreferenceViewController {
  static func buildController() -> PreferenceViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier("PrefViewController")
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PreferenceViewController else {
      fatalError("Cannot find PrefViewController")
    }
    return viewcontroller
  }
}
