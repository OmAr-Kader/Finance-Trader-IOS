import Foundation
import Combine

class SupplyAndDemandData {
    
    let repository: SupplyDemandRepo
    
    init(repository: SupplyDemandRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func insertSupplyDemand(_ supplyDemand: SupplyDemand,_ invoke: @escaping ((SupplyDemand?) async -> Unit)) async {
        await repository.insertSupplyDemand(supplyDemand, invoke)
    }
    
    @BackgroundActor
    func updateSupplyDemand(
        supplyDemandData: SupplyDemandData
    ) async -> ResultRealm<SupplyDemand?> {
        await repository.updateSupplyDemand(supplyDemandData: supplyDemandData)
    }
    
    
    @BackgroundActor
    func getSupplyDemand(
        id: String,
        invoke: @escaping (ResultRealm<SupplyDemand?>) -> Unit
    ) async {
        await repository.getSupplyDemand(id: id, invoke: invoke)
    }
    
    @BackgroundActor
    func getSupplysAndDemands(
        stockId: String,
        invoke: @escaping (ResultRealm<[SupplyDemand]>) -> Unit
    ) async {
        await repository.getSupplysAndDemands(stockId: stockId, invoke: invoke)
    }
    
    @BackgroundActor
    func getSupplysAndDemandsLive(
        stockInfo: StockInfo,
        invoke: @escaping ([SupplyDemand]) -> Unit
    ) async -> AnyCancellable? {
        return await repository.getSupplysAndDemandsLive(stockInfo: stockInfo, invoke: invoke)
    }
    
    @BackgroundActor
    func deleteSupplyDemand(supplyDemand: SupplyDemand) async -> Int {
        return await repository.deleteSupplyDemand(supplyDemand: supplyDemand)
    }
    
}
