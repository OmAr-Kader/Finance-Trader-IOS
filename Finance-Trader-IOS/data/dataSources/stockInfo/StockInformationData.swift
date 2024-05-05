import Foundation
import Combine
import RealmSwift

class StockInformationData {
    
    let repository: StockInfoRep
    
    init(repository: StockInfoRep) {
        self.repository = repository
    }
    
    @BackgroundActor
    func insertStockInfo(_ stockInfo: StockInfo,_ invoke: @escaping ((StockInfo?) async -> Unit)) async {
        await repository.insertStockInfo(stockInfo, invoke)
    }
    
    @BackgroundActor
    func updateSession(
        stockInfoData: StockInfoData
    ) async -> ResultRealm<StockInfo?> {
        await repository.updateSession(stockInfoData: stockInfoData)
    }
    
    @BackgroundActor
    func getStockInfoLive(id: String, invoke: @escaping (StockInfo?) -> Unit) async -> AnyCancellable? {
        return await repository.getStockInfoLive(id: id, invoke: invoke)
    }
    
    @BackgroundActor
    func getAllStockInfo(
        invoke: (ResultRealm<[StockInfo]>) -> Unit
    ) async {
        await repository.getAllStockInfo(invoke: invoke)
    }
    
}
