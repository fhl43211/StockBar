//
//  PreferencePopover.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Cocoa
import SwiftUI

class PreferencePopover: NSPopover {
    override init() {
        super.init()
        self.behavior = NSPopover.Behavior.transient
        //self.contentViewController = PreferenceViewController.buildController()
        self.contentViewController = PreferenceHostingController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
