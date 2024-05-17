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
            state.stocksInfo.ifEmpty {
                loadStocksInfoSearch()
            }
        } else if it == 1 {
            state.stocks.ifEmpty {
                loadStocks()
            }
        } else if it == 2 {
            state.myStocks.ifEmpty {
                loadMyStocks(traderId: traderId)
            }
        } else if it == 3 {
            loadAllArticles()
        }
    }
    
    @MainActor
    func loadStocks() {
        loadingStatus(true)
        self.scope.launchRealm {
            self.cancelAllLive?.cancel()
            self.cancelAllLive = await self.project.stockInfo.getAllStockInfoLive { it in
                it.toHomeStockData().supplyBack { nativeStocks in
                    nativeStocks.map { it in
                        it.splitStock(timeScope: it.timeScope).loadWave()
                    }.supplyBack { stocks in
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
    func loadMyStocks(traderId: String) {
        loadingStatus(true)
        self.scope.launchRealm {
            self.cancelAllLive?.cancel()
            self.cancelAllLive = await self.project.stockInfo.getTraderStocksInfoLive(traderId: traderId) { it in
                it.toHomeStockData().supplyBack { nativeMyStocks in
                    nativeMyStocks.map { it in
                        it.splitStock(timeScope: it.timeScope)
                    }.supplyBack { myStocks in
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
    func loadStocksInfoSearch() {
        self.state = self.state.copy(isLoading: true)
        self.scope.launchRealm {
            self.cancelAllLive?.cancel()
            self.cancelAllLive = await self.project.stockInfo.getAllStockInfoLive { it in
                it.toStockInfoData().supplyBack { stockInfos in
                    self.scope.launchMain {
                        withAnimation {
                            self.state = self.state.copy(stocksInfo: stockInfos, stocksSearch: stockInfos, isLoading: false)
                        }
                    }
                }
            }
        }
    }
  
    @MainActor
    func loadStockMode(index: Int, mode: ChartMode) {
        state.supply { state in
            state.stocks[safe: index]?.supply { stock in
                self.state = self.state.copy(stocks: state.stocks.updateStocks(index, stock.copy(isLoading: true)), dummy: self.state.dummy + 1)
                self.scope.launchRealm {
                    let newStocks = state.stocks.changeStockMode(index: index, mode: mode)
                    self.scope.launchMain {
                        self.state = self.state.copy(stocks: newStocks, dummy: self.state.dummy + 1)
                    }
                }
            }
        }
    }
    
    
    @MainActor
    func loadTimeScope(index: Int, timeScope: Int64) {
        state.supply { state in
            self.scope.launchRealm {
                state.stocks.changeTimeScope(nativeStocks: state.nativeStocks, index: index, timeScope: timeScope).supplyBack { newStocks in
                    self.scope.launchMain {
                        self.state = self.state.copy(stocks: newStocks, dummy: self.state.dummy + 1)
                    }
                }
            }
        }
    }
    
    @MainActor
    func loadMyStockMode(index: Int, mode: ChartMode) {
        state.supply { state in
            state.myStocks[safe: index]?.supply { myStock in
                self.state = self.state.copy(myStocks: state.myStocks.updateStocks(index, myStock.copy(isLoading: true)), dummy: self.state.dummy + 1)
                self.scope.launchRealm {
                    let newMyStocks = state.myStocks.changeStockMode(index: index, mode: mode)
                    self.scope.launchMain {
                        self.state = self.state.copy(myStocks: newMyStocks, dummy: self.state.dummy + 1)
                    }
                }
            }
        }
    }
    
    @MainActor
    func loadMyTimeScope(index: Int, timeScope: Int64) {
        state.supply { state in
            self.scope.launchRealm {
                state.myStocks.changeTimeScope(nativeStocks: state.nativeMyStocks, index: index, timeScope: timeScope).supply { newMyStocks in
                    self.scope.launchMain {
                        self.state = self.state.copy(myStocks: newMyStocks, dummy: self.state.dummy + 1)
                    }
                }
            }
        }
        
    }
    
    @MainActor
    func createSupply(isSupply: Bool, traderId: String, stockId: String, shares: Int64, price: Float64, invoke: @escaping @MainActor () -> (), failed: @escaping @MainActor () -> ()) {
        loadingStatus(true)
        self.scope.launchRealm {
            await self.project.stockInfo.getStockInfo(id: stockId) { it in
                it.value.letBack { stockInfo in
                    self.scope.launchRealm {
                        await self.project.supplyDemand.insertSupplyDemand(
                            SupplyDemand(
                                supplyDemandData: SupplyDemandData(id: "", isSupply: isSupply, traderId: traderId, stockId: stockId, shares: shares, price: price), stockInfo: stockInfo
                            )
                        ) { it in
                            it?.supplyBack { _ in
                                self.scope.launchMain {
                                    self.loadingStatus(false)
                                    invoke()
                                }
                            } ?? {
                                self.scope.launchMain {
                                    self.loadingStatus(false)
                                    failed()
                                }
                            }()
                        }
                    }
                } ?? self.loadingStatus(false)
            }
        }
    }
    
    @MainActor
    func loadAllArticles() {
        loadingStatus(true)
        self.scope.launchRealm {
            self.cancelAllLive?.cancel()
            self.cancelAllLive = await self.project.article.getAllArticlesLive { it in
                it?.toArticleData().sorted { it, it1 in
                    it.releasedDate < it1.releasedDate
                }.supply { articles in
                    self.scope.launchMain {
                        self.state = self.state.copy(articles: articles, isLoading: false)
                    }
                } ?? self.loadingStatus(false)
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
        self.state.supply { state in
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
    
    struct State : ScopeFunc {
        var stocks: [StockData] = []
        var nativeStocks: [StockData] = []
        var myStocks: [StockData] = []
        var nativeMyStocks: [StockData] = []
        var stocksInfo: [StockInfoData] = []
        var stocksSearch: [StockInfoData] = []

        var articles: [ArticleData] = []

        var isSearch: Bool = false
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

