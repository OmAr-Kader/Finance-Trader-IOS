import Foundation

let SCHEMA_VERSION: UInt64 = 0
let MIN_CHART_SCALE: Float64 = 0.99
let MAX_CHART_SCALE: Float64 = 1.01
let DEFAULT_TIME_SCOPE: Int64 = 3
let PREF_USER_ID: String = "userId"
let PREF_USER_NAME: String = "userName"
let PREF_USER_EMAIL: String = "userEmail"
let PREF_USER_TYPE: String = "userType"


let timeScopes: [(key: Int64 , value: String)] = [
    (3, "Last 3 days"),
    (7, "last week"),
    (14, "last 2 weeks"),
    (28, "last 4 weeks"),
    (84, "last 12 weeks"),
]
