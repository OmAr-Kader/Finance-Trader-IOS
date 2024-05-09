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
    func getSessionLive(stockId: String, invoke: @escaping (StockSession?) -> Unit) async -> AnyCancellable?
    
    @BackgroundActor
    func getAStockSession(
        stockId: String,
        stringData: String,
        invoke: (ResultRealm<StockSession?>) -> Unit
    ) async
    
    @BackgroundActor
    func getStockSessions(
        stockId: String,
        stringData: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async
    
    @BackgroundActor
    func getAllStockSessions(
        stockId: String,
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async
    
    @BackgroundActor
    func getStocksSessions(
        stockId: [String],
        stringData: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async
    
    @BackgroundActor
    func getAllStocksSessions(
        stockId: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async
    
}
