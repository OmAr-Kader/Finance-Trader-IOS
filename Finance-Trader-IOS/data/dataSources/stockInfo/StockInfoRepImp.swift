import Foundation
import RealmSwift
import Combine

class StockInfoRepImp : BaseRepoImp, StockInfoRep {
    
    func insertStockInfo(_ stockInfo: StockInfo, _ invoke: @escaping @BackgroundActor (StockInfo?) async -> Unit) async {
        await invoke(await insert(stockInfo).value)
    }
    
    func updateStockInfo(stockInfoData: StockInfoData) async -> ResultRealm<StockInfo?> {
        return await edit(try! ObjectId(string: stockInfoData.id)) { it in
            it.copy(stockInfoData)
        }
    }
    
    func getStockInfoLive(id: String, invoke: @escaping @BackgroundActor (StockInfo?) -> Unit) async -> AnyCancellable? {
        return await querySingleFlow(invoke, "getStockInfoLive\(id)", "%K == %@", "_id", try! ObjectId.init(string: id))
    }
    
    func getStockInfo(
        id: String,
        invoke: @BackgroundActor (ResultRealm<StockInfo?>) -> Unit
    ) async {
        await querySingle(invoke, "getStockInfo\(id)", "%K == %@", "_id", try! ObjectId.init(string: id))
    }
    
    func getAllStockInfo(invoke: @BackgroundActor (ResultRealm<[StockInfo]>) -> Unit) async {
        await queryAll(invoke)
    }
    
    @BackgroundActor
    func getTraderStocksInfoLive(
        traderId: String,
        invoke: @escaping @BackgroundActor ([StockInfo]) -> Unit
    ) async -> AnyCancellable? {
        await queryFlow(invoke, "getTraderStocksInfoLive\(traderId)", "%K CONTAINS %@", "queryHolders", NSString(string: traderId))
    }
    
    func getAllStockInfoLive(
        invoke: @escaping @BackgroundActor ([StockInfo]) -> Unit
    ) async -> AnyCancellable? {
        return await queryAllFlow(invoke, "getAllStockInfoLive")
    }
    
}
