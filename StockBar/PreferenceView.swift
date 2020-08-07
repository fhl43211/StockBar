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
    @ObservedObject var userdata : UserData
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
        ForEach(userdata.realTimeTrades) { item in
            HStack {
                Button(action: {
                    if let index = self.userdata.realTimeTrades.map({$0.id}).firstIndex(of: item.id) {
                        self.userdata.realTimeTrades.remove(at: index)
                    }
                }){
                    Text("-")
                }
                PreferenceRow(realTimeTrade: item)
                Button(action: {
                    let emptyTrade = RealTimeTrade(trade: Trade(name: "",
                                                                position: Position(unitSize: "",
                                                                                   positionAvgCost: "")),
                                                   realTimeInfo: TradingInfo())
                    if let index = self.userdata.realTimeTrades.map({$0.id}).firstIndex(of: item.id) {
                        self.userdata.realTimeTrades.insert(emptyTrade, at: index+1)
                    }
                }){
                    Text("+")
                }
            }
            
        }
    }
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView(userdata: UserData.sharedInstance)
    }
}
