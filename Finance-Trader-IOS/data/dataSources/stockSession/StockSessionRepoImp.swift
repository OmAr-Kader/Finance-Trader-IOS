import Foundation
import RealmSwift
import Combine

class StockSessionRepoImp : BaseRepoImp, StockSessionRepo {
    
    func insertStockSession(_ stock: StockSession, _ invoke: @escaping ((StockSession?) async -> Unit)) async {
        await invoke(await insert(stock).value)
    }
    
    func updateSession(id: String, stockData: StockData) async -> ResultRealm<StockSession?> {
        return await edit(try! ObjectId(string: id)) { it in
            it.copy(stockData)
        }
    }
    
    func getSessionLive(stockId: String, invoke: @escaping (StockSession?) -> Unit) async -> AnyCancellable? {
        return await querySingleFlow(
            invoke,
            "getSessionLive\(stockId)",
            "%K == %@",
            "stockId", NSString(string: stockId)
        )
    }
    
    @BackgroundActor
    func getAStockSession(
        stockId: String,
        stringData: String,
        invoke: (ResultRealm<StockSession?>) -> Unit
    ) async {
        await querySingle(
            invoke,
            "getAStockSession\(stockId + stringData)",
            "%K == %@ AND %K == %@",
            "stockId", NSString(string: stockId),
            "stringData", NSString(string: stringData)
        )
    }
    
    func getStockSessions(stockId: String, stringData: [String], stockSessions: (ResultRealm<[StockSession]>) -> Unit) async {
        let filterArguments = NSMutableArray()
        filterArguments.add(stringData)
        filterArguments.addObjects(from: stringData)
        await queryLess(stockSessions,
            "%K == %@ AND %K IN %@",
            "stockId", NSString(string: stockId),
            "stringData", filterArguments
        )
    }
    
    @BackgroundActor
    func getStockSessions(stockId: String, dateScope: Date, invoke: @escaping (ResultRealm<StockSession?>) -> Unit) async {
        await querySingle(
            invoke,
            "getStockSessions\(stockId)\(dateScope.timeIntervalSince1970)",
            "%K == %@ AND %K > %@", "stockId",
            NSString(string: stockId), "dateSession", NSDate(timeIntervalSince1970: dateScope.timeIntervalSince1970)
        )
    }
    
    @BackgroundActor
    func getAllStockSessions(
        stockId: String,
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        await queryLess(
            stockSessions,
            "%K == %@",
            //"%K == %@ AND %K > %@",
            "stockId", NSString(string: stockId)//,
            //"dateSession", NSDate(timeIntervalSince1970: (currentTime - (84 * 86400000)).toStrDMY.toTimeDate().timeIntervalSince1970)
        )
    }

    func getStocksSessions(stockId: [String], stringData: [String], stockSessions: (ResultRealm<[StockSession]>) -> Unit) async {
        let stringDataArguments = NSMutableArray()
        stringDataArguments.addObjects(from: stringData)
        let stockIdArguments = NSMutableArray()
        stockIdArguments.addObjects(from: stockId)
        await queryLess(stockSessions,
            "%K IN %@ AND %K IN %@",
            "stockId", stockIdArguments,
            "stringData", stringDataArguments
        )
    }
    
    @BackgroundActor
    func getAllStocksSessions(
        stockId: [String],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        let stockIdArguments = NSMutableArray()
        stockIdArguments.addObjects(from: stockId)
        await queryLess(stockSessions,
            "%K IN %@",
            "stockId", stockIdArguments
        )
    }
    
}

