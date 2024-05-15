import Foundation
import Combine
import RealmSwift

class StockInformationData {
    
    let repository: StockInfoRep
    
    init(repository: StockInfoRep) {
        self.repository = repository
    }
    
    @BackgroundActor
    func insertStockInfo(_ stockInfo: StockInfo,_ invoke: @escaping @BackgroundActor (StockInfo?) async -> Unit) async {
        await repository.insertStockInfo(stockInfo, invoke)
    }
    
    @BackgroundActor
    func updateStockInfo(
        stockInfoData: StockInfoData
    ) async -> ResultRealm<StockInfo?> {
        await repository.updateStockInfo(stockInfoData: stockInfoData)
    }
    
    @BackgroundActor
    func getStockInfoLive(id: String, invoke: @escaping @BackgroundActor (StockInfo?) -> Unit) async -> AnyCancellable? {
        return await repository.getStockInfoLive(id: id, invoke: invoke)
    }
    
    @BackgroundActor
    func getAllStockInfo(
        invoke: @BackgroundActor (ResultRealm<[StockInfo]>) -> Unit
    ) async {
        await repository.getAllStockInfo(invoke: invoke)
    }
    
    @BackgroundActor
    func getAllStockInfoLive(
        invoke: @escaping @BackgroundActor ([StockInfo]) -> Unit
    ) async -> AnyCancellable? {
        return await repository.getAllStockInfoLive(invoke: invoke)
    }
    
    @BackgroundActor
    func getTraderStocksInfoLive(
        traderId: String,
        invoke: @escaping @BackgroundActor ([StockInfo]) -> Unit
    ) async -> AnyCancellable? {
        return await repository.getTraderStocksInfoLive(traderId: traderId, invoke: invoke)
    }
    
    @BackgroundActor
    func getStockInfo(
        id: String,
        invoke: @BackgroundActor (ResultRealm<StockInfo?>) -> Unit
    ) async {
        await repository.getStockInfo(id: id, invoke: invoke)
    }
    
}
