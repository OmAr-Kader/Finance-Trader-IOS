import Foundation

struct ResultRealm<T> : ScopeFunc {
    let value: T
    let result: Int
}
/*
enum ResultRealm<T> : ScopeFunc {
    case Succes(T)
    case Failed(String)
}
*/
