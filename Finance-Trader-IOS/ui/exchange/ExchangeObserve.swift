import Foundation

class ExchangeObserve : ObservableObject {
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    
    struct State {
        var stock: StockData = StockData()
        var stockPrediction: StockData = StockData()

        var isLoading: Bool = false
        
        mutating func copy(
            stock: StockData? = nil,
            stockPrediction: StockData? = nil,
            isLoading: Bool? = nil
        ) -> Self {
            self.stock = stock ?? self.stock
            self.stockPrediction = stockPrediction ?? self.stockPrediction
            self.isLoading = isLoading ?? self.isLoading
            return self
        }
    }

}
