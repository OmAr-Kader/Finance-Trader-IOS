import Combine

class PreferenceData {
    
    var repository: PrefRepo
    
    init(repository: PrefRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func prefs(invoke: ([Preference]) -> Unit) async {
        await repository.prefs(invoke: invoke)
    }
    
    @BackgroundActor
    func prefsBack(invoke: @escaping ([Preference]) -> Unit) async -> AnyCancellable? {
        return await repository.prefsBack(invoke: invoke)
    }
    
    @BackgroundActor
    func insertPref(
        _ pref: Preference,
        _ invoke: @escaping (Preference?) async -> Unit
    ) async {
        await repository.insertPref(pref, invoke)
    }
    
    @BackgroundActor
    func insertPref(_ prefs: [Preference],_ invoke: @escaping (([Preference]?) -> Unit)) async {
        await repository.insertPref(prefs, invoke)
    }

    @BackgroundActor
    func updatePref(
        _ pref: Preference,
        _ newValue: String,
        _ invoke: @escaping (Preference?) async -> Unit
    ) async {
        await repository.updatePref(pref, newValue, invoke)
    }

    @BackgroundActor
    func deletePref(key: String) async -> Int {
        return await repository.deletePref(key: key)
    }
    
    @discardableResult
    @BackgroundActor
    func deletePrefAll() async -> Int {
        return await repository.deletePrefAll()
    }
}
