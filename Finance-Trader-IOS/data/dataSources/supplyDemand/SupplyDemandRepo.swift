import Foundation
import Combine

protocol SupplyDemandRepo {
    
    @BackgroundActor
    func insertSupplyDemand(_ supplyDemand: SupplyDemand,_ invoke: @escaping ((SupplyDemand?) async -> Unit)) async
    
    @BackgroundActor
    func updateSupplyDemand(
        supplyDemandData: SupplyDemandData
    ) async -> ResultRealm<SupplyDemand?>
    
    @BackgroundActor
    func getSupplysAndDemands(
        stockId: String,
        invoke: (ResultRealm<[SupplyDemand]>) -> Unit
    ) async
    
    @BackgroundActor
    func deleteSupplyDemand(supplyDemand: SupplyDemand) async -> Int
    
}
