import Foundation
import SwiftUI

class StockObserve : ObservableObject {
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    @MainActor 
    func loadData(trader: TraderData, isDarkMode: Bool) {
        let mode = ChartMode.StockWave
        self.scope.launchRealm {
            let stockInfo = StockInfoData.temp().injectColor(isDarkMode: isDarkMode)
            let haveShares = stockInfo.stockholders.first { it in
                it.holderId == trader.id
            }
            let supplyDemands = SupplyDemandData.temps().injectStatus(traderId: trader.id, haveShares: haveShares).injectColors(stackHolders: stockInfo.stockholders)
            let _stock = StockData.temp(id: "1", symbol: "SPY").injectLastPrice(price: stockInfo.stockPrice, isGain: stockInfo.isGain)
            guard let stockBoarder = _stock.values.minAndMaxValues(mode) else {
                self.scope.launchMain {
                    self.state = self.state.copy(isLoading: false)
                }
                return
            }
            let gradient = _stock.injectStatus(mode: mode).values.gradientCreator(stockBoarder, mode: mode)
            let stock = _stock.injectGradient(gradient: gradient).injectMode(mode: mode).injectStockBoarder(stockBoarder: stockBoarder)
            self.scope.launchMain {
                self.state = self.state.copy(stockInfo: stockInfo, supplyDemands: supplyDemands, isHaveShares: haveShares != nil, stock: stock, isLoading: false)
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
            }
        }
    }
    
