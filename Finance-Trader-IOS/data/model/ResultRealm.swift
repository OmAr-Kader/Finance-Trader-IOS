import Foundation

struct ResultRealm<T> : ScopeFunc {
    let value: T
    let result: Int
}
