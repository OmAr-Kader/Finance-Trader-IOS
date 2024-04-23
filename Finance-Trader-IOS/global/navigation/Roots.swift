import SwiftUI

extension View {

    @ViewBuilder func targetScreen(
        _ target: Screen,
        _ app: AppObserve
    ) -> some View {
        switch target {
        case .SPLASH_SCREEN_ROUTE :
            SplashScreen(app: app)
        case .HOME_TRADER_ROUTE :
            HomeTrader(app: app)
        }
    }
}

enum Screen {
    
    case SPLASH_SCREEN_ROUTE
    case HOME_TRADER_ROUTE
}


protocol ScreenConfig {}

class SplashConfig: ScreenConfig {
    
}

