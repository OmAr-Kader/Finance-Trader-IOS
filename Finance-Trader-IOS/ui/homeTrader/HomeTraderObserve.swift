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
                        let nativeStocks: [StockData] = stockInfos.toHomeStockData(it.value.toStockData())
                        let stocks = nativeStocks.map { it in
                            it.splitStock(timeScope: it.timeScope)
                        }
                        self.scope.launchMain {
                            withAnimation {
                                self.state = self.state.copy(stocks: stocks, nativeStocks: nativeStocks, isLoading: false, dummy: self.state.dummy + 1)
                            }
                        }
                    }
                }
            }
        }
    }
  
    @MainActor
    func loadStockMode(index: Int, mode: ChartMode) {
        let state = state
        guard let stock: StockData = state.stocks[safe: index] else {
            return
        }
        self.state = self.state.copy(stocks: state.stocks.updateStocks(index, stock.copy(isLoading: true)), dummy: self.state.dummy + 1)
        
        self.scope.launchRealm {
            guard let nativeStock: StockData = state.nativeStocks.first(where: { it in it.stockId == stock.stockId }) else {
                return
            }
            let _newNativeStock = switch mode {
            case .StockWave: nativeStock.loadWave()
            case .StockSMA: nativeStock.loadSMA()
            case .StockEMA: nativeStock.loadEMA()
            case .StockRSI: nativeStock.loadRSI()
            case .StockTrad: nativeStock.loadTrad()
            case .StockPrediction: nativeStock.loadPrediction()
            }
            let newNativeStocks = state.nativeStocks.updateStocks(index, _newNativeStock)
            let newStocks = state.stocks.updateStocks(index, _newNativeStock.splitStock(timeScope: stock.timeScope))
            self.scope.launchMain {
                self.state = self.state.copy(stocks: newStocks, nativeStocks: newNativeStocks, dummy: self.state.dummy + 1)
            }
        }
    }
    
    @MainActor
    func loadTimeScope(index: Int, timeScope: Int64) {
        let state = state
        self.scope.launchRealm {
            print(String(index) + "   " + String(timeScope))
            guard let stock: StockData = state.stocks[safe: index] else {
                return
            }
            guard let nativeStock: StockData = state.nativeStocks.first(where: { it in it.stockId == stock.stockId }) else {
                return
            }
            let newStock = nativeStock.splitStock(timeScope: timeScope).copy(timeScope: timeScope)
            let newStocks = state.stocks.updateStocks(index, newStock)
            self.scope.launchMain {
                self.state = self.state.copy(stocks: newStocks, dummy: self.state.dummy + 1)
            }
        }
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
                        let nativeMyStocks: [StockData] = stockInfos.toHomeStockData(it.value.toStockData())
                        let myStocks = nativeMyStocks.map { it in
                            it.splitStock(timeScope: it.timeScope)
                        }
                        self.scope.launchMain {
                            withAnimation {
                                self.state = self.state.copy(myStocks: myStocks, nativeMyStocks: nativeMyStocks, isLoading: false, dummy: self.state.dummy + 1)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func loadMyStockMode(index: Int, mode: ChartMode) {
        let state = state
        guard let myStock: StockData = state.myStocks[safe: index] else {
            return
        }
        self.state = self.state.copy(myStocks: state.myStocks.updateStocks(index, myStock.copy(isLoading: true)), dummy: self.state.dummy + 1)
        
        self.scope.launchRealm {
            guard let nativeMyStock: StockData = state.nativeMyStocks.first(where: { it in it.stockId == myStock.stockId }) else {
                return
            }
            let _newNativeMyStock = switch mode {
            case .StockWave: nativeMyStock.loadWave()
            case .StockSMA: nativeMyStock.loadSMA()
            case .StockEMA: nativeMyStock.loadEMA()
            case .StockRSI: nativeMyStock.loadRSI()
            case .StockTrad: nativeMyStock.loadTrad()
            case .StockPrediction: nativeMyStock.loadPrediction()
            }
            let newNativeMyStocks = state.nativeMyStocks.updateStocks(index, _newNativeMyStock)
            let newmyStocks = state.myStocks.updateStocks(index, _newNativeMyStock.splitStock(timeScope: myStock.timeScope))
            self.scope.launchMain {
                self.state = self.state.copy(myStocks: newmyStocks, nativeMyStocks: newNativeMyStocks, dummy: self.state.dummy + 1)
            }
        }
    }
    
    
    @MainActor
    func loadMyTimeScope(index: Int, timeScope: Int64) {
        let state = state
        self.scope.launchRealm {
            print(String(index) + "   " + String(timeScope))
            guard let stock: StockData = state.myStocks[safe: index] else {
                return
            }
            guard let nativeMyStock: StockData = state.nativeMyStocks.first(where: { it in it.stockId == stock.stockId }) else {
                return
            }
            let newMyStock = nativeMyStock.splitStock(timeScope: timeScope).copy(timeScope: timeScope)
            let newMyStocks = state.myStocks.updateStocks(index, newMyStock)
            self.scope.launchMain {
                self.state = self.state.copy(stocks: newMyStocks, dummy: self.state.dummy + 1)
            }
        }
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
        var nativeStocks: [StockData] = []
        var myStocks: [StockData] = []
        var nativeMyStocks: [StockData] = []
        var isLoading: Bool = false
        var selectedIndex: Int = 1

        var supplyStockId: String = ""
        var isAddSheet: Bool = false

        var dummy: Int = 1

        mutating func copy(
            stocks: [StockData]? = nil,
            nativeStocks: [StockData]? = nil,
            myStocks: [StockData]? = nil,
            nativeMyStocks: [StockData]? = nil,
            selectedIndex: Int? = nil,
            isLoading: Bool? = nil,
            supplyStockId: String? = nil,
            isAddSheet: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.stocks = stocks ?? self.stocks
            self.nativeStocks = nativeStocks ?? self.nativeStocks
            self.myStocks = myStocks ?? self.myStocks
            self.nativeMyStocks = nativeMyStocks ?? self.nativeMyStocks
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
