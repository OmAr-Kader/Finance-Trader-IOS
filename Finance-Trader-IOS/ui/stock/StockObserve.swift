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
                self.scope.launchRealm {
                    await self.project.stockSession.getAllStockSessions(
                        stockId: stockInfo.id
                    ) { sessions in
                        self.scope.launchRealm {
                            await self.project.supplyDemand.getSupplysAndDemands(stockId: stockId) { it in
                                let haveShares = stockInfo.stockholders.first { it in
                                    it.holderId == trader.id
                                }
                                let stock = stockInfo.toHomeStockData(sessions.value.toStockData())
                                let supplyDemands = it.value.toSupplyDemandData().injectStatus(traderId: trader.id, haveShares: haveShares).injectColors(stackHolders: stockInfo.stockholders)
                                self.scope.launchMain {
                                    self.state = self.state.copy(stockInfo: stockInfo, supplyDemands: supplyDemands, isHaveShares: haveShares != nil, stock: stock, isLoading: false)
                                }
                            }
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
        let stockPred = stock.injectStatus(mode: mode).injectPredictions(predictions: [])
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
    
    @MainActor
    func buyShare(supplyData: SupplyDemandData, toTrader: String, stockId: String, invoke: @escaping () -> (), failed: @escaping @MainActor () -> ()) {
        loadingStatus(true)
        self.adjustStockInfo(supplyData: supplyData, fromTrader: supplyData.traderId, toTrader: toTrader, stockId: stockId) { newStockInfoData in
            self.scope.launchRealm {
                await self.project.stockSession.getAStockSession(stockId: stockId, stringData: currentTime.toStrDMY) { _stockSession in
                    self.scope.launchRealm {
                        guard let stockSession = _stockSession.value else {
                            self.createNewSession(newStockInfoData: newStockInfoData, symbol: newStockInfoData.symbol, stockId: stockId, invoke: {
                                await self.deleteSuppltDemand(supplyDemandData: supplyData, invoke: invoke, failed: failed)
                            }, failed: failed)
                            return
                        }
                        self.adjustStockSession(stockSession: stockSession, newStockInfoData: newStockInfoData, symbol: newStockInfoData.symbol, stockId: stockId, invoke: {
                            await self.deleteSuppltDemand(supplyDemandData: supplyData, invoke: invoke, failed: failed)
                        }, failed: failed)
                    }
                }
            }
        } failed: {
            failed()
        }
    }
    
    private func adjustStockInfo(
        supplyData: SupplyDemandData,
        fromTrader: String,
        toTrader: String,
        stockId: String,
        invoke: @escaping (StockInfoData) -> (),
        failed: @escaping @MainActor () -> ()
    ) {
        self.scope.launchRealm {
            await self.project.stockInfo.getStockInfo(id: stockId) { _stockInfo in
                guard let stockInfo = _stockInfo.value else {
                    self.scope.launchMain {
                        self.loadingStatus(false)
                        failed()
                    }
                    return
                }
                let stockInfoData = StockInfoData(stockInfo: stockInfo)
    
                guard let newStockInfoData = stockInfoData.adjustStockPrice(
                    sharesToExchange: supplyData.shares,
                    newPrice: supplyData.price
                ).makeExchange(fromTrader: fromTrader, toTrader: toTrader, exchangedShares: supplyData.shares) else {
                    self.scope.launchMain {
                        self.loadingStatus(false)
                        failed()
                    }
                    return
                }
                invoke(newStockInfoData)
            }
        }
    }
    
    private func createNewSession(
        newStockInfoData: StockInfoData,
        symbol: String,
        stockId: String,
        invoke: @escaping @BackgroundActor () async -> (),
        failed: @escaping @MainActor () -> ()
    ) {
        self.scope.launchRealm {
            let stockSession = StockSession(
                stockData: StockData(
                    id: "",
                    stockId: stockId,
                    symbol: symbol,
                    values: [StockPointData(time: currentTime, newPrice: newStockInfoData.stockPrice)],
                    stringData: currentTime.toStrDMY
                )
            )
            await self.project.stockSession.insertStockSession(stockSession) { newStockSession in
                guard newStockSession != nil else {
                    self.scope.launchMain {
                        self.loadingStatus(false)
                        failed()
                    }
                    return
                }
                self.scope.launchRealm {
                    guard let updatedStockInfoData = await self.project.stockInfo.updateSession(
                        stockInfoData: newStockInfoData
                    ).value else {
                        self.scope.launchMain {
                            self.loadingStatus(false)
                            failed()
                        }
                        return
                    }
                    await invoke()
                }
            }
        }
    }
    
    private func adjustStockSession(
        stockSession: StockSession,
        newStockInfoData: StockInfoData,
        symbol: String,
        stockId: String,
        invoke: @escaping @BackgroundActor () async -> (),
        failed: @escaping @MainActor () -> ()
    ) {
        self.scope.launchRealm {
            var _stockData = StockData(stockSession)
            _stockData.values.append(StockPointData(time: currentTime, newPrice: newStockInfoData.stockPrice))
            let stockData = _stockData
            self.scope.launchRealm {
                let newStockSession = await self.project.stockSession.updateSession(id: stockData.id, stockData: stockData)
                guard newStockSession.value != nil else {
                    self.scope.launchMain {
                        self.loadingStatus(false)
                        failed()
                    }
                    return
                }
                await invoke()
            }
        }
    }
    
    @BackgroundActor
    private func deleteSuppltDemand(supplyDemandData: SupplyDemandData, invoke: @escaping @MainActor () -> (), failed: @escaping @MainActor () -> ()) async {
        let result = await self.project.supplyDemand.deleteSupplyDemand(supplyDemand: SupplyDemand(supplyDemandData: supplyDemandData))
        if result == REALM_SUCCESS {
            self.scope.launchMain {
                invoke()
            }
        } else {
            self.scope.launchMain {
                self.loadingStatus(false)
                failed()
            }
        }
    }
    
    func sellShare(demmandData: SupplyDemandData, fromTrader: String, stockId: String, invoke: @escaping () -> (), failed: @escaping @MainActor () -> ()) {
        loadingStatus(true)
        self.adjustStockInfo(supplyData: demmandData, fromTrader: fromTrader, toTrader: demmandData.traderId, stockId: stockId) { newStockInfoData in
            self.scope.launchRealm {
                await self.project.stockSession.getAStockSession(stockId: stockId, stringData: currentTime.toStrDMY) { _stockSession in
                    self.scope.launchRealm {
                        guard let stockSession = _stockSession.value else {
                            self.createNewSession(newStockInfoData: newStockInfoData, symbol: newStockInfoData.symbol, stockId: stockId, invoke: {
                                await self.deleteSuppltDemand(supplyDemandData: demmandData, invoke: invoke, failed: failed)
                            }, failed: failed)
                            return
                        }
                        self.adjustStockSession(stockSession: stockSession, newStockInfoData: newStockInfoData, symbol: newStockInfoData.symbol, stockId: stockId, invoke: {
                            await self.deleteSuppltDemand(supplyDemandData: demmandData, invoke: invoke, failed: failed)
                        }, failed: failed)
                    }
                }
            }
        } failed: {
            failed()
        }
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
