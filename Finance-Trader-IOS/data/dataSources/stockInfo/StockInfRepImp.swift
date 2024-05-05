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
    
    func getAllStockInfo(invoke: (ResultRealm<[StockInfo]>) -> Unit) async {
        await queryAll(invoke)
    }
    
}
