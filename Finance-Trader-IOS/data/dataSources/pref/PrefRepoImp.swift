import Foundation
import RealmSwift
import Combine

class PrefRepoImp : PrefRepo {
    
    private let realmApi: RealmApi
    
    init(realmApi: RealmApi) {
        self.realmApi = realmApi
    }
    
    @BackgroundActor
    func prefs(invoke: ([Preference]) -> Unit) async {
        let list: [Preference] = await realmApi.local()?.objects(Preference.self).map { it in
            it
        } ?? []
        invoke(list)
    }
    
    @BackgroundActor
    func prefsBack(invoke: @escaping ([Preference]) -> Unit) async -> AnyCancellable? {
        let realm = await realmApi.local()
        guard let realm else {
            return nil
        }
        return realm.objects(Preference.self)
            .collectionPublisher
            //.receive(on: DispatchQueue.global())
            //.subscribe(on: DispatchQueue.global())
            .assertNoFailure()
            .sink { response in
                invoke(response.map { it in
                    it
                })
            }
    }
    
    @BackgroundActor
    func insertPref(_ pref: Preference,_ invoke: @escaping (Preference?) async -> Unit) async {
        do {
            let realm = await realmApi.local()
            guard let realm else {
                await invoke(nil)
                return
            }
            try await realm.asyncWrite {
                realm.add(pref, update: .all)
            }
            await invoke(pref)
        } catch let error {
            print("=====>" + error.localizedDescription)
            await invoke(nil)
        }
    }
    
    @BackgroundActor
    func insertPref(_ prefs: [Preference],_ invoke: @escaping (([Preference]?) -> Unit)) async {
        do {
            let realm = await realmApi.local()
            guard let realm else {
                invoke(nil)
                return
            }
            try await realm.asyncWrite {
                prefs.forEach { pref in
                    realm.add(pref, update: .all)
                }
            }
            invoke(prefs)
        } catch let e {
            print(e.localizedDescription)
            invoke(nil)
        }
    }
    
    @BackgroundActor
    func updatePref(
        _ pref: Preference,
        _ newValue: String,
        _ invoke: @escaping (Preference?) async -> Unit
    ) async {
        let realm = await realmApi.local()
        guard let realm else {
            await invoke(nil)
            return
        }
        let op = realm.object(ofType: Preference.self, forPrimaryKey: pref._id)
        guard let op else {
            await insertPref(pref, invoke)
            return
        }
        do {
            try await realm.asyncWrite {
                op.value = newValue
            }
            await invoke(pref)
        } catch {
            await invoke(nil)
        }
    }
    
    @BackgroundActor
    func deletePref(key: String) async -> Int {
        do {
            let realm = await realmApi.local()
            guard let realm else {
                return REALM_FAILED
            }
            let op = realm.objects(Preference.self).filter("ketString == $0", key).first
            if (op == nil) {
                return REALM_FAILED
            }
            try await realm.asyncWrite {
                realm.delete(op!)
            }
            return REALM_SUCCESS
        } catch {
            return REALM_FAILED
        }
    }
    
    @BackgroundActor
    func deletePrefAll() async -> Int {
        let realm = await realmApi.local()
        guard let realm else {
            return REALM_FAILED
        }
        do {
            try await realm.asyncWrite {
                realm.delete(realm.objects(Preference.self))
            }
            return REALM_SUCCESS
        } catch {
            return REALM_FAILED
        }
    }

}
