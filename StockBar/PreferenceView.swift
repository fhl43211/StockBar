//
//  PreferenceView.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-08-02.
//  Copyright © 2020 Hongliang Fan. All rights reserved.
//

import SwiftUI

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
        ForEach(0..<size) { iter in
            HStack {
                Spacer()
                TextField( "symbol", text: self.$userdata.realTimeTrades[iter].trade.name )
                TextField( "unit size", text: self.$userdata.realTimeTrades[iter].trade.position.unitSize )
                TextField( "average position cost", text: self.$userdata.realTimeTrades[iter].trade.position.positionAvgCost )
                Text("\(self.userdata.realTimeTrades[iter].realTimeInfo.currentPrice)")
                Spacer()
            }
        }
    }
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView(userdata: .sharedInstance)
    }
}
