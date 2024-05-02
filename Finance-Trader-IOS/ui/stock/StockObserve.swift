import Foundation
import SwiftUI

class StockObserve : ObservableObject {
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    @MainActor 
    func loadData(trader: TraderData, isDarkMode: Bool) {
        let mode = state.mode
        self.scope.launchRealm {
            let stockInfo = StockInfoData.temp().injectColor(isDarkMode: isDarkMode)
            let haveShares = stockInfo.stockholders.first { it in
                it.holderId == trader.id
            }
            let supplyDemands = SupplyDemandData.temps().injectStatus(traderId: trader.id, haveShares: haveShares).injectColors(stackHolders: stockInfo.stockholders)
            let stock = StockData.temp(symbol: "SPY")
            stock.values.minAndMaxValues(mode) { stockBoarder in
                let gradient = stock.injectStatus(mode: mode).values.gradientCreator(stockBoarder, mode: mode)
                self.scope.launchMain {
                    self.state = self.state.copy(trader: trader, stockInfo: stockInfo, supplyDemands: supplyDemands, isHaveShares: haveShares != nil, stock: stock, stockBoarder: stockBoarder, gradient: gradient, isLoading: false)
                }
            } failed: {
                self.scope.launchMain {
                    self.state = self.state.copy(isLoading: false)
                }
            }
        }
    }
    
    @MainActor
    func loadStocks(mode: ChartMode) {
        scope.launchRealm {
            switch mode {
            case .StockWave: await self.loadWave(self.state.stock, mode: mode)
            case .StockSMA: await self.loadSMA(self.state.stock, mode: mode)
            case .StockEMA: await self.loadEMA(self.state.stock, mode: mode)
            case .StockRSI: await self.loadRSI(self.state.stock, mode: mode)
            case .StockTrad: await self.loadTrad(self.state.stock, mode: mode)
            case .StockPrediction: await self.loadPrediction(self.state.stock, mode: mode)
            default : ()
            }
        }
    }
    
    @BackgroundActor
    private func loadWave(_ stock: StockData, mode: ChartMode) async {
        let stockWave = stock.injectStatus(mode: mode)
        stockWave.values.minAndMaxValues(mode) { stockBoarderWave in
            let gradient = stockWave.values.gradientCreator(stockBoarderWave, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockWave, stockBoarder: stockBoarderWave, gradient: gradient, mode: mode, isLoading: false)
            }
        } failed: {}
    }
    
    @BackgroundActor
    private func loadSMA(_ stock: StockData, mode: ChartMode) async {
        let stockSMA = stock.injectSMA().injectStatus(mode: mode)
        stockSMA.values.minAndMaxValues(mode) { stockBoarderSMA in
            let gradient = stockSMA.values.gradientCreator(stockBoarderSMA, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockSMA, stockBoarder: stockBoarderSMA, gradient: gradient, mode: mode, isLoading: false)
            }
        } failed: {}
    }
    
    @BackgroundActor
    private func loadEMA(_ stock: StockData, mode: ChartMode) async {
        let stockEMA = stock.injectEMA().injectStatus(mode: mode)
        stockEMA.values.minAndMaxValues(mode) { stockBoarderEMA in
            let gradient = stockEMA.values.gradientCreator(stockBoarderEMA, mode: mode)
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockEMA, stockBoarder: stockBoarderEMA, gradient: gradient, mode: mode, isLoading: false)
            }
        } failed: {}
    }
    
    @BackgroundActor
    private func loadRSI(_ stock: StockData, mode: ChartMode) async {
        let stockRSI = stock.injectRSI().injectStatus(mode: mode)
        stockRSI.values.minAndMaxValues(mode) { stockBoarderRSI in
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockRSI, stockBoarder: StockBoarder(minX: stockBoarderRSI.minX, maxX: stockBoarderRSI.maxX, minY: 0, maxY: 100), mode: mode, isLoading: false)
            }
        } failed: {}
    }
    
    @BackgroundActor
    private func loadTrad(_ stock: StockData, mode: ChartMode) async {
        let stockTrad = stock.injectStatus(mode: mode)
        stockTrad.values.minAndMaxValues(mode) { stockBoarderTrad in
            self.scope.launchMain {
                self.state = self.state.copy(stock: stockTrad, stockBoarder: stockBoarderTrad, mode: mode, isLoading: false)
            }
        } failed: {}
    }
    
    
    @BackgroundActor
    private func loadPrediction(_ stock: StockData, mode: ChartMode) async {
        let stockPred = stock.injectStatus(mode: mode)
        let _stockPrediction = StockData.temp(symbol: "SPY", start: stock.values.count, end: stock.values.count + 10).injectStatus(mode: mode)
        let stockMulti = [stockPred, _stockPrediction]
        stockPred.values.minAndMaxValues(mode) { stockBoarderPred in
            _stockPrediction.values.minAndMaxValues(mode) { stockBoarderPredictions in
                stockMulti.minAndMaxValues(mode) { both in
                    let gradient = stockPred.values.gradientCreator(stockBoarderPred, mode: mode)
                    let gradientPred = _stockPrediction.values.gradientCreator(stockBoarderPredictions, mode: mode)
                    let stockPrediction = _stockPrediction.injectConnectPoint(stockPred.values.last!) // Not Before For Correctly Gradient Creation
                    self.scope.launchMain {
                        self.state = self.state.copy(stock: stockPred, stockBoarder: both, gradient: gradient, mode: mode, stockPrediction: stockPrediction, gradientPred: gradientPred, isLoading: false)
                    }
                } failed: {}
            } failed: {}
        } failed: {}
    }
    
    struct State {
        
        var trader: TraderData = TraderData()
        var stockInfo: StockInfoData = StockInfoData()
        var supplyDemands: [SupplyDemandData] = []
        var isHaveShares: Bool = false

        var stock: StockData = StockData()
        var stockBoarder: StockBoarder = StockBoarder()
        var gradient: Gradient = Gradient(stops: [])
        var mode: ChartMode = ChartMode.StockWave

        var stockPrediction: StockData = StockData()
        var gradientPred: Gradient = Gradient(stops: [])

        var isLoading: Bool = false
        
        mutating func copy(
            trader: TraderData? = nil,
            stockInfo: StockInfoData? = nil,
            supplyDemands: [SupplyDemandData]? = nil,
            isHaveShares: Bool? = nil,
            stock: StockData? = nil,
            stockBoarder: StockBoarder? = nil,
            gradient: Gradient? = nil,
            mode: ChartMode? = nil,
            stockPrediction: StockData? = nil,
            gradientPred: Gradient? = nil,
            isLoading: Bool? = nil
        ) -> Self {
            self.trader = trader ?? self.trader
            self.stockInfo = stockInfo ?? self.stockInfo
            self.supplyDemands = supplyDemands ?? self.supplyDemands
            self.isHaveShares = isHaveShares ?? self.isHaveShares
            self.stock = stock ?? self.stock
            self.stockBoarder = stockBoarder ?? self.stockBoarder
            self.gradient = gradient ?? self.gradient
            self.mode = mode ?? self.mode
            self.stockPrediction = stockPrediction ?? self.stockPrediction
            self.gradientPred = gradientPred ?? self.gradientPred
            self.isLoading = isLoading ?? self.isLoading
            return self
        }
    }
    
}
