import SwiftUI

struct ExchangeScreen : View {
    @StateObject var app: AppObserve

    @Inject
    private var theme: Theme
    
    @StateObject private var obs: ExchangeObserve = ExchangeObserve()
    
    var body: some View {
        FullZStack {
            
        }
    }
}
