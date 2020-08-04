//
//  PreferenceView.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-08-02.
//  Copyright © 2020 Hongliang Fan. All rights reserved.
//

import SwiftUI

struct PreferenceRow : View {
    @ObservedObject var realTimeTrade : RealTimeTrade
    var body: some View {
        HStack {
            Spacer()
            TextField( "symbol", text: self.$realTimeTrade.trade.name )
            TextField( "unit size", text: self.$realTimeTrade.trade.position.unitSize )
            TextField( "average position cost", text: self.$realTimeTrade.trade.position.positionAvgCost )
            Text("\(self.realTimeTrade.realTimeInfo.currentPrice)")
            Spacer()
        }
    }
}

struct PreferenceView: View {
    let userdata : UserData = UserData.sharedInstance
    var size : Int {
        get {
            userdata.realTimeTrades.count
        }
    }
    var body: some View {
//        Section {
//            Spacer()
//            Text("Symbol")
//            Text("Unit")
//            Text("Average position cost")
//            Spacer()
//        }
        ForEach(0..<size) { iter in
            PreferenceRow(realTimeTrade: UserData.sharedInstance.realTimeTrades[iter])
        }
    }
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView()
    }
}
