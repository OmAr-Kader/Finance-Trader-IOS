import Foundation
import Combine

protocol StockSessionRepo {
    
    @BackgroundActor
    func insertStockSession(_ stock: StockSession,_ invoke: @escaping ((StockSession?) async -> Unit)) async
    
    @BackgroundActor
    func updateSession(
        id: String,
        stockData: StockData
    ) async -> ResultRealm<StockSession?>
    
    
    @BackgroundActor
    func getSessionLive(stockInfo: StockInfo, invoke: @escaping (StockSession?) -> Unit) async -> AnyCancellable?
    
    @BackgroundActor
    func getAStockSession(
        stockInfo: StockInfo,
        stringData: String,
        invoke: (ResultRealm<StockSession?>) -> Unit
    ) async
    
    @BackgroundActor
    func getStockSessions(
        stockInfo: StockInfo,
        stringData: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async
    
    @BackgroundActor
    func getStockSessions(stockInfo: StockInfo, dateScope: Date, invoke: @escaping (ResultRealm<StockSession?>) -> Unit) async
    
    @BackgroundActor
    func getAllStockSessions(
        stockInfo: StockInfo,
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async
    
    @BackgroundActor
    func getStocksSessions(
        stockInfo:[ StockInfo],
        stringData: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async
    
    @BackgroundActor
    func getAllStocksSessions(
        stockInfo: [StockInfo],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async
    
}
