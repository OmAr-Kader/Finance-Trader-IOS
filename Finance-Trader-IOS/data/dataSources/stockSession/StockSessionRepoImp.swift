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
    
    func getStockSessions(stockId: String, stringData: [String], stockSessions: (ResultRealm<[StockSession]>) -> Unit) async {
        let filterArguments = NSMutableArray()
        filterArguments.add(stringData)
        filterArguments.addObjects(from: stringData)
        await queryLess(stockSessions,
            "%K == %@ AND ANY %K IN %@",
            "stockId", NSString(string: stockId),
            "stringData", filterArguments
        )
    }

    func getStocksSessions(stockId: [String], stringData: [String], stockSessions: (ResultRealm<[StockSession]>) -> Unit) async {
        let stringDataArguments = NSMutableArray()
        stringDataArguments.addObjects(from: stringData)
        let stockIdArguments = NSMutableArray()
        stockIdArguments.addObjects(from: stockId)
        await queryLess(stockSessions,
            "%K IN %@ AND ANY %K IN %@",
            "stockId", stockIdArguments,
            "stringData", stringDataArguments
        )
    }
    
}

