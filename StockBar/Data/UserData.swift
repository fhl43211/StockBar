//
//  UserData.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-08-02.

import Foundation
import Combine

class RealTimeTrade : ObservableObject, Identifiable {
    let id = UUID()
    @Published var trade : Trade
    private let passThroughTrade : PassthroughSubject<Trade, Never> = PassthroughSubject()
    var sharedPassThroughTrade: Publishers.Share<PassthroughSubject<Trade, Never>>
    @Published var realTimeInfo : TradingInfo
    func sendTradeToPublisher() {
        if (cancelled) {
            initCancellable()
        }
        passThroughTrade.send(trade)
    }
    func initCancellable() {
        self.cancelled = false
        self.cancellable = sharedPassThroughTrade
            .merge(with: $trade.share()
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates {
                    $0.name == $1.name
            })
            .filter {
                $0.name != ""
            }
            .setFailureType(to: URLSession.DataTaskPublisher.Failure.self)
            .flatMap { singleTrade in
                    return URLSession.shared.dataTaskPublisher(for: URL( string: ("https://query1.finance.yahoo.com/v8/finance/chart/\(singleTrade.name)?interval=1d") )!)
            }
            .map(\.data)
            .compactMap { try? JSONDecoder().decode(Overview.self, from: $0) }
            .receive(on: DispatchQueue.main)
            .sink (
                receiveCompletion: { [weak self] _ in
                    self?.cancellable?.cancel()
                    self?.cancelled = true
                },
                receiveValue: { [weak self] overview in
                    let chart = overview.chart;
                    if let _ = chart.error {
                        self?.realTimeInfo = TradingInfo()
                    }
                    else if let results = chart.result {
                        let newRealTimeInfo = TradingInfo(currentPrice: results[0].meta.regularMarketPrice,
                                                          prevClosePrice: results[0].meta.chartPreviousClose,
                                                          currency: results[0].meta.currency,
                                                          regularMarketTime: results[0].meta.regularMarketTime,
                                                          exchangeTimezoneName: results[0].meta.exchangeTimezoneName)
                        self?.realTimeInfo = newRealTimeInfo
                    }
                }
            )
    }
    init(trade: Trade, realTimeInfo: TradingInfo) {
        self.trade = trade
        self.realTimeInfo = realTimeInfo
        self.sharedPassThroughTrade = self.passThroughTrade.share()
        initCancellable()
    }
    var cancellable : AnyCancellable? = nil
    var cancelled : Bool = false
    
}

// This is a single source of truth during the running of this app.
// It loads from the UserDefaults at startup and all the user input goes here. It then updates the UserDefaults
class DataModel : ObservableObject{
    let decoder = JSONDecoder()
    @Published var realTimeTrades : [RealTimeTrade]
    init() {
        let data = UserDefaults.standard.object(forKey: "usertrades") as? Data ?? Data()
        self.realTimeTrades = ((try? decoder.decode([Trade].self, from: data)) ?? emptyTrades(size: 1))
            .map {
                RealTimeTrade(trade: $0, realTimeInfo: TradingInfo())
            }
    }
}

func emptyTrades(size : Int) -> [Trade]{
    return [Trade].init(repeating: Trade(name: "", position: Position(unitSize: "1", positionAvgCost: "")), count: size)
}

func emptyRealTimeTrade()->RealTimeTrade {
    return RealTimeTrade(trade: Trade(name: "",
                                      position: Position(unitSize: "1",
                                                         positionAvgCost: "")),
                         realTimeInfo: TradingInfo())
}
