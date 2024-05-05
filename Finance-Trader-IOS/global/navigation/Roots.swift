import SwiftUI

extension View {
    
    @ViewBuilder func targetScreen(
        _ target: Screen,
        _ app: AppObserve
    ) -> some View {
        switch target {
        case .SPLASH_SCREEN_ROUTE :
            SplashScreen(app: app)
        case .SIGN_ROUTE:
            SignScreen(app: app)
        case .HOME_TRADER_ROUTE(let traderData) :
            HomeTrader(app: app, traderData: traderData)
        case .STOCK_SCREEN_ROUTE(let traderData, let stockId):
            StockScreen(app: app, trader: traderData, stockId: stockId)
        case .LISTING_STOCK_ROUTE(let traderData, let stockInfoData):
            ListingStockScreen(app: app, trader: traderData, stockInfoData: stockInfoData)
        }
    }
}

enum Screen : Hashable {
    
    case SPLASH_SCREEN_ROUTE
    case SIGN_ROUTE
    case HOME_TRADER_ROUTE(traderData: TraderData)
    case STOCK_SCREEN_ROUTE(traderData: TraderData, stockId: String)
    case LISTING_STOCK_ROUTE(traderData: TraderData, stockInfoData: StockInfoData?)
}


protocol ScreenConfig {}

class SplashConfig: ScreenConfig {
    
}
