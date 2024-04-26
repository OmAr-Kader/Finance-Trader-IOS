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
            stocks: [],
            stock: StockData(),
            mode: mode
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
        let stockWave = StockData.temp(name: "SPY").injectStatus(mode: mode)
        stockWave.values.minAndMaxValues(mode) { stockBoarderWave in
            let gradient = stockWave.values.gradientCreator(stockBoarderWave, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(
                    stock: stockWave,
                    stockBoarder: stockBoarderWave,
                    mode: mode,
                    gradient: gradient
                )
            }
        } failed: {
            
        }
    }
    
    @BackgroundActor
    private func loadMulti(mode: ChartMode) async {
        let stock1 = StockData.temp(name: "SPY").injectStatus(mode: mode)
        let stock2 = StockData.temp(name: "IBM").injectStatus(mode: mode)
        let stockMulti = [stock1, stock2].injectColor()
        stockMulti.minAndMaxValues(mode) { stockBoarderMulti in
            self.scope.launchMain {
                self.state = self.state.copy(
                    stocks: stockMulti,
                    stockBoarder: stockBoarderMulti,
                    mode: mode
                )
            }
        } failed: {
            
        }
    }
    
    @BackgroundActor
    private func loadSMA(mode: ChartMode) async {
        let stockSMA = StockData.temp(name: "SPY").injectSMA().injectStatus(mode: mode)
        stockSMA.values.minAndMaxValues(mode) { stockBoarderSMA in
            let gradient = stockSMA.values.gradientCreator(stockBoarderSMA, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(
                    stock: stockSMA,
                    stockBoarder: stockBoarderSMA,
                    mode: mode,
                    gradient: gradient
                )
            }
        } failed: {
            
        }
    }
    
    @BackgroundActor
    private func loadEMA(mode: ChartMode) async {
        let stockEMA = StockData.temp(name: "SPY").injectEMA().injectStatus(mode: mode)
        stockEMA.values.minAndMaxValues(mode) { stockBoarderEMA in
            let gradient = stockEMA.values.gradientCreator(stockBoarderEMA, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(
                    stock: stockEMA,
                    stockBoarder: stockBoarderEMA,
                    mode: mode,
                    gradient: gradient
                )
            }
        } failed: {
            
        }
    }
    
    @BackgroundActor
    private func loadRSI(mode: ChartMode) async {
        let stockRSI = StockData.temp(name: "SPY").injectRSI().injectStatus(mode: mode)
        stockRSI.values.minAndMaxValues(mode) { stockBoarderRSI in
            self.scope.launchMain {
                self.state = self.state.copy(
                    stock: stockRSI,
                    stockBoarder: StockBoarder(minX: stockBoarderRSI.minX, maxX: stockBoarderRSI.maxX, minY: 0, maxY: 100),
                    mode: mode
                )
            }
        } failed: {
            
        }
    }
    
    @BackgroundActor
    private func loadTrad(mode: ChartMode) async {
        let stockTrad = StockData.temp(name: "SPY").injectStatus(mode: mode)
        stockTrad.values.minAndMaxValues(mode) { stockBoarderTrad in
            self.scope.launchMain {
                self.state = self.state.copy(
                    stock: stockTrad,
                    stockBoarder: stockBoarderTrad,
                    mode: mode
                )
            }
        } failed: {
            
        }
    }
    
    
    @BackgroundActor
    private func loadPrediction(mode: ChartMode) async {
        let stockPred = StockData.temp(name: "SPY", start: 0, end: 30).injectStatus(mode: mode)
        let _stockPrediction = StockData.temp(name: "SPY", start: 30, end: 40).injectStatus(mode: mode)
        let stockMulti = [stockPred, _stockPrediction]
        stockPred.values.minAndMaxValues(mode) { stockBoarderPred in
            _stockPrediction.values.minAndMaxValues(mode) { stockBoarderPredictions in
                stockMulti.minAndMaxValues(mode) { both in
                    let gradient = stockPred.values.gradientCreator(stockBoarderPred, mode: mode)
                    let gradientPred = _stockPrediction.values.gradientCreator(stockBoarderPredictions, mode: mode)
                    let stockPrediction = _stockPrediction.injectConnectPoint(stockPred.values.last!) // Not Before For Correctly Gradient Creation
                    self.scope.launchMain {
                        self.state = self.state.copy(
                            stock: stockPred,
                            stockPrediction: stockPrediction,
                            stockBoarder: both,
                            mode: mode,
                            gradient: gradient,
                            gradientPred: gradientPred
                        )
                    }
                } failed: {
                    
                }
            } failed: {
                
            }
        } failed: {
            
        }
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
        var mode: ChartMode = ChartMode.StockPrediction
        var staticsMode: Int = 0
        
        mutating func copy(
            stocks: [StockData]? = nil,
            stock: StockData? = nil,
            stockPrediction: StockData? = nil,
            stockBoarder: StockBoarder? = nil,
            selectedIndex: Int? = nil,
            mode: ChartMode? = nil,
            staticsMode: Int? = nil,
            gradient: Gradient? = nil,
            gradientPred: Gradient? = nil,
            isLoading: Bool? = nil
        ) -> Self {
            self.stocks = stocks ?? self.stocks
            self.stock = stock ?? self.stock
            self.stockPrediction = stockPrediction ?? self.stockPrediction
            self.stockBoarder = stockBoarder ?? self.stockBoarder
            self.selectedIndex = selectedIndex ?? self.selectedIndex
            self.staticsMode = staticsMode ?? self.staticsMode
            self.mode = mode ?? self.mode
            self.gradient = gradient ?? self.gradient
            self.gradientPred = gradientPred ?? self.gradientPred
            self.isLoading = isLoading ?? self.isLoading
            return self
        }
    }
}
