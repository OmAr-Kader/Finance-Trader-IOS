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
    
    func getSupplysAndDemands(stockId: String, invoke: (ResultRealm<[SupplyDemand]>) -> Unit) async {
        await query(invoke, "getSupplysAndDemands\(stockId)", "%K == %@", "stockId", NSString(string: stockId))
    }
    
    func deleteSupplyDemand(supplyDemand: SupplyDemand) async -> Int {
        return await delete(supplyDemand, supplyDemand._id)
    }
    
}
