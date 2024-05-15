import Foundation
import Combine

protocol StockInfoRep {
    
    @BackgroundActor
    func insertStockInfo(_ stockInfo: StockInfo,_ invoke: @escaping @BackgroundActor (StockInfo?) async -> Unit) async
    
    @BackgroundActor
    func updateStockInfo(
        stockInfoData: StockInfoData
    ) async -> ResultRealm<StockInfo?>
    
    @BackgroundActor
    func getStockInfoLive(id: String, invoke: @escaping @BackgroundActor (StockInfo?) -> Unit) async -> AnyCancellable?
    
    @BackgroundActor
    func getStockInfo(
        id: String,
        invoke: @BackgroundActor (ResultRealm<StockInfo?>) -> Unit
    ) async
    
    @BackgroundActor
    func getAllStockInfo(
        invoke: @BackgroundActor (ResultRealm<[StockInfo]>) -> Unit
    ) async
    
    @BackgroundActor
    func getTraderStocksInfoLive(
        traderId: String,
        invoke: @escaping @BackgroundActor ([StockInfo]) -> Unit
    ) async -> AnyCancellable?
    
    @BackgroundActor
    func getAllStockInfoLive(
        invoke: @escaping @BackgroundActor ([StockInfo]) -> Unit
    ) async -> AnyCancellable?
    
}
