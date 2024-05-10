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
    func getSupplyDemand(
        id: String,
        invoke: @escaping (ResultRealm<SupplyDemand?>) -> Unit
    ) async
    
    @BackgroundActor
    func getSupplysAndDemands(
        stockId: String,
        invoke: @escaping (ResultRealm<[SupplyDemand]>) -> Unit
    ) async
    
    @BackgroundActor
    func getSupplysAndDemandsLive(
        stockId: String,
        invoke: @escaping ([SupplyDemand]) -> Unit
    ) async -> AnyCancellable?
    
    @BackgroundActor
    func deleteSupplyDemand(supplyDemand: SupplyDemand) async -> Int
    
}
