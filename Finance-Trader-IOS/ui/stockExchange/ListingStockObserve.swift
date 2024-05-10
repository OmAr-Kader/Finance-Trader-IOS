import Foundation
import SwiftUI

class ListingStockObserve : ObservableObject {
    
    @Inject
    private var project: Project
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    @MainActor
    func loadData(stockInfo: StockInfoData? = nil) {
        self.state = self.state.copy(isLoading: true)
        self.scope.launchRealm {
            await self.project.stockInfo.getAllStockInfo { it in
                let names = it.value.map { it in
                    it.name
                }
                let symbols = it.value.map { it in
                    it.symbol
                }
                self.scope.launchMain {
                    withAnimation {
                        self.state = self.state.copy(stockInfo: stockInfo, names: names, symbols: symbols, isLoading: false)
                    }
                }
            }
        }
    }
    
    @MainActor
    func createStock(name: String, symbol: String, share: String, pri: String, traderId: String, invoke: @escaping @MainActor () -> (), failed: @escaping @MainActor () -> ()) {
        if name.isEmpty || symbol.isEmpty{
            withAnimation {
                self.state = self.state.copy(isPressed: true)
            }
            return
        }
        guard let share = Int64(share) else {
            withAnimation {
                self.state = self.state.copy(isPressed: true)
            }
            return
        }
        guard let pri = Float64(pri) else {
            withAnimation {
                self.state = self.state.copy(isPressed: true)
            }
            return
        }
        loadingStatus(true)
        self.scope.launchRealm {
            let stockInfoData = StockInfoData(
                id: "",
                logoUrl: "",
                symbol: symbol,
                name: name,
                isGain: true,
                numberOfShares: share,
                stockPrice: pri,
                stockholders: [StockHolderData(holderId: traderId, holderShares: share)]
            )
            await self.project.stockInfo.insertStockInfo(StockInfo(stockInfoData: stockInfoData)) { it in
                guard it != nil else {
                    self.scope.launchMain {
                        failed()
                    }
                    self.loadingStatus(false)
                    return
                }
                self.scope.launchMain {
                    invoke()
                }
            }
        }
    }
    
    @MainActor
    func editStock(name: String, symbol: String, share: String, pri: String, traderId: String, stockInfoData: StockInfoData, invoke: @escaping @MainActor () -> (), failed: @escaping @MainActor () -> ()) {
        if name.isEmpty || symbol.isEmpty{
            withAnimation {
                self.state = self.state.copy(isPressed: true)
            }
            return
        }
        guard let share = Int64(share) else {
            withAnimation {
                self.state = self.state.copy(isPressed: true)
            }
            return
        }
        guard let pri = Float64(pri) else {
            withAnimation {
                self.state = self.state.copy(isPressed: true)
            }
            return
        }
        loadingStatus(true)
        self.scope.launchRealm {
            var _stockInfoData = stockInfoData
            _stockInfoData.name = name
            _stockInfoData.symbol = symbol
            _stockInfoData.numberOfShares = share
            _stockInfoData.stockPrice = pri
            let stockInfo = _stockInfoData
            guard (await self.project.stockInfo.updateSession(stockInfoData: stockInfo).value) != nil else {
                self.scope.launchMain {
                    failed()
                }
                self.loadingStatus(false)
                return
            }
            self.scope.launchMain {
                invoke()
            }
        }
    }

    private func loadingStatus(_ it: Bool) {
        self.scope.launchMain {
            withAnimation {
                self.state = self.state.copy(isLoading: it)
            }
        }
    }
    
    @MainActor
    func checkIsPressed() {
        if self.state.isPressed {
            self.state = self.state.copy(isPressed: false)
        }
    }
    
    struct State {
        
        var stockInfo: StockInfoData = StockInfoData()
        var names: [String] = []
        var symbols: [String] = []
        var isLoading: Bool = false
        var isPressed: Bool = false

        var dummy: Int = 1

        mutating func copy(
            stockInfo: StockInfoData? = nil,
            names: [String]? = nil,
            symbols: [String]? = nil,
            isLoading: Bool? = nil,
            isPressed: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.stockInfo = stockInfo ?? self.stockInfo
            self.names = names ?? self.names
            self.symbols = symbols ?? self.symbols
            self.isLoading = isLoading ?? self.isLoading
            self.isPressed = isPressed ?? self.isPressed
            self.dummy = dummy ?? self.dummy
            return self
        }
    }
}
