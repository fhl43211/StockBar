//
//  AppDelegate.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-06-20.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController : StockMenuBarController?
    private var userdata : UserData = .sharedInstance
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarController = StockMenuBarController()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }



}


