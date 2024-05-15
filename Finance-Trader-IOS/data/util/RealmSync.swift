import Foundation
import RealmSwift

class RealmApi {
    
    let realmApp: App
    private var realmLocal: Realm? = nil
    private var realmCloud: Realm? = nil
    
    init(realmApp: App) {
        self.realmApp = realmApp
    }
    
    @BackgroundActor
    func local() async -> Realm? {
        guard let realmLocal else {
            do {
                var config = Realm.Configuration.defaultConfiguration
                config.objectTypes = listOfOnlyLocalSchemaRealmClass
                config.schemaVersion = 1
                config.deleteRealmIfMigrationNeeded = false
                config.shouldCompactOnLaunch = { _,_ in
                    true
                }
                let realm = try await Realm(
                    configuration: config,
                    actor: BackgroundActor.shared
                )
                realmLocal = realm
                return realm
            } catch {
                return nil
            }
        }
        return realmLocal
    }
    
    @BackgroundActor
    func cloud() async -> Realm? {
        guard let realmCloud else {
            do {
                let user = realmApp.currentUser
                if user != nil {
                    realmCloud = try await Realm(
                        configuration: realmApp.currentUser!.initialSubscriptionBlock,
                        actor: BackgroundActor.shared,
                        downloadBeforeOpen: .always
                    )
                    return realmCloud
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
        return realmCloud
    }
}

extension User {
    
    var initialSubscriptionBlock: Realm.Configuration {
        var config = self.flexibleSyncConfiguration(initialSubscriptions: { subs in
            subs.append(QuerySubscription<StockSession>())
            subs.append(QuerySubscription<StockInfo>())
            subs.append(QuerySubscription<SupplyDemand>())
            subs.append(QuerySubscription<Article>())
            subs.append(QuerySubscription<Trader>())
       })
        config.objectTypes = listOfSchemaRealmClass + listOfSchemaEmbeddedRealmClass
        config.schemaVersion = SCHEMA_VERSION
        config.eventConfiguration?.errorHandler = { error in
            print(error.localizedDescription)
        }
        return config
    }
}
 
@globalActor actor BackgroundActor: GlobalActor {
    static var shared = BackgroundActor()
}

