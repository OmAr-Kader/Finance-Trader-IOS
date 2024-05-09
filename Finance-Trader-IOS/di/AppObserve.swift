import Foundation
import SwiftUI
import RealmSwift
import Combine

class AppObserve : ObservableObject {

    @Inject
    private var project: Project
        
    private var scope = Scope()

    @Published var navigationPath = NavigationPath()
    
    @Published var state = State()
            
    private var preff: Preference? = nil
    private var preferences: [Preference] = []
    private var prefsTask: Task<Void, Error>? = nil
    private var sinkPrefs: AnyCancellable? = nil

    init() {
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        prefsTask = scope.launchRealm {
            self.sinkPrefs = await self.project.preference.prefsBack { list in
                self.preferences = list
            }
        }
    }
    
    @MainActor
    var navigateHome: (Screen) -> Unit {
        return { screen in
            withAnimation {
                self.state = self.state.copy(homeScreen: screen)
            }
            return ()
        }
    }
    
    @MainActor
    func navigateTo(_ screen: Screen) {
        self.navigationPath.append(screen)
    }
    
    @MainActor
    func backPress() {
        if !self.navigationPath.isEmpty {
            self.navigationPath.removeLast()
        }
    }
    
    private func inti(invoke: @BackgroundActor @escaping ([Preference]) -> Unit) {
        scope.launchRealm {
            await self.project.preference.prefs { list in
                invoke(list)
            }
        }
    }

    func getArgument<T: ScreenConfig>(screen: Screen) -> T? {
        return state.argOf(screen)
    }

    func writeArguments(_ route: Screen,_ screenConfig: ScreenConfig) {
        state = state.copy(route, screenConfig)
    }
    
    @MainActor
    func signOut(_ invoke: @escaping @MainActor () -> Unit,_ failed: @escaping @MainActor () -> Unit) {
        scope.launchRealm {
            let result = await self.project.preference.deletePrefAll()
            if result == REALM_SUCCESS {
                self.scope.launchMain {
                    invoke()
                }
            } else {
                self.scope.launchMain {
                    failed()
                }
            }
        }
    }
    
    @MainActor
    func findUserBase(
        invoke: @escaping @MainActor (TraderData?) -> Unit
    ) {
        guard self.project.realmApi.realmApp.currentUser != nil else {
            invoke(nil)
            return
        }
        //invoke(TraderData(id: "663bb05fadc20930950c11c2", name: "Ramo", email: "ramo@gmail.com", accountType: 1))
        //invoke(TraderData(id: "6638fe6c19a7050bba0ad215", name: "Omar", email: "omar@gmail.com", accountType: 1))
        if (preferences.isEmpty) {
            inti { it in
                let userBase = self.fetchUserBase(it)
                self.scope.launchMain {
                    self.preferences = it
                    invoke(userBase)
                }
            }
        } else {
            scope.launchRealm {
                let userBase = self.fetchUserBase(self.preferences)
                self.scope.launchMain {
                    invoke(userBase)
                }
            }
        }
    }

    @BackgroundActor
    private func fetchUserBase(_ list: [Preference]) -> TraderData? {
        let id = list.last { it in it.ketString == PREF_USER_ID }?.value
        let name = list.last { it in it.ketString == PREF_USER_NAME }?.value
        let email = list.last { it in it.ketString == PREF_USER_EMAIL }?.value
        let userType = list.last { it in it.ketString == PREF_USER_TYPE }?.value
        if (id == nil || name == nil || email == nil || userType == nil) {
            return nil
        }
        return TraderData(id: id!, name: name!, email: email!, accountType: Int(userType!)!)
    }

    func updateUserBase(trader: TraderData, invoke: @escaping @MainActor () -> Unit) {
        scope.launchRealm {
            var list : [Preference] = []
            list.append(Preference(ketString: PREF_USER_ID, value: trader.id))
            list.append(Preference(ketString: PREF_USER_NAME, value: trader.name))
            list.append(Preference(ketString: PREF_USER_EMAIL, value: trader.email))
            list.append(Preference(ketString: PREF_USER_TYPE, value: String(trader.accountType)))
            await self.project.preference.insertPref(list) { newPref in
                self.inti { it in
                    self.scope.launchMain {
                        self.preferences = it
                        invoke()
                    }
                }
            }
        }
    }

    func findPrefString(
        key: String,
        value: @escaping (String?) -> Unit
    ) {
        if (preferences.isEmpty) {
            inti { it in
                let preference = it.first { it1 in it1.ketString == key }?.value
                self.scope.launchMain {
                    self.preferences = it
                    value(preference)
                }
            }
        } else {
            scope.launchRealm {
                let preference = self.preferences.first { it1 in it1.ketString == key }?.value
                self.scope.launchMain {
                    value(preference)
                }
            }
        }
    }
    
    @BackgroundActor
    private func updatePref(
        _ key: String,
        _ newValue: String,
        _ invoke: @escaping () async -> Unit
    ) async {
        await self.project.preference.insertPref(
            Preference(
                ketString: key,
                value: newValue
            )) { _ in
                await invoke()
            }
    }
    
    func updatePref(key: String, newValue: String, _ invoke: @escaping () -> ()) {
        scope.launchRealm {
            await self.updatePref(key, newValue) {
                invoke()
            }
        }
    }
    

    struct State {
        var homeScreen: Screen = .SPLASH_SCREEN_ROUTE
        var args = [Screen : any ScreenConfig]()

        mutating func copy(homeScreen: Screen) -> Self {
            self.homeScreen = homeScreen
        
            return self
        }
        
        mutating func argOf<T: ScreenConfig>(_ screen: Screen) -> T? {
            return args.first { (key: Screen, value: any ScreenConfig) in
                key == screen
            } as? T
        }
        
        mutating func copy<T : ScreenConfig>(_ screen: Screen, _ screenConfig: T) -> Self {
            args[screen] = screenConfig
            return self
        }
    }
    
    /*func hiIamJustBuilt() {
        import AVFoundation
        var player: AVAudioPlayer?
        guard let path = Bundle.main.path(forResource: "beep", ofType:"mp3") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }*/
    
    deinit {
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        sinkPrefs = nil
        prefsTask = nil
        scope.deInit()
    }
    
}
