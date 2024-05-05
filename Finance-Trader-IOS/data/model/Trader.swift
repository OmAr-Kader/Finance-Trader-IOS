import Foundation
import RealmSwift

class Trader : Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var email: String
    @Persisted var accountType: Int

    override init() {
        super.init()
        self.name = ""
        self.email = ""
        self.accountType = -1
    }
    
    @BackgroundActor
    convenience init(traderData: TraderData) {
        self.init()
        if !traderData.id.isEmpty {
            self._id = try! ObjectId.init(string: traderData.id)
        }
        self.name = traderData.name
        self.email = traderData.email
        self.accountType = traderData.accountType
    }

}

struct TraderData : Hashable {
    
    let id: String
    let name: String
    let email: String
    let accountType: Int

    init() {
        self.id = ""
        self.name = ""
        self.email = ""
        self.accountType = -1
    }
    
    init(id: String, name: String, email: String, accountType: Int) {
        self.id = id
        self.name = name
        self.email = email
        self.accountType = accountType
    }
    
    @BackgroundActor
    init(trader: Trader) {
        self.id = trader._id.stringValue
        self.name = trader.name
        self.email = trader.email
        self.accountType = trader.accountType
    }

}
