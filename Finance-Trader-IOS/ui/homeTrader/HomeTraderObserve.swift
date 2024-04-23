import Foundation
import SwiftUI

class HomeTraderObserve : ObservableObject {
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    @MainActor
    func onPageSelected(_ it: Int) {
        state = state.copy(selectedIndex: it)
    }

    func loadData(_ it: Int) {
        switch  it {
        case 0: ()
        case 1: loadStocks()
        default: ()
        }
    }
    
    private func loadStocks() {
        scope.launchRealm {
            let stocksMutli: [StockData] = [StockData.temp(name: "SPY"), StockData.temp(name: "CMP")]
            let stocksWave: [StockData] = [StockData.temp(name: "SPY")]
            stocksMutli.minAndMaxValues { stockBoarderMulti in
                stocksWave.minAndMaxValues { stockBoarderWave in
                    self.scope.launchMain {
                        self.state = await self.state.copy(
                            stocksMutli: stocksMutli,
                            stocksWave: stocksWave,
                            stockBoarderMulti: stockBoarderMulti,
                            stockBoarderWave: stockBoarderWave,
                            grad: stocksWave.first?.values.gradientCreator(stockBoarderWave)
                        )
                    }
                } failed: {
                    
                }
            } failed: {

            }
        }
    }

    
    struct State {
        var stocksMutli: [StockData] = []
        var stocksWave: [StockData] = []
        var stockBoarderMulti: StockBoarder = StockBoarder(minX: 0, maxX: 0, minY: 0, maxY: 0)
        var stockBoarderWave: StockBoarder = StockBoarder(minX: 0, maxX: 0, minY: 0, maxY: 0)
        var ss: KeyValuePairs<String, LinearGradient> = [:]
        var grad: Gradient = Gradient(stops: [])
        
        var isLoading: Bool = false
        var selectedIndex: Int = 1
        
        mutating func copy(
            stocksMutli: [StockData]? = nil,
            stocksWave: [StockData]? = nil,
            selectedIndex: Int? = nil,
            stockBoarderMulti: StockBoarder? = nil,
            stockBoarderWave: StockBoarder? = nil,
            ss: KeyValuePairs<String, LinearGradient>? = nil,
            grad: Gradient? = nil,
            isLoading: Bool? = nil
        ) -> Self {
            self.stocksMutli = stocksMutli ?? self.stocksMutli
            self.stocksWave = stocksWave ?? self.stocksWave
            self.selectedIndex = selectedIndex ?? self.selectedIndex
            self.stockBoarderMulti = stockBoarderMulti ?? self.stockBoarderMulti
            self.stockBoarderWave = stockBoarderWave ?? self.stockBoarderWave
            self.ss = ss ?? self.ss
            self.grad = grad ?? self.grad
            self.isLoading = isLoading ?? self.isLoading
            return self
        }
    }
}
