//
//  AppDelegate.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController : StockMenuBarController?
    private var userdata : DataModel = DataModel()
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarController = StockMenuBarController(data: userdata)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }



}


