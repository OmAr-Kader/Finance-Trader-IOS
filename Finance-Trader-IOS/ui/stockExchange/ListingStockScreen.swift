import SwiftUI

//* Change Already Token + Aleady Token Not Work + Good Night

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
                    },
                    hint: "Enter your Company Name",
                    isError: name.isEmpty || state.names.contains(name),
                    errorMsg: "Already Taken",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.default
                ).padding()
                OutlinedTextField(
                    text: self.symbol,
                    onChange: { it in
                        self.symbol = it.uppercased()
                    },
                    hint: "Enter your Compant Symbol",
                    isError: symbol.isEmpty || state.symbols.contains(symbol),
                    errorMsg: "Already Taken",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.decimalPad
                ).padding()
                OutlinedTextField(
                    text: self.shares,
                    onChange: { it in
                        self.shares = it
                    },
                    hint: "Enter your stock Shares",
                    isError: Int64(shares) == nil,
                    errorMsg: "Shouldn't be empty",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.numberPad
                ).padding()
                
                OutlinedTextField(
                    text: self.price,
                    onChange: { it in
                        self.price = it
                    },
                    hint: "Enter your desired Price",
                    isError: Float64(price) == nil,
                    errorMsg: "Shouldn't be empty",
                    theme: theme,
                    cornerRadius: 15,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.numberPad
                ).padding()
                Button {
                    if self.name.isEmpty {
                        return
                    }
                    if self.symbol.isEmpty {
                        return
                    }
                    guard let share = Int64(shares) else {
                        return
                    }
                    guard let pri = Float64(price) else {
                        return
                    }
                    guard let stockInfoData = self.stockInfoData else {
                        obs.createStock(name: name, symbol: symbol, share: share, pri: pri, traderId: trader.id) {
                            app.backPress()
                        } failed: {
                            toast = Toast(style: .error, message: "Failed")
                        }
                        return
                    }
                    obs.editStock(name: name, symbol: symbol, share: share, pri: pri, traderId: trader.id, stockInfoData: stockInfoData) {
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
            }.onAppear {
                guard let stockInfoData = self.stockInfoData else  {
                    return
                }
                imageUrl = stockInfoData.name
                name = stockInfoData.name
                symbol = stockInfoData.symbol
                shares = String(stockInfoData.numberOfShares)
                price = String(stockInfoData.stockPrice)
            }
            LoadingScreen(isLoading: state.isLoading)
        }.toastView(toast: $toast)
            .background(theme.backDark)
            .withCustomBackButton {
                app.backPress()
            }.toolbarRole(.navigationStack)
    }
}
