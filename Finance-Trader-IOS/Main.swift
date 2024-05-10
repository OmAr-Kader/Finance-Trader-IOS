import SwiftUI

struct Main: View {
    @StateObject var app: AppObserve
    
    @Inject
    private var theme: Theme

    var body: some View {
        ZStack {
            NavigationStack(path: $app.navigationPath) {
                targetScreen(
                    app.state.homeScreen, app
                ).navigationDestination(for: Screen.self) { route in
                    targetScreen(route, app)
                }
            }
        }.background(theme.background)
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
                .frame(width: width, height: width, alignment: .center)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.35)) {
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
        }.background(theme.background).toolbar(.hidden)
    }
}
