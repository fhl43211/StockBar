//
//  UserData.swift
//  StockBar
//
//  Created by Hongliang Fan on 2020-08-02.
//

import Foundation
import Combine

// Single source of truth during app runtime.
// Loads from UserDefaults at startup, wraps Trade with empty RealTimeTrading info.
// User input modifies Trade, updates UserDefaults.
// Real-time trading info fetched from URLSession and updates RealTimeTrading,
// then reflected on NSStatusItem.
class DataModel: ObservableObject {
    private let decoder = JSONDecoder()
    
    @Published var realTimeTrades: [RealTimeTrade]
    
    init() {
        let data = UserDefaults.standard.data(forKey: "usertrades") ?? Data()
        let trades = (try? decoder.decode([Trade].self, from: data)) ?? emptyTrades(size: 1)
        self.realTimeTrades = trades.map {
            RealTimeTrade(trade: $0, realTimeInfo: TradingInfo())
        }
    }
}

class RealTimeTrade: ObservableObject, Identifiable {
    let id = UUID()
    
    static let apiBaseURL = "https://query1.finance.yahoo.com/v8/finance/chart/"
    static let emptyQueryURL = URL(string: apiBaseURL)!
    
    @Published var trade: Trade
    @Published var realTimeInfo: TradingInfo
    
    private let passThroughTrade = PassthroughSubject<Trade, Never>()
    private var cancellable: AnyCancellable?
    private var isCancelled = false
    
    // Shared publisher to avoid duplicate subscriptions
    lazy var sharedPassThroughTrade = passThroughTrade.share()
    
    init(trade: Trade, realTimeInfo: TradingInfo) {
        self.trade = trade
        self.realTimeInfo = realTimeInfo
        
        if #available(macOS 11.0, *) {
            initCancellable()
        } else {
            // fallback or no-op for older versions
            // Optionally log or handle gracefully here
        }
    }
    
    func sendTradeToPublisher() {
        if isCancelled {
            if #available(macOS 11.0, *) {
                initCancellable()
            }
        }
        passThroughTrade.send(trade)
    }
    
    @available(macOS 11.0, *)
    func initCancellable() {
        isCancelled = false
        
        cancellable = sharedPassThroughTrade
            .merge(with: $trade
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates(by: { $0.name == $1.name }))
            .filter { !$0.name.isEmpty }
            .setFailureType(to: URLError.self)
            .flatMap(maxPublishers: .max(1)) { singleTrade -> AnyPublisher<YahooFinanceQuote, Never> in
                var components = URLComponents(string: Self.apiBaseURL + singleTrade.name)
                components?.queryItems = [URLQueryItem(name: "interval", value: "1d")]
                guard let url = components?.url else {
                    return Just(YahooFinanceQuote(chart: nil)).eraseToAnyPublisher()
                }
                
                return URLSession.shared.dataTaskPublisher(for: url)
                    .map(\.data)
                    .decode(type: YahooFinanceQuote.self, decoder: JSONDecoder())
                    .catch { error in
                        print("Fetch or decode error: \(error.localizedDescription)")
                        return Just(YahooFinanceQuote(chart: nil))
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Data task failed: \(error.localizedDescription)")
                }
                self?.cancellable?.cancel()
                self?.isCancelled = true
            }, receiveValue: { [weak self] quote in
                guard let meta = quote.chart?.result?.first?.meta else {
                    self?.realTimeInfo = TradingInfo()
                    return
                }
                
                self?.realTimeInfo = TradingInfo(
                    currentPrice: meta.regularMarketPrice,
                    prevClosePrice: meta.regularMarketPreviousClose,
                    currency: meta.currency,
                    regularMarketTime: meta.regularMarketTime,
                    exchangeTimezoneName: meta.exchangeTimezoneName,
                    shortName: meta.shortName
                )
            })
    }
}

func emptyTrades(size: Int) -> [Trade] {
    Array(repeating: Trade(name: "", position: Position(unitSize: "1", positionAvgCost: "")), count: size)
}

func emptyRealTimeTrade() -> RealTimeTrade {
    RealTimeTrade(
        trade: Trade(name: "", position: Position(unitSize: "1", positionAvgCost: "")),
        realTimeInfo: TradingInfo()
    )
}
