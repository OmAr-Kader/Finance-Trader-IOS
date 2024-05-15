import Foundation
import SwiftUI
import Combine

class StockCompareObserve  : ObservableObject {
    
    private var scope = Scope()
    
    @Inject
    private var project: Project
    
    @MainActor
    @Published var state = State()
    
    private var cancelInfo: AnyCancellable? = nil
    private var cancelSupplysAndDemands: AnyCancellable? = nil

    @MainActor
    func loadData() {
        loadingStatus(true)
        self.scope.launchRealm {
            await self.project.stockInfo.getAllStockInfo { it in
                let stockInfos = it.value.toStockInfoData()
                self.scope.launchMain {
                    withAnimation {
                        self.state = self.state.copy(stocksInfo: stockInfos, stocksSearch: stockInfos, isLoading: false)
                    }
                }
            }
        }
    }
    
    @MainActor
    func addStock(_ stockInfoData: StockInfoData) {
        self.loadingStatus(true)
        let state = self.state
        self.scope.launchRealm {
            await self.project.stockInfo.getStockInfo(id: stockInfoData.id) { it in
                guard let _stockInfo = it.value else {
                    self.loadingStatus(false)
                    return
                }
                let stockInfo =  StockInfoData(stockInfo: _stockInfo)
                let stock = stockInfo.toHomeStockData(_stockInfo.stockSessions.toStockData(stockId: stockInfo.id)).injectStatus(mode: ChartMode.StockWave).injectColor(i: state.stocksNative.count)
                let splitStock = stock.splitStock(timeScope: stock.timeScope)
                let stocksNative = state.stocksNative.appendToStocks(stock)
                let stocks = state.stocks.appendToStocks(splitStock)
                let stockBoarderMulti = splitStock.values.minAndMaxValues(ChartMode.StockWave)
                self.scope.launchMain {
                    self.state = self.state.copy(
                        stocks: stocks,
                        stocksNative: stocksNative,
                        stockBoarderMulti: stockBoarderMulti,
                        timeScope: splitStock.timeScope,
                        stringData: splitStock.stringData,
                        isLoading: false,
                        dummy: self.state.dummy + 1
                    )
                }
            }
        }
    }
    
    @MainActor
    func onTimeScope(_ timeScope: Int64) {
        self.loadingStatus(true)
        let state = self.state
        self.scope.launchRealm {
            let stocks = state.stocksNative.map { it in
                it.splitStock(timeScope: timeScope)
            }
            self.scope.launchMain {
                self.state = self.state.copy(stocks: stocks, timeScope: timeScope, stringData: stocks.first?.stringData ?? "", isLoading: false)
            }
        }
    }
    
    @MainActor
    func onSearch(str: String) {
        let state = self.state
        self.scope.launchMed {
            let stocksSearch = if str.isEmpty {
                state.stocksInfo
            } else {
                state.stocksInfo.filter { it in
                    it.name.range(of: str, options: .caseInsensitive) != nil || it.symbol.range(of: str, options: .caseInsensitive) != nil
                }
            }
            self.scope.launchMain {
                self.state = self.state.copy(stocksSearch: stocksSearch)
            }
        }
    }
    
    private func loadingStatus(_ it: Bool) {
        if it == true {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: it)
            }
        } else {
            self.scope.launchMain {
                withAnimation {
                    self.state = self.state.copy(isLoading: it)
                }
            }
        }
    }
    
    struct State {
        
        var stocks: [StockData] = []
        var stocksNative: [StockData] = []
        var stocksInfo: [StockInfoData] = []
        var stocksSearch: [StockInfoData] = []
        var stockBoarderMulti: StockBoarder = StockBoarder()
        var timeScope: Int64 = DEFAULT_TIME_SCOPE
        var stringData: String = ""
        var isLoading: Bool = false
        var dummy: Int = 0

        mutating func copy(
            stocks: [StockData]? = nil,
            stocksNative: [StockData]? = nil,
            stocksInfo: [StockInfoData]? = nil,
            stocksSearch: [StockInfoData]? = nil,
            stockBoarderMulti: StockBoarder? = nil,
            timeScope: Int64? = nil,
            stringData: String? = nil,
            isLoading: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.stocks = stocks ?? self.stocks
            self.stocksNative = stocksNative ?? self.stocksNative
            self.stocksInfo = stocksInfo ?? self.stocksInfo
            self.stocksSearch = stocksSearch ?? self.stocksSearch
            self.stockBoarderMulti = stockBoarderMulti ?? self.stockBoarderMulti
            self.timeScope = timeScope ?? self.timeScope
            self.stringData = stringData ?? self.stringData
            self.isLoading = isLoading ?? self.isLoading
            self.dummy = dummy ?? self.dummy
            return self
        }
    }
    
    deinit {
        cancelInfo?.cancel()
        cancelSupplysAndDemands?.cancel()
        cancelInfo = nil
        cancelSupplysAndDemands = nil
    }
}

