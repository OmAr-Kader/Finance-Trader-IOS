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
        case .STOCK_SCREEN_ROUTE(let traderData, let stockId):
            StockScreen(app: app, trader: traderData, stockId: stockId)
        }
    }
}

enum Screen : Hashable {
    
    case SPLASH_SCREEN_ROUTE
    case HOME_TRADER_ROUTE
    case STOCK_SCREEN_ROUTE(traderData: TraderData, stockId: String)
}


protocol ScreenConfig {}

class SplashConfig: ScreenConfig {
    
}
