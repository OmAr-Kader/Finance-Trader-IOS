import Foundation
import Combine

class TraderUserData {
    
    let repository: TraderRepo
    
    init(repository: TraderRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func insertTrader(_ trader: Trader,_ invoke: @escaping ((Trader?) async -> Unit)) async {
        await repository.insertTrader(trader, invoke)
    }
    
    @BackgroundActor
    func getTrader(
        email: String,
        trader: (ResultRealm<Trader?>) -> Unit
    ) async {
        await repository.getTrader(email: email, trader: trader)
    }
    
}
