import Foundation
import Combine

class StockSessionData {
    
    let repository: StockSessionRepo
    
    init(repository: StockSessionRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func insertStockSession(_ stock: StockSession,_ invoke: @escaping ((StockSession?) async -> Unit)) async {
        await repository.insertStockSession(stock, invoke)
    }
    
    @BackgroundActor
    func updateSession(
        id: String,
        stockData: StockData
    ) async -> ResultRealm<StockSession?> {
        await repository.updateSession(id: id, stockData: stockData)
    }
    
    
    @BackgroundActor
    func getSessionLive(stockId: String, invoke: @escaping (StockSession?) -> Unit) async -> AnyCancellable? {
        return await repository.getSessionLive(stockId: stockId, invoke: invoke)
    }
    
    @BackgroundActor
    func getStockSessions(
        stockId: String,
        stringData: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        await repository.getStockSessions(stockId: stockId, stringData: stringData, stockSessions: stockSessions)
    }
    
    @BackgroundActor
    func getStocksSessions(
        stockId: [String],
        stringData: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        await repository.getStocksSessions(stockId: stockId, stringData: stringData, stockSessions: stockSessions)
    }
}
