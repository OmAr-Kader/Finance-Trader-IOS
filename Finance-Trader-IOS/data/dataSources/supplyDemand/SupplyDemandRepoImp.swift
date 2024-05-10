import Foundation
import Combine
import RealmSwift

class SupplyDemandRepoImp : BaseRepoImp, SupplyDemandRepo {
    
    func insertSupplyDemand(_ supplyDemand: SupplyDemand, _ invoke: @escaping ((SupplyDemand?) async -> Unit)) async {
        await invoke(await insert(supplyDemand).value)
    }
    
    func updateSupplyDemand(supplyDemandData: SupplyDemandData) async -> ResultRealm<SupplyDemand?> {
        return await edit(try! ObjectId(string: supplyDemandData.id)) { it in
            it.copy(supplyDemandData)
        }
    }
    
    @BackgroundActor
    func getSupplyDemand(
        id: String,
        invoke: @escaping (ResultRealm<SupplyDemand?>) -> Unit
    ) async {
        await querySingleLess(invoke, "%K == %@", "_id", try! ObjectId.init(string: id))
    }
    
    func getSupplysAndDemands(stockId: String, invoke: @escaping (ResultRealm<[SupplyDemand]>) -> Unit) async {
        await query(invoke, "getSupplysAndDemands\(stockId)", "%K == %@", "stockId", NSString(string: stockId))
    }
    
    func getSupplysAndDemandsLive(
        stockId: String,
        invoke: @escaping ([SupplyDemand]) -> Unit
    ) async -> AnyCancellable? {
        return await queryFlow(invoke, "getSupplysAndDemandsLive\(stockId)", "%K == %@", "stockId", NSString(string: stockId))
    }
    
    func deleteSupplyDemand(supplyDemand: SupplyDemand) async -> Int {
        return await delete(supplyDemand, supplyDemand._id)
    }
    
}
