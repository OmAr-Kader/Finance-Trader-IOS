import Foundation
import Combine

protocol StockInfoRep {
    
    @BackgroundActor
    func insertStockInfo(_ stockInfo: StockInfo,_ invoke: @escaping ((StockInfo?) async -> Unit)) async
    
    @BackgroundActor
    func updateSession(
        stockInfoData: StockInfoData
    ) async -> ResultRealm<StockInfo?>
    
    @BackgroundActor
    func getStockInfoLive(id: String, invoke: @escaping (StockInfo?) -> Unit) async -> AnyCancellable?
    
    @BackgroundActor
    func getAllStockInfo(
        invoke: (ResultRealm<[StockInfo]>) -> Unit
    ) async
    
}
