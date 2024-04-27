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
    
    var navigateHome: (Screen) -> Unit {
        return { screen in
            withAnimation {
                self.state = self.state.copy(homeScreen: screen)
            }
            return ()
        }
    }
    
    func navigateTo(_ screen: Screen) {
        self.navigationPath.append(screen)
    }
    
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
    
    func signOut(_ invoke: @escaping () -> Unit,_ failed: @escaping () -> Unit) {
        scope.launchRealm {
            await self.project.preference.deletePrefAll()
            invoke()
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
    
    func updatePref(key: String, newValue: String) {
        scope.launchRealm {
            await self.updatePref(key, newValue) {
                
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
