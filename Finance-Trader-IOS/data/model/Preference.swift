import Foundation
import RealmSwift

class Preference : Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var ketString: String
    @Persisted var value: String

    override init() {
        super.init()
        ketString = ""
        value = ""
    }
    
    convenience init(ketString: String, value: String) {
        self.init()
        self.ketString = ketString
        self.value = value
    }

}
