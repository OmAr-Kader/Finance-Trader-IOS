import Foundation
import SwiftUI
import Combine

class HomeTraderObserve : ObservableObject {
    
    private var scope = Scope()

    @Inject
    private var project: Project
    
    @MainActor
    @Published var state = State()
    
    private var cancelAllLive: AnyCancellable? = nil
    
    @MainActor
    func onPageSelected(_ it: Int) {
        state = state.copy(selectedIndex: it)
    }
    
    @MainActor
    func loadData(_ it: Int, traderId: String) {
        if it == 0 {
        } else if it == 1 {
            if state.stocks.isEmpty {
                loadStocks()
            }
        } else if it == 2 {
            if state.myStocks.isEmpty {
                loadMyStocks(traderId: traderId)
            }
        }
    }
    
    @MainActor
    func loadStocks() {
        self.state = self.state.copy(isLoading: true)
        self.scope.launchRealm {
            self.cancelAllLive?.cancel()
            self.cancelAllLive = await self.project.stockInfo.getAllStockInfoLive { it in
                let stockInfos = it.toStockInfoData()
                let ids = stockInfos.map { it in
                    it.id
                }
                self.scope.launchRealm {
                    await self.project.stockSession.getAllStocksSessions(
                        stockId: ids
                    ) { it in
                        let stocks: [StockData] = stockInfos.toHomeStockData(it.value.toStockData())
                        self.scope.launchMain {
                            withAnimation {
                                self.state = self.state.copy(stocks: stocks, isLoading: false, dummy: self.state.dummy + 1)
                            }
                        }
                    }
                }
            }
        }
    }
  
    @MainActor
    func loadStockMode(index: Int, mode: ChartMode) {
        guard var _stock: StockData = state.stocks[safe: index] else {
            return
        }
        _stock.isLoading = true
        let stock = _stock
        self.state = self.state.copy(stocks: self.updateStocks(index, stock))
        self.scope.launchRealm {
            let newStock = switch mode {
            case .StockWave: stock.loadWave()
            case .StockSMA: stock.loadSMA()
            case .StockEMA: stock.loadEMA()
            case .StockRSI: stock.loadRSI()
            case .StockTrad: stock.loadTrad()
            case .StockPrediction: stock.loadPrediction()
            }
            self.scope.launchMain {
                self.state = self.state.copy(stocks: self.updateStocks(index, newStock), dummy: self.state.dummy + 1)
            }
        }
    }
    
    @MainActor
    func updateStocks(_ index: Int,_ stockData: StockData) -> [StockData] {
        var stocks = state.stocks
        var _stockData = stockData
        _stockData.isLoading = false
        stocks[index] = _stockData
        return stocks
    }

    @MainActor
    func loadMyStocks(traderId: String) {
        self.state = self.state.copy(isLoading: true)
        self.scope.launchRealm {
            self.cancelAllLive?.cancel()
            self.cancelAllLive = await self.project.stockInfo.getTraderStocksInfoLive(traderId: traderId) { it in
                let stockInfos = it.toStockInfoData()
                let ids = stockInfos.map { it in
                    it.id
                }
                self.scope.launchRealm {
                    await self.project.stockSession.getAllStocksSessions(
                        stockId: ids
                    ) { it in
                        let myStocks: [StockData] = stockInfos.toHomeStockData(it.value.toStockData())
                        self.scope.launchMain {
                            withAnimation {
                                self.state = self.state.copy(myStocks: myStocks, isLoading: false, dummy: self.state.dummy + 1)
                            }
                        }
                    }
                }
            }
        }
    }
  
    @MainActor
    func loadMyStockMode(index: Int, mode: ChartMode) {
        guard var _stock: StockData = state.myStocks[safe: index] else {
            return
        }
        _stock.isLoading = true
        let stock = _stock
        self.state = self.state.copy(stocks: self.updateStocks(index, stock))
        self.scope.launchRealm {
            let newStock = switch mode {
            case .StockWave: stock.loadWave()
            case .StockSMA: stock.loadSMA()
            case .StockEMA: stock.loadEMA()
            case .StockRSI: stock.loadRSI()
            case .StockTrad: stock.loadTrad()
            case .StockPrediction: stock.loadPrediction()
            }
            self.scope.launchMain {
                self.state = self.state.copy(stocks: self.updateStocks(index, newStock), dummy: self.state.dummy + 1)
            }
        }
    }
    
    @MainActor
    func updateMyStocks(_ index: Int,_ stockData: StockData) -> [StockData] {
        var stocks = state.myStocks
        var _stockData = stockData
        _stockData.isLoading = false
        stocks[index] = _stockData
        return stocks
    }
    
    @MainActor
    func createSupply(isSupply: Bool, traderId: String, stockId: String, shares: Int64, price: Float64, invoke: @escaping @MainActor () -> (), failed: @escaping @MainActor () -> ()) {
        loadingStatus(true)
        self.scope.launchRealm {
            await self.project.supplyDemand.insertSupplyDemand(
                SupplyDemand(supplyDemandData: SupplyDemandData(id: "", isSupply: isSupply, traderId: traderId, stockId: stockId, shares: shares, price: price))) { it in
                    self.scope.launchMain {
                        guard it != nil else {
                            self.loadingStatus(false)
                            failed()
                            return
                        }
                        self.loadingStatus(false)
                        invoke()
                    }
                }
        }
    }
    
    @MainActor
    func setAddSheet(_ it: Bool,_ supplyStockId: String) {
        self.state = self.state.copy(supplyStockId: supplyStockId, isAddSheet: it)
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
        var myStocks: [StockData] = []
        var isLoading: Bool = false
        var selectedIndex: Int = 1

        var supplyStockId: String = ""
        var isAddSheet: Bool = false

        var dummy: Int = 1

        mutating func copy(
            stocks: [StockData]? = nil,
            myStocks: [StockData]? = nil,
            selectedIndex: Int? = nil,
            isLoading: Bool? = nil,
            supplyStockId: String? = nil,
            isAddSheet: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.stocks = stocks ?? self.stocks
            self.myStocks = myStocks ?? self.myStocks
            self.selectedIndex = selectedIndex ?? self.selectedIndex
            self.isLoading = isLoading ?? self.isLoading
            self.supplyStockId = supplyStockId ?? self.supplyStockId
            self.isAddSheet = isAddSheet ?? self.isAddSheet
            self.dummy = dummy ?? self.dummy
            return self
        }
    }
    
    /*
    var stocks: [StockData] = []
    var stockBoarderMulti: StockBoarder
     
    StockMultiView(stocks: state.stocks, stockBoarderMulti: state.stockBoarderMulti, isLoading: state.isLoading)
     
    @BackgroundActor
    private func loadMulti(mode: ChartMode) async {
        let stock1 = StockData.temp(id: "1", symbol: "SPY").injectStatus(mode: mode)
        let stock2 = StockData.temp(id: "2", symbol: "IBM").injectStatus(mode: mode)
        let stockMulti = [stock1, stock2].injectColor()
        guard let stockBoarderMulti = stockMulti.minAndMaxValues(mode) else {
            return
        }
    }*/
    
    deinit {
        cancelAllLive?.cancel()
        cancelAllLive = nil
    }

}
