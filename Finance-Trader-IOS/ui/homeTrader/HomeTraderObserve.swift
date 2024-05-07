import Foundation
import SwiftUI

class HomeTraderObserve : ObservableObject {
    
    private var scope = Scope()

    @Inject
    private var project: Project
    
    @MainActor
    @Published var state = State()
    
    @MainActor
    func onPageSelected(_ it: Int) {
        state = state.copy(selectedIndex: it)
    }
    
    @MainActor
    func loadData(_ it: Int) {
        if it == 0 {
        } else if it == 1 {
            if state.stocks.isEmpty {
                loadStocks()
            }
        } else if it == 2 {
        }
    }
    
    @MainActor
    func loadStocks() {
        state = state.copy(
            isLoading: true
        )
        self.scope.launchRealm {
            await self.project.stockInfo.getAllStockInfo { it in
                let stockInfos = it.value.toStockInfoData()
                /*let ids = stockInfos.map { it in
                    it.id
                }*/
                /*self.scope.launchRealm {
                    await self.project.stockSession.getStocksSessions(
                        stockId: ids,
                        stringData: []
                    ) { it in
                        
                    }
                }*/
                let stocks: [StockData] = stockInfos.toHomeStockData([])
                self.scope.launchMain {
                    self.state = self.state.copy(stocks: stocks, isLoading: false, dummy: self.state.dummy + 1)
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
            case .StockPrediction: await self.loadPrediction(stock, mode: mode)
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
    
    
    @BackgroundActor
    private func loadPrediction(_ stock: StockData, mode: ChartMode) async -> StockData {
        let stockPred = stock.injectStatus(mode: mode).injectPredictions(predictions: []).injectPredictionStatus(mode: mode)
        let stockMulti = [stockPred.values, stockPred.valuesPrediction]
        guard let stockBoarderPred = stockPred.values.minAndMaxValues(mode)  else {
            return stock
        }
        guard let stockBoarderPredictions = stockPred.valuesPrediction.minAndMaxValues(mode) else {
            return stock
        }
        guard let both = stockMulti.minAndMaxValues(mode) else {
            return stock
        }
        let gradient = stockPred.values.gradientCreator(stockBoarderPred, mode: mode)
        let gradientPred = stockPred.valuesPrediction.gradientCreator(stockBoarderPredictions, mode: mode)
        return stockPred.injectGradient(gradient: gradient)
            .injectGradientPredictions(gradientPred: gradientPred)
            .injectConnectPredictionPoint(stockPred.values.last!)
            .injectMode(mode: mode)
            .injectStockBoarder(stockBoarder: both)
    }
    
    struct State {
        var stocks: [StockData] = []
        var isLoading: Bool = false
        var selectedIndex: Int = 1

        var dummy: Int = 1

        mutating func copy(
            stocks: [StockData]? = nil,
            selectedIndex: Int? = nil,
            isLoading: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.stocks = stocks ?? self.stocks
            self.selectedIndex = selectedIndex ?? self.selectedIndex
            self.isLoading = isLoading ?? self.isLoading
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

}
