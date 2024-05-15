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
            if state.stocksInfo.isEmpty {
                loadStocksInfoSearch()
            }
        } else if it == 1 {
            if state.stocks.isEmpty {
                loadStocks()
            }
        } else if it == 2 {
            if state.myStocks.isEmpty {
                loadMyStocks(traderId: traderId)
            }
        } else if it == 3 {
            loadAllArticles()
        }
    }
    
    @MainActor
    func loadStocks() {
        self.state = self.state.copy(isLoading: true)
        self.scope.launchRealm {
            self.cancelAllLive?.cancel()
            self.cancelAllLive = await self.project.stockInfo.getAllStockInfoLive { it in
                let nativeStocks: [StockData] = it.toHomeStockData()
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
    
    @MainActor
    func loadMyStocks(traderId: String) {
        self.state = self.state.copy(isLoading: true)
        self.scope.launchRealm {
            self.cancelAllLive?.cancel()
            self.cancelAllLive = await self.project.stockInfo.getTraderStocksInfoLive(traderId: traderId) { it in
                let nativeMyStocks: [StockData] = it.toHomeStockData()
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
    
    
    @MainActor
    func loadStocksInfoSearch() {
        self.state = self.state.copy(isLoading: true)
        self.scope.launchRealm {
            self.cancelAllLive?.cancel()
            self.cancelAllLive = await self.project.stockInfo.getAllStockInfoLive { it in
                let stockInfos = it.toStockInfoData()
                self.scope.launchMain {
                    withAnimation {
                        self.state = self.state.copy(stocksInfo: stockInfos, stocksSearch: stockInfos, isLoading: false)
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
            let new = state.stocks.changeStockMode(nativeStocks: state.nativeStocks, index: index, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(stocks: new.newStocks, nativeStocks: new.newNativeStocks, dummy: self.state.dummy + 1)
            }
        }
    }
    
    
    @MainActor
    func loadTimeScope(index: Int, timeScope: Int64) {
        let state = state
        self.scope.launchRealm {
            let newStocks = state.stocks.changeTimeScope(nativeStocks: state.nativeStocks, index: index, timeScope: timeScope)
            self.scope.launchMain {
                self.state = self.state.copy(stocks: newStocks, dummy: self.state.dummy + 1)
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
            let new = state.myStocks.changeStockMode(nativeStocks: state.nativeMyStocks, index: index, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(myStocks: new.newStocks, nativeMyStocks: new.newNativeStocks, dummy: self.state.dummy + 1)
            }
        }
    }
    
    @MainActor
    func loadMyTimeScope(index: Int, timeScope: Int64) {
        let state = state
        self.scope.launchRealm {
            let newMyStocks = state.myStocks.changeTimeScope(nativeStocks: state.nativeMyStocks, index: index, timeScope: timeScope)
            self.scope.launchMain {
                self.state = self.state.copy(stocks: newMyStocks, dummy: self.state.dummy + 1)
            }
        }
    }
    
    @MainActor
    func createSupply(isSupply: Bool, traderId: String, stockId: String, shares: Int64, price: Float64, invoke: @escaping @MainActor () -> (), failed: @escaping @MainActor () -> ()) {
        loadingStatus(true)
        self.scope.launchRealm {
            await self.project.stockInfo.getStockInfo(id: stockId) { it in
                guard let stockInfo = it.value else {
                    self.loadingStatus(false)
                    return
                }
                self.scope.launchRealm {
                    await self.project.supplyDemand.insertSupplyDemand(
                        SupplyDemand(supplyDemandData: SupplyDemandData(id: "", isSupply: isSupply, traderId: traderId, stockId: stockId, shares: shares, price: price), stockInfo: stockInfo)
                    ) { it in
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
        }
    }
    
    @MainActor
    func loadAllArticles() {
        loadingStatus(true)
        self.scope.launchRealm {
            await self.project.article.getAllArticles { it in
                let articles = it.value.toArticleData().sorted { it, it1 in
                    it.releasedDate < it1.releasedDate
                }
                self.scope.launchMain {
                    self.state = self.state.copy(articles: articles, isLoading: false)
                }
            }
        }
    }
    
    @MainActor
    func setAddSheet(_ it: Bool,_ supplyStockId: String) {
        self.state = self.state.copy(supplyStockId: supplyStockId, isAddSheet: it)
    }
    
    @MainActor
    func setIsSearch() {
        self.state = self.state.copy(isSearch: state.isSearch ? false : true)
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
        var nativeStocks: [StockData] = []
        var myStocks: [StockData] = []
        var nativeMyStocks: [StockData] = []
        var stocksInfo: [StockInfoData] = []
        var stocksSearch: [StockInfoData] = []

        var articles: [ArticleData] = []

        var isSearch: Bool = false
        var isLoading: Bool = false
        var selectedIndex: Int = 3

        var supplyStockId: String = ""
        var isAddSheet: Bool = false

        var dummy: Int = 1

        mutating func copy(
            stocks: [StockData]? = nil,
            nativeStocks: [StockData]? = nil,
            myStocks: [StockData]? = nil,
            nativeMyStocks: [StockData]? = nil,
            stocksInfo: [StockInfoData]? = nil,
            stocksSearch: [StockInfoData]? = nil,
            articles: [ArticleData]? = nil,
            selectedIndex: Int? = nil,
            isLoading: Bool? = nil,
            isSearch: Bool? = nil,
            supplyStockId: String? = nil,
            isAddSheet: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.stocks = stocks ?? self.stocks
            self.nativeStocks = nativeStocks ?? self.nativeStocks
            self.myStocks = myStocks ?? self.myStocks
            self.nativeMyStocks = nativeMyStocks ?? self.nativeMyStocks
            self.stocksInfo = stocksInfo ?? self.stocksInfo
            self.stocksSearch = stocksSearch ?? self.stocksSearch
            self.articles = articles ?? self.articles
            self.selectedIndex = selectedIndex ?? self.selectedIndex
            self.isSearch = isSearch ?? self.isSearch
            self.isLoading = isLoading ?? self.isLoading
            self.supplyStockId = supplyStockId ?? self.supplyStockId
            self.isAddSheet = isAddSheet ?? self.isAddSheet
            self.dummy = dummy ?? self.dummy
            return self
        }
    }
    
    deinit {
        cancelAllLive?.cancel()
        cancelAllLive = nil
    }

}

