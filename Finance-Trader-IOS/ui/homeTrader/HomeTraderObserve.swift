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
    func loadData(_ it: Int, mode: ChartMode) {
        switch  it {
        case 0: ()
        case 1: loadStocks(mode: mode)
        case 2: ()
        default: ()
        }
    }
    
    @MainActor
    func loadStocks(mode: ChartMode) {
        state = state.copy(
            stocks: mode != state.mode ? [] : state.stocks,
            stock: mode != state.mode ? StockData() : state.stock,
            mode: mode,
            isLoading: true
        )
        scope.launchRealm {
            switch mode {
            case .StockWave: await self.loadWave(mode: mode)
            case .StockMulti: await self.loadMulti(mode: mode)
            case .StockSMA: await self.loadSMA(mode: mode)
            case .StockEMA: await self.loadEMA(mode: mode)
            case .StockRSI: await self.loadRSI(mode: mode)
            case .StockTrad: await self.loadTrad(mode: mode)
            case .StockPrediction: await self.loadPrediction(mode: mode)
            }
        }
    }
    
    @BackgroundActor
    private func loadWave(mode: ChartMode) async {
        let stockWave = StockData.temp(symbol: "SPY").injectStatus(mode: mode)
        stockWave.values.minAndMaxValues(mode) { stockBoarderWave in
            let gradient = stockWave.values.gradientCreator(stockBoarderWave, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockWave, stockBoarder: stockBoarderWave, mode: mode, gradient: gradient, isLoading: false)
            }
        } failed: {}
    }
    
    @BackgroundActor
    private func loadMulti(mode: ChartMode) async {
        let stock1 = StockData.temp(symbol: "SPY").injectStatus(mode: mode)
        let stock2 = StockData.temp(symbol: "IBM").injectStatus(mode: mode)
        let stockMulti = [stock1, stock2].injectColor()
        stockMulti.minAndMaxValues(mode) { stockBoarderMulti in
            self.scope.launchMain {
                self.state = self.state.copy(stocks: stockMulti, stockBoarder: stockBoarderMulti, mode: mode, isLoading: false)
            }
        } failed: {}
    }
    
    @BackgroundActor
    private func loadSMA(mode: ChartMode) async {
        let stockSMA = StockData.temp(symbol: "SPY").injectSMA().injectStatus(mode: mode)
        stockSMA.values.minAndMaxValues(mode) { stockBoarderSMA in
            let gradient = stockSMA.values.gradientCreator(stockBoarderSMA, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockSMA, stockBoarder: stockBoarderSMA, mode: mode, gradient: gradient, isLoading: false)
            }
        } failed: {}
    }
    
    @BackgroundActor
    private func loadEMA(mode: ChartMode) async {
        let stockEMA = StockData.temp(symbol: "SPY").injectEMA().injectStatus(mode: mode)
        stockEMA.values.minAndMaxValues(mode) { stockBoarderEMA in
            let gradient = stockEMA.values.gradientCreator(stockBoarderEMA, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockEMA, stockBoarder: stockBoarderEMA, mode: mode, gradient: gradient, isLoading: false)
            }
        } failed: {}
    }
    
    @BackgroundActor
    private func loadRSI(mode: ChartMode) async {
        let stockRSI = StockData.temp(symbol: "SPY").injectRSI().injectStatus(mode: mode)
        stockRSI.values.minAndMaxValues(mode) { stockBoarderRSI in
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockRSI, stockBoarder: StockBoarder(minX: stockBoarderRSI.minX, maxX: stockBoarderRSI.maxX, minY: 0, maxY: 100), mode: mode, isLoading: false)
            }
        } failed: {}
    }
    
    @BackgroundActor
    private func loadTrad(mode: ChartMode) async {
        let stockTrad = StockData.temp(symbol: "SPY").injectStatus(mode: mode)
        stockTrad.values.minAndMaxValues(mode) { stockBoarderTrad in
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockTrad, stockBoarder: stockBoarderTrad, mode: mode, isLoading: false)
            }
        } failed: {}
    }
    
    
    @BackgroundActor
    private func loadPrediction(mode: ChartMode) async {
        let stockPred = StockData.temp(symbol: "SPY", start: 0, end: 30).injectStatus(mode: mode)
        let _stockPrediction = StockData.temp(symbol: "SPY", start: 30, end: 40).injectStatus(mode: mode)
        let stockMulti = [stockPred, _stockPrediction]
        stockPred.values.minAndMaxValues(mode) { stockBoarderPred in
            _stockPrediction.values.minAndMaxValues(mode) { stockBoarderPredictions in
                stockMulti.minAndMaxValues(mode) { both in
                    let gradient = stockPred.values.gradientCreator(stockBoarderPred, mode: mode)
                    let gradientPred = _stockPrediction.values.gradientCreator(stockBoarderPredictions, mode: mode)
                    let stockPrediction = _stockPrediction.injectConnectPoint(stockPred.values.last!) // Not Before For Correctly Gradient Creation
                    self.scope.launchMain {
                        self.state = self.state.copy(stock: stockPred, stockPrediction: stockPrediction, stockBoarder: both, mode: mode, gradient: gradient, gradientPred: gradientPred, isLoading: false)
                    }
                } failed: {}
            } failed: {}
        } failed: {}
    }
    
    struct State {
        var stocks: [StockData] = []
        var stock: StockData = StockData()
        var stockPrediction: StockData = StockData()

        var stockBoarder: StockBoarder = StockBoarder()
        
        var gradient: Gradient = Gradient(stops: [])
        var gradientPred: Gradient = Gradient(stops: [])

        var isLoading: Bool = false
        var selectedIndex: Int = 1
        var mode: ChartMode = ChartMode.StockWave
        
        mutating func copy(
            stocks: [StockData]? = nil,
            stock: StockData? = nil,
            stockPrediction: StockData? = nil,
            stockBoarder: StockBoarder? = nil,
            selectedIndex: Int? = nil,
            mode: ChartMode? = nil,
            gradient: Gradient? = nil,
            gradientPred: Gradient? = nil,
            isLoading: Bool? = nil
        ) -> Self {
            self.stocks = stocks ?? self.stocks
            self.stock = stock ?? self.stock
            self.stockPrediction = stockPrediction ?? self.stockPrediction
            self.stockBoarder = stockBoarder ?? self.stockBoarder
            self.selectedIndex = selectedIndex ?? self.selectedIndex
            self.mode = mode ?? self.mode
            self.gradient = gradient ?? self.gradient
            self.gradientPred = gradientPred ?? self.gradientPred
            self.isLoading = isLoading ?? self.isLoading
            return self
        }
    }
}
