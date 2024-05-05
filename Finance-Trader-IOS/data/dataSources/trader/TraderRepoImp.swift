import Foundation
import RealmSwift
import Combine

class TraderRepoImp : BaseRepoImp, TraderRepo {
    
    func insertTrader(_ trader: Trader, _ invoke: @escaping ((Trader?) async -> Unit)) async {
        await invoke(await insert(trader).value)
    }
    
    func getTrader(email: String, trader: (ResultRealm<Trader?>) -> Unit) async {
        await querySingle(trader, "getTrader\(email)", "%K == %@", "email", email)
    }
    
}
