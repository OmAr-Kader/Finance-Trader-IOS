import Foundation
import RealmSwift

struct Project : ScopeFunc {
    let realmApi: RealmApi    
    let preference: PreferenceData
    let trader: TraderUserData
    let stockSession: StockSessionData
    let stockInfo: StockInformationData
    let supplyDemand: SupplyAndDemandData
    let article: ArticleStockData
}
