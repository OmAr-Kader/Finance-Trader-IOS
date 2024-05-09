import Combine

protocol PrefRepo {
    
    @BackgroundActor
    func prefs(invoke: ([Preference]) -> Unit) async
    
    @BackgroundActor
    func prefsBack(invoke: @escaping ([Preference]) -> Unit) async -> AnyCancellable?
  
    @BackgroundActor
    func insertPref(_ pref: Preference,_ invoke: @escaping ((Preference?) async -> Unit)) async
    
    @BackgroundActor
    func insertPref(_ prefs: [Preference],_ invoke: @escaping (([Preference]?) -> Unit)) async

    @BackgroundActor
    func updatePref(
        _ pref: Preference,
        _ newValue: String,
        _ invoke: @escaping (Preference?) async -> Unit
    ) async

    @BackgroundActor
    func deletePref(key: String) async -> Int
    
    @BackgroundActor
    func deletePrefAll() async -> Int
    
}
