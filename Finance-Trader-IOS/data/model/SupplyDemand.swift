import Foundation
import RealmSwift

class SupplyDemand : Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var isSupply: Bool
    @Persisted var traderId: String
    @Persisted var stockId: String
    @Persisted var shares: Int64
    @Persisted var price: Float64

    override init() {
        super.init()
        self.isSupply = false
        self.traderId = ""
        self.stockId = ""
        self.shares = 0
        self.price = 0.00
    }
    
    convenience init(supplyDemandData: SupplyDemandData) {
        self.init()
        self._id = try! ObjectId.init(string: supplyDemandData.id)
        self.isSupply = supplyDemandData.isSupply
        self.traderId = supplyDemandData.traderId
        self.stockId = supplyDemandData.stockId
        self.shares = supplyDemandData.shares
        self.price = supplyDemandData.price
    }

}


struct SupplyDemandData {
    
    let id: String
    let isSupply: Bool
    let traderId: String
    let stockId: String
    let shares: Int64
    let price: Float64

    init(id: String, isSupply: Bool, traderId: String, stockId: String, shares: Int64, price: Float64) {
        self.id = id
        self.isSupply = isSupply
        self.traderId = traderId
        self.stockId = stockId
        self.shares = shares
        self.price = price
    }
    
    init(supplyDemand: SupplyDemand) {
        self.id = supplyDemand._id.stringValue
        self.isSupply = supplyDemand.isSupply
        self.traderId = supplyDemand.traderId
        self.stockId = supplyDemand.stockId
        self.shares = supplyDemand.shares
        self.price = supplyDemand.price
    }
}
