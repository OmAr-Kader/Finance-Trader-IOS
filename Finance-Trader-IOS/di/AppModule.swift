import Foundation
import RealmSwift
import SwiftUI
import Swinject
//https://github.com/realm/realm-swift
//https://github.com/firebase/firebase-ios-sdk
//https://github.com/Swinject/Swinject
//https://github.com/onevcat/RandomColorSwift.git

func buildContainer() -> Container {
    let container = Container()
    let realmApi = RealmApi(realmApp: App(id: REALM_APP_ID))
    let pro = Project(
        realmApi: realmApi,
        preference: PreferenceData(repository: PrefRepoImp(realmApi: realmApi)),
        trader: TraderUserData(repository: TraderRepoImp(realmApi: realmApi)),
        stockSession: StockSessionData(repository: StockSessionRepoImp(realmApi: realmApi)),
        stockInfo: StockInformationData(repository: StockInfRepImp(realmApi: realmApi)),
        supplyDemand: SupplyAndDemandData(repository: SupplyDemandRepoImp(realmApi: realmApi))
    )
    let theme = Theme(isDarkMode: UITraitCollection.current.userInterfaceStyle.isDarkMode)
    container.register(RealmApi.self) { _  in
        return realmApi
    }.inObjectScope(.container)
    container.register(Project.self) { _  in
        return pro
    }.inObjectScope(.container)
    container.register(Theme.self) { _  in
        return theme
    }.inObjectScope(.container)
    return container
}


class Resolver {
    static let shared = Resolver()
    
    //get the IOC container
    private var container = buildContainer()
    
    func resolve<T>(_ type: T.Type) -> T {
        container.resolve(T.self)!
    }
}

@propertyWrapper
struct Inject<I> {
    let wrappedValue: I
    init() {
        self.wrappedValue = Resolver.shared.resolve(I.self)
    }
}




