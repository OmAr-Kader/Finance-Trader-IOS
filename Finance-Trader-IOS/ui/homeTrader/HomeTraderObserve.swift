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
            var _stocks: [StockData] = []
            for i in 0...10 {
                let stockInfo = StockInfoData.temp()
                let _stock = StockData.temp(id: String(i), symbol: stockInfo.symbol).injectLastPrice(price: stockInfo.stockPrice, isGain: stockInfo.isGain)
                let stock = await self.loadWave(_stock, mode: ChartMode.StockWave)
                _stocks.append(stock)
            }
            let stocks = _stocks
            self.scope.launchMain {
                self.state = self.state.copy(stocks: stocks, isLoading: false, dummy: self.state.dummy + 1)
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
            case .StockWave: await self.loadWave(stock, mode: mode)
            case .StockSMA: await self.loadSMA(stock, mode: mode)
            case .StockEMA: await self.loadEMA(stock, mode: mode)
            case .StockRSI: await self.loadRSI(stock, mode: mode)
            case .StockTrad: await self.loadTrad(stock, mode: mode)
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
    private func loadWave(_ stock: StockData, mode: ChartMode) async -> StockData {
        let _stockWave = stock.injectStatus(mode: mode)
        guard let stockBoarderWave = _stockWave.values.minAndMaxValues(mode) else {
            return stock
        }
        let gradient = _stockWave.values.gradientCreator(stockBoarderWave, mode: mode)
        return _stockWave.injectGradient(gradient: gradient).injectMode(mode: mode).injectStockBoarder(stockBoarder: stockBoarderWave)
    }
    
    @BackgroundActor
    private func loadSMA(_ stock: StockData, mode: ChartMode) async -> StockData {
        let _stockSMA = stock.injectSMA().injectStatus(mode: mode)
        guard let stockBoarderSMA = _stockSMA.values.minAndMaxValues(mode) else {
            return stock
        }
        let gradient = _stockSMA.values.gradientCreator(stockBoarderSMA, mode: mode)
        return _stockSMA.injectGradient(gradient: gradient).injectMode(mode: mode).injectStockBoarder(stockBoarder: stockBoarderSMA)
    }
    
    @BackgroundActor
    private func loadEMA(_ stock: StockData, mode: ChartMode) async -> StockData {
        let _stockEMA = stock.injectEMA().injectStatus(mode: mode)
        guard let stockBoarderEMA = _stockEMA.values.minAndMaxValues(mode) else {
            return stock
        }
        let gradient = _stockEMA.values.gradientCreator(stockBoarderEMA, mode: mode)
        return _stockEMA.injectGradient(gradient: gradient).injectMode(mode: mode).injectStockBoarder(stockBoarder: stockBoarderEMA)
    }
    
    @BackgroundActor
    private func loadRSI(_ stock: StockData, mode: ChartMode) async -> StockData {
        let _stockRSI = stock.injectRSI().injectStatus(mode: mode)
        guard let stockBoarderRSI = _stockRSI.values.minAndMaxValues(mode) else {
            return stock
        }
        return _stockRSI.injectMode(mode: mode).injectStockBoarder(stockBoarder: StockBoarder(minX: stockBoarderRSI.minX, maxX: stockBoarderRSI.maxX, minY: 0, maxY: 100))
    }
    
    @BackgroundActor
    private func loadTrad(_ stock: StockData, mode: ChartMode) async -> StockData {
        let _stockTrad = stock.injectStatus(mode: mode)
        guard let stockBoarderTrad = _stockTrad.values.minAndMaxValues(mode) else {
            return stock
        }
        return _stockTrad.injectMode(mode: mode).injectStockBoarder(stockBoarder: stockBoarderTrad)
    }
    
    
    @BackgroundActor
    private func loadPrediction(_ stock: StockData, mode: ChartMode) async -> StockData {
        let stockPred = stock.injectStatus(mode: mode).injectPredictions().injectPredictionStatus(mode: mode)
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
