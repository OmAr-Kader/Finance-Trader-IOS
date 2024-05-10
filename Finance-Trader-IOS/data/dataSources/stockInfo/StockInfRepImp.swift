import Foundation
import RealmSwift
import Combine

class StockInfRepImp : BaseRepoImp, StockInfoRep {
    
    func insertStockInfo(_ stockInfo: StockInfo, _ invoke: @escaping ((StockInfo?) async -> Unit)) async {
        await invoke(await insert(stockInfo).value)
    }
    
    func updateSession(stockInfoData: StockInfoData) async -> ResultRealm<StockInfo?> {
        return await edit(try! ObjectId(string: stockInfoData.id)) { it in
            it.copy(stockInfoData)
        }
    }
    
    func getStockInfoLive(id: String, invoke: @escaping (StockInfo?) -> Unit) async -> AnyCancellable? {
        return await querySingleFlow(invoke, "getStockInfoLive\(id)", "%K == %@", "_id", try! ObjectId.init(string: id))
    }
    
    func getStockInfo(
        id: String,
        invoke: (ResultRealm<StockInfo?>) -> Unit
    ) async {
        await querySingle(invoke, "getStockInfo\(id)", "%K == %@", "_id", try! ObjectId.init(string: id))
    }
    
    func getAllStockInfo(invoke: (ResultRealm<[StockInfo]>) -> Unit) async {
        await queryAll(invoke)
    }
    
    @BackgroundActor
    func getTraderStocksInfoLive(
        traderId: String,
        invoke: @escaping ([StockInfo]) -> Unit
    ) async -> AnyCancellable? {
        await queryFlow(invoke, "getTraderStocksInfoLive\(traderId)", "%K CONTAINS %@", "queryHolders", NSString(string: traderId))
    }
    
    func getAllStockInfoLive(
        invoke: @escaping ([StockInfo]) -> Unit
    ) async -> AnyCancellable? {
        return await queryAllFlow(invoke, "getAllStockInfoLive")
    }
    
}
