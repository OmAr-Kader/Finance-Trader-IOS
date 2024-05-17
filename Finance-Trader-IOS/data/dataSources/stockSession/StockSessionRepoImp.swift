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
    
    func getSessionLive(stockInfo: StockInfo, invoke: @escaping (StockSession?) -> Unit) async -> AnyCancellable? {
        return await querySingleFlow(
            invoke,
            "getSessionLive\(stockInfo._id.stringValue)",
            "%K == %@",
            "stockInfo", stockInfo
        )
    }
    
    @BackgroundActor
    func getAStockSession(
        stockInfo: StockInfo,
        stringData: String,
        invoke: (ResultRealm<StockSession?>) -> Unit
    ) async {
        await querySingle(
            invoke,
            "getAStockSession\(stockInfo._id.stringValue + stringData)",
            "%K == %@ AND %K == %@",
            "stockInfo", stockInfo,
            "stringData", NSString(string: stringData)
        )
    }
    
    func getStockSessions(stockInfo: StockInfo, stringData: [String], stockSessions: (ResultRealm<[StockSession]>) -> Unit) async {
        let filterArguments = NSMutableArray()
        filterArguments.add(stringData)
        filterArguments.addObjects(from: stringData)
        await queryLess(stockSessions,
            "%K == %@ AND %K IN %@",
            "stockInfo", stockInfo,
            "stringData", filterArguments
        )
    }
    
    @BackgroundActor
    func getStockSessions(stockInfo: StockInfo, dateScope: Date, invoke: @escaping (ResultRealm<StockSession?>) -> Unit) async {
        await querySingle(
            invoke,
            "getStockSessions\(stockInfo._id.stringValue)\(dateScope.timeIntervalSince1970)",
            "%K == %@ AND %K > %@",
            "stockInfo", stockInfo,
            "dateSession", NSDate(timeIntervalSince1970: dateScope.timeIntervalSince1970)
        )
    }
    
    @BackgroundActor
    func getAllStockSessions(
        stockInfo: StockInfo,
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        await queryLess(
            stockSessions,
            "%K == %@",
            //"%K == %@ AND %K > %@",
            "stockInfo", stockInfo//,
            //"dateSession", NSDate(timeIntervalSince1970: (currentTime - (84 * 86400000)).toStrDMY.toTimeDate().timeIntervalSince1970)
        )
    }

    func getStocksSessions(stockInfo: [StockInfo], stringData: [String], stockSessions: (ResultRealm<[StockSession]>) -> Unit) async {
        let stringDataArguments = NSMutableArray()
        stringDataArguments.addObjects(from: stringData)
        let stockInfoArguments = NSMutableArray()
        stockInfoArguments.addObjects(from: stockInfo)
        await queryLess(stockSessions,
            "%K IN %@ AND %K IN %@",
            "stockInfo", stockInfoArguments,
            "stringData", stringDataArguments
        )
    }
    
    @BackgroundActor
    func getAllStocksSessions(
        stockInfo: [StockInfo],
        stockSessions: (ResultRealm<[StockSession]>) -> Unit
    ) async {
        let stockInfoArguments = NSMutableArray()
        stockInfoArguments.addObjects(from: stockInfo)
        await queryLess(stockSessions,
            "%K IN %@",
            "stockInfo", stockInfoArguments
        )
    }
    
}