    @BackgroundActor
    private func loadWave(_ stock: StockData, mode: ChartMode) async {
        let _stockWave = stock.injectStatus(mode: mode)
        guard let stockBoarderWave = _stockWave.values.minAndMaxValues(mode) else {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: false)
            }
            return
        }
        let gradient = _stockWave.values.gradientCreator(stockBoarderWave, mode: mode)
        let stockWave = _stockWave.injectGradient(gradient: gradient).injectMode(mode: mode).injectStockBoarder(stockBoarder: stockBoarderWave)
        self.scope.launchMain {
            self.state = self.state.copy(stock: stockWave, isLoading: false)
        }
    }
    
    @BackgroundActor
    private func loadSMA(_ stock: StockData, mode: ChartMode) async {
        let _stockSMA = stock.injectSMA().injectStatus(mode: mode)
        guard let stockBoarderSMA = _stockSMA.values.minAndMaxValues(mode) else {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: false)
            }
            return
        }
        let gradient = _stockSMA.values.gradientCreator(stockBoarderSMA, mode: mode)
        let stockSMA = _stockSMA.injectGradient(gradient: gradient).injectMode(mode: mode).injectStockBoarder(stockBoarder: stockBoarderSMA)
        self.scope.launchMain {
            self.state = self.state.copy(stock: stockSMA, isLoading: false)
        }
    }
    
    @BackgroundActor
    private func loadEMA(_ stock: StockData, mode: ChartMode) async {
        let _stockEMA = stock.injectEMA().injectStatus(mode: mode)
        guard let stockBoarderEMA = _stockEMA.values.minAndMaxValues(mode) else {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: false)
            }
            return
        }
        let gradient = _stockEMA.values.gradientCreator(stockBoarderEMA, mode: mode)
        let stockEMA = _stockEMA.injectGradient(gradient: gradient).injectMode(mode: mode).injectStockBoarder(stockBoarder: stockBoarderEMA)
        self.scope.launchMain {
            self.state = self.state.copy(stock: stockEMA, isLoading: false)
        }
    }
    
    @BackgroundActor
    private func loadRSI(_ stock: StockData, mode: ChartMode) async {
        let _stockRSI = stock.injectRSI().injectStatus(mode: mode)
        guard let stockBoarderRSI = _stockRSI.values.minAndMaxValues(mode) else {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: false)
            }
            return
        }
        let stockRSI = _stockRSI.injectMode(mode: mode).injectStockBoarder(stockBoarder: StockBoarder(minX: stockBoarderRSI.minX, maxX: stockBoarderRSI.maxX, minY: 0, maxY: 100))
        self.scope.launchMain {
            self.state = self.state.copy(stock: stockRSI, isLoading: false)
        }
    }
    
    @BackgroundActor
    private func loadTrad(_ stock: StockData, mode: ChartMode) async {
        let _stockTrad = stock.injectStatus(mode: mode)
        guard let stockBoarderTrad = _stockTrad.values.minAndMaxValues(mode) else {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: false)
            }
            return
        }
        let stockTrad = _stockTrad.injectMode(mode: mode).injectStockBoarder(stockBoarder: stockBoarderTrad)
        self.scope.launchMain {
            self.state = self.state.copy(stock: stockTrad, isLoading: false)
        }
    }
    
    
    @BackgroundActor
    private func loadPrediction(_ stock: StockData, mode: ChartMode) async {
        let stockPred = stock.injectStatus(mode: mode).injectPredictions()
        let stockMulti = [stockPred.values, stockPred.values]
        guard let stockBoarderPred = stockPred.values.minAndMaxValues(mode) else {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: false)
            }
            return
        }
        guard let stockBoarderPredictions = stockPred.valuesPrediction.minAndMaxValues(mode) else {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: false)
            }
            return
        }
        guard let both = stockMulti.minAndMaxValues(mode) else {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: false)
            }
            return
        }
        let gradient = stockPred.values.gradientCreator(stockBoarderPred, mode: mode)
        let gradientPred = stockPred.valuesPrediction.gradientCreator(stockBoarderPredictions, mode: mode)
        let stockPrediction = stockPred.injectGradient(gradient: gradient)
            .injectGradientPredictions(gradientPred: gradientPred)
            .injectConnectPredictionPoint(stockPred.values.last!)
            .injectMode(mode: mode)
            .injectStockBoarder(stockBoarder: both)
        self.scope.launchMain {
            self.state = self.state.copy(stock: stockPrediction, isLoading: false)
        }
    }
    
    func sellShare(supplyDemandData: SupplyDemandData, trader: TraderData, stockInfo: StockInfoData) {
        
    }
    
    func buyShare(supplyDemandData: SupplyDemandData, trader: TraderData, stockInfo: StockInfoData) {
        
    }
    
    func pushNegotiate(supplyDemandData: SupplyDemandData, trader: TraderData) {
        
    }
    
    @MainActor
    func setAddSheet(_ it: Bool) {
        self.state = self.state.copy(isAddSheet: it)
    }
    
    @MainActor
    func setNegotiateSheet(_ it: Bool) {
        self.state = self.state.copy(isNegotiateSheet: it)
    }
    
    @MainActor
    func setNegotiateShares(_ it: String) {
        self.state = self.state.copy(shares: it)
    }
    
    @MainActor
    func setNegotiatePrice(_ it: String) {
        self.state = self.state.copy(price: it)
    }
    
    @MainActor
    func showSupplyDemandSheet(supplyDemandData: SupplyDemandData) {
        self.state = self.state.copy(
            supplyDemandData: supplyDemandData,
            isNegotiateSheet: true
        )
    }
    
    @MainActor
    func showNegotiateSheet(supplyDemandData: SupplyDemandData) {
        self.state = self.state.copy(
            supplyDemandData: supplyDemandData,
            isNegotiateSheet: true
        )
    }
    
    
    struct State {
        
        var stockInfo: StockInfoData = StockInfoData()
        var supplyDemands: [SupplyDemandData] = []
        var isHaveShares: Bool = false

        var stock: StockData = StockData()

        var isLoading: Bool = false
        
        var isAddSheet: Bool = false

        var isNegotiateSheet: Bool = false
        var supplyDemandData: SupplyDemandData? = nil

        mutating func copy(
            stockInfo: StockInfoData? = nil,
            supplyDemands: [SupplyDemandData]? = nil,
            isHaveShares: Bool? = nil,
            stock: StockData? = nil,
            isLoading: Bool? = nil,
            isAddSheet: Bool? = nil,
            supplyDemandData: SupplyDemandData? = nil,
            isNegotiateSheet: Bool? = nil,
            shares: String? = nil,
            price: String? = nil
        ) -> Self {
            self.stockInfo = stockInfo ?? self.stockInfo
            self.supplyDemands = supplyDemands ?? self.supplyDemands
            self.isHaveShares = isHaveShares ?? self.isHaveShares
            self.stock = stock ?? self.stock
            self.isLoading = isLoading ?? self.isLoading
            self.isAddSheet = isAddSheet ?? self.isAddSheet
            self.supplyDemandData = supplyDemandData ?? self.supplyDemandData
            self.isNegotiateSheet = isNegotiateSheet ?? self.isNegotiateSheet
            return self
        }
    }
    
}
