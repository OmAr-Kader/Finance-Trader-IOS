import Foundation
import SwiftUI

class StockObserve : ObservableObject {
    
    private var scope = Scope()
    
    @Inject
    private var project: Project
    
    @MainActor
    @Published var state = State()
    
    @MainActor 
    func loadData(stockId: String, trader: TraderData, isDarkMode: Bool) {
        loadingStatus(true)
        self.scope.launchRealm {
            await self.project.stockInfo.getStockInfo(id: stockId) { it in
                guard let _stockInfo = it.value else {
                    self.loadingStatus(false)
                    return
                }
                let stockInfo = StockInfoData(stockInfo: _stockInfo).injectColor(isDarkMode: isDarkMode)
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
                self.scope.launchRealm {
                    await self.project.supplyDemand.getSupplysAndDemands(stockId: stockId) { it in
                        let haveShares = stockInfo.stockholders.first { it in
                            it.holderId == trader.id
                        }
                        let stock = stockInfo.toHomeStockData([])
                        let supplyDemands = it.value.toSupplyDemandData().injectStatus(traderId: trader.id, haveShares: haveShares).injectColors(stackHolders: stockInfo.stockholders)
                        self.scope.launchMain {
                            self.state = self.state.copy(stockInfo: stockInfo, supplyDemands: supplyDemands, isHaveShares: haveShares != nil, stock: stock, isLoading: false)
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func loadStocks(mode: ChartMode) {
        let stock = self.state.stock
        scope.launchRealm {
            let newStock = switch mode {
            case .StockWave: stock.loadWave()
            case .StockSMA: stock.loadSMA()
            case .StockEMA: stock.loadEMA()
            case .StockRSI: stock.loadRSI()
            case .StockTrad: stock.loadTrad()
            case .StockPrediction: self.loadPrediction(stock, mode: mode)
            }
            
            self.scope.launchMain {
                self.state = self.state.copy(stock: newStock)
            }
        }
    }
    
    @BackgroundActor
    private func loadPrediction(_ stock: StockData, mode: ChartMode) -> StockData {
        let stockPred = stock.injectStatus(mode: mode).injectPredictions()
        let stockMulti = [stockPred.values, stockPred.values]
        guard let stockBoarderPred = stockPred.values.minAndMaxValues(mode) else {
            loadingStatus(false)
            return stock
        }
        guard let stockBoarderPredictions = stockPred.valuesPrediction.minAndMaxValues(mode) else {
            loadingStatus(false)
            return stock
        }
        guard let both = stockMulti.minAndMaxValues(mode) else {
            loadingStatus(false)
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
    
    @MainActor
    func createSupply(isSupply: Bool, traderId: String, stockId: String, shares: Int64, price: Float64, invoke: @escaping @MainActor () -> (), failed: @escaping @MainActor () -> ()) {
        loadingStatus(true)
        self.scope.launchRealm {
            await self.project.supplyDemand.insertSupplyDemand(
                SupplyDemand(supplyDemandData: SupplyDemandData(id: "", isSupply: isSupply, traderId: traderId, stockId: stockId, shares: shares, price: price))) { it in
                    self.scope.launchMain {
                        guard it != nil else {
                            self.loadingStatus(false)
                            failed()
                            return
                        }
                        self.loadingStatus(false)
                        invoke()
                    }
                }
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
    
    private func loadingStatus(_ it: Bool) {
        self.scope.launchMain {
            self.state = self.state.copy(isLoading: it)
        }
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
