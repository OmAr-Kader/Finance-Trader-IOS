import Foundation
import RealmSwift
import SwiftUI

class SignObserve  : ObservableObject {
    
    @Inject
    private var project: Project
    
    private var scope = Scope()
    
    @MainActor
    @Published var state = State()
    
    @MainActor
    func setIsLogin(_ it: Bool) {
        self.state = self.state.copy(isLogin: it, isPressed: false)
    }
 
    @MainActor
    func login(
        email: String,
        password: String,
        invoke: @escaping @BackgroundActor (TraderData) -> Unit,
        failed: @escaping @MainActor (String) -> Unit
    ) {
        if (!isNetworkAvailable()) {
            failed("Failed: Internet is disconnected")
            return
        }
        
        if password.isEmpty || email.isEmpty {
            withAnimation {
                self.state = self.state.copy(isPressed: true)
            }
            return
        }
        self.state = self.state.copy(isLoading: true)
        doLogIn(email: email, password: password, invoke, failed)
    }

    private func doLogIn(
       email: String,
       password: String,
       _ invoke: @escaping @BackgroundActor (TraderData) -> Unit,
       _ failed: @escaping @MainActor (String) -> Unit
    ) {
        self.loginRealm(email: email, password: password) { user in
            if user == nil {
                self.scope.launchMain {
                    self.state = self.state.copy(isLoading: false)
                    failed("Failed")
                }
                return
            }
            self.scope.launchRealm {
                await self.project.trader.getTrader(
                    email: email
                ) { r in
                    guard let trader = r.value else {
                        self.scope.launchMain {
                            self.state = self.state.copy(isLoading: false)
                            failed("Failed")
                        }
                        return
                    }
                    invoke(TraderData(trader: trader))
                    self.scope.launchMain {
                        self.state = self.state.copy(isLoading: false)
                    }
                }
            }
        }
    }
   
    
    @MainActor
    func signUp(
        name: String,
        email: String,
        password: String,
        invoke: @escaping @BackgroundActor (TraderData) -> Unit,
        failed: @escaping @MainActor (String) -> Unit
    ) {
        if (!isNetworkAvailable()) {
            failed("Failed: Internet is disconnected")
            return
        }
        if password.isEmpty || email.isEmpty || name.isEmpty {
            withAnimation {
                self.state = self.state.copy(isPressed: true)
            }
            return
        }
        self.state = self.state.copy(isLoading: true)
        doSignUp(name: name, email: email, password: password, invoke, failed)
    }
        
    private func doSignUp(
        name: String,
        email: String,
        password: String,
        _ invoke: @escaping @BackgroundActor (TraderData) -> Unit,
        _ failed: @escaping @MainActor (String) -> Unit
    ) {
        self.realmSignIn(email: email, password: password, failed: failed) { user in
            self.scope.launchRealm {
                await self.project.trader.insertTrader(Trader(traderData: TraderData(id: "", name: name, email: email, accountType: 1))) { trader in
                    guard let trader else {
                        self.scope.launchMain {
                            self.state = self.state.copy(isLoading: false)
                            failed("Failed")
                        }
                        return
                    }
                    invoke(TraderData(trader: trader))
                }
            }
        }
    }
    
    private func realmSignIn(
        email: String,
        password: String,
        failed: @escaping @MainActor (String) -> Unit,
        invoke: @escaping (User?) -> Unit
    ) {
        self.project.realmApi.realmApp.emailPasswordAuth.registerUser(
                email: email, password: password
        ) { (error) in
            if error != nil {
                if (error!.localizedDescription.contains("existing")) {
                    self.scope.launchMain {
                        self.state = self.state.copy(isLoading: false)
                        failed("Failed: Already Exists")
                    }
                } else {
                    invoke(nil)
                }
            } else {
                self.loginRealm(email: email, password: password) { user in
                    invoke(user)
                }
            }
        }
    }
    
    private func loginRealm(email: String, password: String, invoke: @escaping (User?) -> Unit) {
        self.project.realmApi.realmApp.login(
            credentials: Credentials.emailPassword(
                email: email,
                password: password
            )
        ) { (result) in
            switch result {
            case .failure( _):
                invoke(nil)
            case .success(let user):
                invoke(user)
            }
        }
    }
    
    private func signUpRealm(email: String, password: String, invoke: @escaping (Int) -> Unit) {
        self.project.realmApi.realmApp.emailPasswordAuth.registerUser(
            email: email, password: password
        ) { (error) in
            invoke(error == nil ? REALM_SUCCESS : REALM_FAILED)
        }
    }
    
    @MainActor
    func checkIsPressed() {
        if self.state.isPressed {
            self.state = self.state.copy(isPressed: false)
        }
    }
    
    struct State {
        
        var trader: TraderData = TraderData()
        var isLoading: Bool = false
        var isLogin: Bool = true
        var isPressed: Bool = false

        mutating func copy(
            trader: TraderData? = nil,
            isLoading: Bool? = nil,
            isLogin: Bool? = nil,
            isPressed: Bool? = nil
        ) -> Self {
            self.trader = trader ?? self.trader
            self.isLoading = isLoading ?? self.isLoading
            self.isLogin = isLogin ?? self.isLogin
            self.isPressed = isPressed ?? self.isPressed
            return self
        }
    }
    
}
