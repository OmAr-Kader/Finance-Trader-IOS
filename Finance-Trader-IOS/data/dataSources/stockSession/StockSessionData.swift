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
    func getSessionLive(stockInfo: StockInfo, invoke: @escaping (StockSession?) -> Unit) async -> AnyCancellable? {
        return await repository.getSessionLive(stockInfo: stockInfo, invoke: invoke)
    }
    
    @BackgroundActor
    func getAStockSession(
        stockInfo: StockInfo,
        stringData: String,
        invoke: (ResultRealm<StockSession?>) -> Unit
    ) async {
        await repository.getAStockSession(stockInfo: stockInfo, stringData: stringData, invoke: invoke)
    }
    
    @BackgroundActor
    func getStockSessions(
        stockInfo: StockInfo,
        stringData: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        await repository.getStockSessions(stockInfo: stockInfo, stringData: stringData, stockSessions: stockSessions)
    }
    
    @BackgroundActor
    func getStockSessions(stockInfo: StockInfo, dateScope: Date, invoke: @escaping (ResultRealm<StockSession?>) -> Unit) async {
        await repository.getStockSessions(stockInfo: stockInfo, dateScope: dateScope, invoke: invoke)
    }
    
    @BackgroundActor
    func getAllStockSessions(
        stockInfo: StockInfo,
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        await repository.getAllStockSessions(stockInfo: stockInfo, stockSessions: stockSessions)
    }
    
    @BackgroundActor
    func getStocksSessions(
        stockInfo: [StockInfo],
        stringData: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        await repository.getStocksSessions(stockInfo: stockInfo, stringData: stringData, stockSessions: stockSessions)
    }
    
    @BackgroundActor
    func getAllStocksSessions(
        stockInfo: [StockInfo],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        await repository.getAllStocksSessions(stockInfo: stockInfo, stockSessions: stockSessions)
    }
}
