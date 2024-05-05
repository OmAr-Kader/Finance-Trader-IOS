import Foundation

class ListingStockObserve : ObservableObject {
    
    @Inject
    private var project: Project
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    @MainActor
    func loadData(stockInfo: StockInfoData? = nil) {
        // Load All StockInfoData Names And Symbols to not conflict with the new Name
        self.state = self.state.copy(stockInfo: stockInfo)
    }
    
    @MainActor
    func createStock(name: String, symbol: String, share: Int64, pri: Float64, traderId: String, invoke: @escaping () -> (), failed: @escaping () -> ()) {
        loadingStatus(true)
        let stockInfo = state.stockInfo
        self.scope.launchRealm {
            let stockInfoData = StockInfoData(
                id: "",
                logoUrl: "",
                symbol: stockInfo.symbol,
                name: stockInfo.symbol,
                isGain: true,
                numberOfShares: stockInfo.numberOfShares,
                stockPrice: stockInfo.stockPrice,
                stockholders: [StockHolderData(holderId: traderId, holderShares: stockInfo.numberOfShares)]
            )
            await self.project.stockInfo.insertStockInfo(StockInfo(stockInfoData: stockInfoData)) { it in
                guard let it else {
                    failed()
                    self.loadingStatus(false)
                    return
                }
                invoke()
            }
        }
    }
    
    @MainActor
    func editStock(name: String, symbol: String, share: Int64, pri: Float64, traderId: String, stockInfoData: StockInfoData, invoke: @escaping () -> (), failed: @escaping () -> ()) {
        loadingStatus(true)
        self.scope.launchRealm {
            var _stockInfoData = stockInfoData
            _stockInfoData.name = name
            _stockInfoData.symbol = symbol
            _stockInfoData.numberOfShares = share
            _stockInfoData.stockPrice = pri
            let stockInfo = _stockInfoData
            guard let it = await self.project.stockInfo.updateSession(stockInfoData: stockInfoData).value else {
                failed()
                self.loadingStatus(false)
                return
            }
            invoke()
        }
    }

    private func loadingStatus(_ it: Bool) {
        self.scope.launchMain {
            self.state = self.state.copy(isLoading: it)
        }
    }
    
    struct State {
        
        var stockInfo: StockInfoData = StockInfoData()
        var names: [String] = []
        var symbols: [String] = []
        var isLoading: Bool = false

        var dummy: Int = 1

        mutating func copy(
            stockInfo: StockInfoData? = nil,
            names: [String]? = nil,
            symbols: [String]? = nil,
            isLoading: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.stockInfo = stockInfo ?? self.stockInfo
            self.names = names ?? self.names
            self.symbols = symbols ?? self.symbols
            self.isLoading = isLoading ?? self.isLoading
            self.dummy = dummy ?? self.dummy
            return self
        }
    }
}
