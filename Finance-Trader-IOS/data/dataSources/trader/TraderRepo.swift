import Combine

protocol TraderRepo {

    @BackgroundActor
    func insertTrader(_ trader: Trader,_ invoke: @escaping ((Trader?) async -> Unit)) async
    
    @BackgroundActor
    func getTrader(
        email: String,
        trader: (ResultRealm<Trader?>) -> Unit
    ) async

}
