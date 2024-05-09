import SwiftUI


struct SignScreen : View {
    
    @StateObject var app: AppObserve
    
    @Inject
    private var theme: Theme
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    @StateObject private var obs: SignObserve = SignObserve()
    @State private var toast: Toast? = nil

    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                Spacer().frame(height: 100)
                HStack(spacing: 0) {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            obs.setIsLogin(true)
                        }
                    }) {
                        Text("Log In")
                            .padding(10)
                            .frame(minWidth: 100)
                            .font(.headline)
                            .foregroundColor(state.isLogin ? .black : theme.textColor)
                            .background(
                                state.isLogin ? theme.primary.gradient : theme.backDark.gradient
                            )
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 35,
                                    bottomLeadingRadius: 35,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: 0
                                )
                            )
                            .transition(.move(edge: .trailing))
                            .animation(.easeInOut(duration: 0.5), value: state.isLogin)
                    }
                    Button(action: {
                        obs.setIsLogin(false)
                    }) {
                        Text("Sign Up")
                            .padding(10)
                            .frame(minWidth: 100)
                            .font(.headline)
                            .foregroundColor(!state.isLogin ? .black : theme.textColor)
                            .background(
                                !state.isLogin ? theme.primary.gradient : theme.backDark.gradient
                            ).clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 35,
                                    topTrailingRadius: 35
                                )
                            )
                            .transition(.move(edge: .leading))
                            .animation(.easeInOut(duration: 0.5), value: state.isLogin)
                    }
                    Spacer()
                }.padding()
                if !state.isLogin {
                    OutlinedTextField(
                        text: self.name,
                        onChange: { it in
                            self.name = it
                        },
                        hint: "Enter your Name",
                        isError: state.isPressed && name.isEmpty,
                        errorMsg: "Shouldn't be empty",
                        theme: theme,
                        cornerRadius: 15,
                        lineLimit: 1,
                        keyboardType: UIKeyboardType.default
                    ).padding()
                }
                OutlinedTextField(
                    text: self.email,
                    onChange: { it in
                        self.email = it
                    },
                    hint: "Enter your email",
                    isError: state.isPressed && email.isEmpty,
                    errorMsg: "Shouldn't be empty",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.decimalPad
                ).padding()
                OutlinedTextField(
                    text: self.password,
                    onChange: { it in
                        self.password = it
                    },
                    hint: "Enter your password",
                    isError: state.isPressed && password.isEmpty,
                    errorMsg: "Shouldn't be empty",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.numberPad
                ).padding()
                Button {
                    if !state.isLogin {
                        obs.signUp(name: name, email: email, password: password) { trader in
                            app.updateUserBase(trader: trader) {
                                app.navigateTo(Screen.HOME_TRADER_ROUTE(traderData: trader))
                            }
                        } failed: { it in
                            toast = Toast(style: .error, message: it)
                        }
                    } else {
                        obs.login(email: email, password: password) { trader in
                            app.updateUserBase(trader: trader) {
                                app.navigateTo(Screen.HOME_TRADER_ROUTE(traderData: trader))
                            }
                        } failed: { it in
                            toast = Toast(style: .error, message: it)
                        }
                    }
                } label: {
                    Text("Done")
                        .padding(10)
                        .frame(minWidth: 80)
                        .foregroundColor(.black)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 15,
                                style: .continuous
                            )
                            .fill(Color.green.gradient)
                        )
                }.padding().onBottom()
            }
            LoadingScreen(isLoading: state.isLoading)
        }.background(theme.background).toastView(toast: $toast)
    }
}
