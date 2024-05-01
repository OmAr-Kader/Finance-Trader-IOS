import Foundation
import RealmSwift

class Trader : Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String

    override init() {
        super.init()
        self.name = ""
    }
    
    convenience init(traderData: TraderData) {
        self.init()
        self._id = try! ObjectId.init(string: traderData.id)
        self.name = traderData.name
    }

}


struct TraderData {
    
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    init(trader: Trader) {
        self.id = trader._id.stringValue
        self.name = trader.name
    }
    
}
