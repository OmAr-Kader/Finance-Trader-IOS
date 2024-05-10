import SwiftUI

struct ListingStockScreen : View {
    
    @StateObject var app: AppObserve
    let trader: TraderData
    let stockInfoData: StockInfoData?
    
    @Inject
    private var theme: Theme
    
    @State private var imageUrl: String = ""
    @State private var name: String = ""
    @State private var symbol: String = ""
    @State private var shares: String = ""
    @State private var price: String = ""
    
    @StateObject private var obs: ListingStockObserve = ListingStockObserve()
    @State private var toast: Toast? = nil

    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                Spacer().frame(height: 40)
                Button {
                    
                } label: {
                    ImageAsset(icon: "image", tint: theme.textColor).padding().frame(width: 100, height: 100).overlay {
                        RoundedRectangle(cornerRadius: 16).stroke(theme.primary, lineWidth: 2).frame(width: 100, height: 100)
                    }
                }.onStart().padding()
                OutlinedTextField(
                    text: self.name,
                    onChange: { it in
                        self.name = it
                        obs.checkIsPressed()
                    },
                    hint: "Enter your Company Name",
                    isError: (state.isPressed && name.isEmpty) || state.names.contains(name),
                    errorMsg: (state.isPressed && name.isEmpty) ? "Shouldn't be empty" : "Already Taken",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.default
                ).padding()
                OutlinedTextField(
                    text: self.symbol,
                    onChange: { it in
                        self.symbol = it.uppercased()
                        obs.checkIsPressed()
                    },
                    hint: "Enter your Company Symbol",
                    isError: (state.isPressed && symbol.isEmpty) || state.symbols.contains(symbol),
                    errorMsg: (state.isPressed && symbol.isEmpty) ? "Shouldn't be empty" : "Already Taken",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.default
                ).padding()
                OutlinedTextField(
                    text: self.shares,
                    onChange: { it in
                        self.shares = it
                        obs.checkIsPressed()
                    },
                    hint: "Enter your stock Shares",
                    isError: state.isPressed && Int64(shares) == nil,
                    errorMsg: "Wrong Formatted",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.numberPad
                ).padding()
                
                OutlinedTextField(
                    text: self.price,
                    onChange: { it in
                        self.price = it
                        obs.checkIsPressed()
                    },
                    hint: "Enter your desired Price",
                    isError: state.isPressed && Float64(price) == nil,
                    errorMsg: "Wrong Formatted",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.numberPad
                ).padding()
                Button {
                    guard let stockInfoData = self.stockInfoData else {
                        obs.createStock(name: name, symbol: symbol, share: shares, pri: price, traderId: trader.id) {
                            app.backPress()
                        } failed: {
                            toast = Toast(style: .error, message: "Failed")
                        }
                        return
                    }
                    obs.editStock(name: name, symbol: symbol, share: shares, pri: price, traderId: trader.id, stockInfoData: stockInfoData) {
                        app.backPress()
                    } failed: {
                        toast = Toast(style: .error, message: "Failed")
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
        }.onAppear {
            obs.loadData(stockInfo: stockInfoData)

            guard let stockInfoData = self.stockInfoData else  {
                return
            }
            imageUrl = stockInfoData.name
            name = stockInfoData.name
            symbol = stockInfoData.symbol
            shares = String(stockInfoData.numberOfShares)
            price = String(stockInfoData.stockPrice)
        }.toastView(toast: $toast)
            .background(theme.backDark)
            .withCustomBackButton {
                app.backPress()
            }.toolbarRole(.navigationStack)
    }
}
