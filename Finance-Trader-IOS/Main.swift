import SwiftUI

struct Main: View {
    @StateObject var app: AppObserve
    
    @Inject
    private var theme: Theme

    var body: some View {
        let isSplash = app.state.homeScreen == Screen.SPLASH_SCREEN_ROUTE
        ZStack {
            NavigationStack(path: $app.navigationPath) {
                targetScreen(
                    app.state.homeScreen, app
                ).navigationDestination(for: Screen.self) { route in
                    targetScreen(route, app).toolbar(.hidden, for: .navigationBar)
                }
            }.prepareStatusBarConfigurator(
                isSplash ? theme.background : theme.primary, isSplash, theme.isDarkStatusBarText
            )
        }.background(theme.background).ignoresSafeArea()
    }
}

#Preview {
    VStack {
        Main(app: AppObserve())
    }
}


struct SplashScreen : View {
    
    @Inject
    private var theme: Theme
    
    @StateObject var app: AppObserve

    @State private var scale: Double = 1
    @State private var width: CGFloat = 50
  
    var body: some View {
        FullZStack {
            Image(
                uiImage: UIImage(
                    named: "AppIcon"
                )?.withTintColor(
                    UIColor(theme.textColor)
                ) ?? UIImage()
            ).resizable().cornerRadius(25)
                .scaleEffect(scale)
                .frame(width: width, height: width, alignment: .center)
                .onAppear {
                    withAnimation() {
                        width = 150
                    }
                    app.findUserBase { it in
                        guard let it else {
                            app.navigateHome(.SIGN_ROUTE)
                            return
                        }
                        app.navigateHome(.HOME_TRADER_ROUTE(traderData: it))
                    }
                }
        }.background(theme.background)
    }
}
