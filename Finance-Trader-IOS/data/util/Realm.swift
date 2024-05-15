import Foundation
import RealmSwift
import os


let REALM_SUCCESS: Int = 1
let REALM_FAILED: Int = -1

let COURSE_TYPE_FOLLOWED: Int = 0
let COURSE_TYPE_ENROLLED: Int = 1

var listOfOnlyLocalSchemaRealmClass: [ObjectBase.Type] {
    return [Preference.self]
}


var listOfSchemaRealmClass: [ObjectBase.Type] {
    return [
        StockSession.self,
        StockInfo.self,
        Trader.self,
        SupplyDemand.self,
        Article.self
    ]
}

var listOfSchemaEmbeddedRealmClass: [ObjectBase.Type] {
    return [
        StockPoint.self,
        StockHolder.self,
        Negotiate.self,
        ArticleText.self
    ]
}

public func log(_ it: String, tag: String = "") {
    print("==> \(tag) \(it)")
}

public func logger(_ tag: String,_ it: String) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    logger.log("==> \(tag) \(it)")
}

public func loggerError(_ tag: String,_ it: String) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    logger.log("==> \(tag) \(it)")
}

extension Realm {
    
    func write<Result>(
        _ block: (Self) -> Result,
        onSucces: () -> Unit,
        onFailed: () -> Unit
    ) {
        do {
            try self.write {
                block(self)
            }
            onSucces()
        } catch {
            print("insertPref" + error.localizedDescription)
            onFailed()
        }
    }

}

protocol ForData : Identifiable, Decodable, Hashable {
    
}

protocol ForSubData : Decodable, Hashable {
    
}
