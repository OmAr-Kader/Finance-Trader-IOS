import SwiftUI

//* Sale toDMY if Specifc Day => Hours
//* Stock isLoasing + Candlestick

struct StockScreen : View {
    
    @StateObject var app: AppObserve
    let trader: TraderData
    let stockId: String

    @State private var addHeight: CGFloat = 0
    @State private var negotiateHeight: CGFloat = 0

    @Inject
    private var theme: Theme
    
    @StateObject private var obs: StockObserve = StockObserve()
    @State private var toast: Toast? = nil

    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                ScrollView {
                    LazyVStack {
                        ChartMainView(
                            stock: state.stock, traderData: trader, onModeChange: obs.loadStockMode, onTimeScope: obs.loadTimeScope, onNavigate: {_ in }
                        ) {
                            Spacer(minLength: 0)
                        }
                        StockDetailView(stockInfo: state.stockInfo) {
                            obs.setAddSheet(true)
                        }
                        Spacer().frame(height: 15)
                        ForEach(state.supplyDemands, id: \.id) { supplyDemand in
                            SupplyDemandItemView(supplyDemand: supplyDemand) { it in
                                switch it {
                                case .IsAcceptSell: obs.sellShare(demmandData: supplyDemand, fromTrader: trader.id, stockInfo: state.stockInfo
                                ) {} failed: {
                                    toast = Toast(style: .error, message: "Failed")
                                }
                                case .IsOwnerEdit: obs.showSupplyDemandSheet(supplyDemandData: supplyDemand)
                                case .IsOwnerDelete: obs.deleteSuppltDemand(supplyDemandData: supplyDemand) {
                                    
                                } failed: {
                                    toast = Toast(style: .error, message: "Failed")
                                }

                                case .IsBuy: obs.buyShare(supplyData: supplyDemand, toTrader: trader.id, stockInfo: state.stockInfo
                                ) {} failed: {
                                    toast = Toast(style: .error, message: "Failed")
                                }
                                case .IsBuyNegotiate: obs.showNegotiateSheet(supplyDemandData: supplyDemand)
                                case .IsSellNegotiate: obs.showNegotiateSheet(supplyDemandData: supplyDemand)
                                case .IsSellNegotiateNotEnough: obs.showNegotiateSheet(supplyDemandData: supplyDemand)
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
            .bottomSheet(
                theme.backDarkSec,
                Binding(get: {
                    state.isAddSheet
                }, set: { it in
                    obs.setAddSheet(it)
                }),
                $addHeight
            ) {
                AddSheet(addSheetMode: state.isHaveShares ? .SupplyAndDemand : .Demand) { shares, prices, isSupply in
                    obs.createSupply(isSupply: isSupply, traderId: trader.id, stockId: stockId, shares: shares, price: prices) {
                        obs.setAddSheet(false)
                    } failed: {
                        toast = Toast(style: .error, message: "Failed")
                    }
                }
            }
            .bottomSheet(
                theme.backDarkSec,
                Binding(get: {
                    state.isNegotiateSheet
                }, set: { it in
                    obs.setNegotiateSheet(it)
                }),
                $negotiateHeight
            ) {
                NegotiateSheet(supplyDemandData: state.supplyDemandData) { supplyDemandData, shares, prices in
                    obs.pushNegotiate(supplyDemandData: supplyDemandData, trader: trader)
                }
            }
            LoadingScreen(isLoading: state.isLoading)
        }.onAppear {
            obs.loadData(stockId: stockId, trader: trader, isDarkMode: theme.isDarkMode)
        }.toastView(toast: $toast)
            .background(theme.background)
            .withCustomBackButton {
                app.backPress()
            }.toolbarRole(.navigationStack)
    }
}


struct StockDetailView : View {
    
    let stockInfo: StockInfoData
    let onAddClicked: () -> ()
    
    @Inject
    private var theme: Theme
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                HStack {
                    ImageCacheView(stockInfo.logoUrl, contentMode: .fill)
                        .frame(width: 60, height: 20)
                    Spacer().frame(width: 5)
                    Text(stockInfo.name).foregroundStyle(theme.textColor).font(.headline.bold())
                    Spacer()
                    ButtonCurvedGradient(text: "Subscribe", cornerRadius: 35, textColor: theme.primary, color: theme.backDark.gradient) {
                        
                    }
                    Spacer().frame(width: 20)
                }
                HStack {
                    Text("Shares:").foregroundStyle(theme.textColor).font(.subheadline)
                    Text(stockInfo.numberOfShares.toMillionOrBillon).foregroundStyle(theme.textHintColor).font(.subheadline)
                    Spacer()
                    StockHolderChartView(holders: stockInfo.stockholders)
                    Spacer().frame(width: 20)
                }
            }.padding()
            Spacer()
        }
        HStack {
            Text("Supplys And Demands")
                .foregroundStyle(theme.textColor).font(.headline.bold()).padding().onStart()
            Spacer()
            Button(action: onAddClicked) {
                ImageAsset(icon: "plus", tint: .black)
                    .frame(width: 20, height: 20)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(theme.primary))
            }
            Spacer().frame(width: 15)
        }

    }
}

struct SupplyDemandItemView : View {
    
    let supplyDemand: SupplyDemandData
    let onNavigate: (SupplyDemandScreenMode) -> Unit

    @Inject
    private var theme: Theme
    
    var body: some View {
        VStack {
            Spacer().frame(height: 10)
            HStack {
                HStack {
                    Text("Shares:").foregroundStyle(theme.textColor).font(.title3)
                    Text(String(supplyDemand.shares)).foregroundStyle(theme.textHintColor).font(.title3)
                }
                Spacer()
                HStack {
                    Text("Prce:").foregroundStyle(theme.textColor).font(.title3)
                    Text(String(supplyDemand.price) + " $").foregroundStyle(theme.textColor).font(.title3)
                }
                Spacer()
            }.padding()
            SupplyDemandActios(status: supplyDemand.status, onNavigate: onNavigate)
            Spacer().frame(height: 10)
        }.background(theme.backDark)
            .cornerRadius(15).padding(top: 6, leading: 8, bottom: 6, trailing: 8)
            .overlay(alignment: .topLeading) {
                VStack {
                    Text(supplyDemand.isSupply ? "Supply" : "Demand")
                        .padding(5)
                        .foregroundColor(supplyDemand.isSupply ? theme.background : theme.textColor)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous
                            )
                            .fill(supplyDemand.isSupply ? supplyDemand.color : theme.backDarkThr)
                        ).clipped()
                        .shadow(color: theme.textColor, radius: 3, x: 0, y: 0)
                }.position(x: 70, y: 12)
            }
    }
}

struct SupplyDemandActios : View {
    
    let status: SupplyDemandCases
    let onNavigate: (SupplyDemandScreenMode) -> Unit

    @Inject
    private var theme: Theme
    
    var body: some View {
        HStack {
            Spacer()
            if status == .IsOwnerThat {
                SupplyDemandButton(text: "Edit", color: Color.green.gradient) {
                    onNavigate(.IsOwnerEdit)
                }
                Spacer()
                SupplyDemandButton(text: "Cancel", color: Color.red.gradient) {
                    onNavigate(.IsOwnerDelete)
                }
            } else if status == .IsDemandAndIsHaveShares {
                SupplyDemandButton(text: "Accept & Sell", color: Color.red.gradient) {
                    onNavigate(.IsAcceptSell)
                }
                Spacer()
                SupplyDemandButton(text: "Negotiate", color: theme.primary.gradient) {
                    onNavigate(.IsSellNegotiate)
                }
            } else if status == .IsDemandAndNotHaveEnough {
                SupplyDemandButton(text: "Negotiate", color: theme.primary.gradient) {
                    onNavigate(.IsSellNegotiateNotEnough)
                }
            } else if status == .IsDemandAndNotHave {
                VStack {}
            } else if status == .IsSupply {
                SupplyDemandButton(text: "Buy", color: Color.green.gradient) {
                    onNavigate(.IsBuy)
                }
                Spacer()
                SupplyDemandButton(text: "Negotiate", color: theme.primary.gradient) {
                    onNavigate(.IsBuyNegotiate)

                }
            }
            Spacer()
        }
    }
}

struct SupplyDemandButton : View {
    let text: String
    let color: AnyGradient
    let onTap: () -> ()
    var body: some View {
        Button(action: onTap) {
            Text(text)
                .padding(top: 7, leading: 10, bottom: 7, trailing: 10)
                .foregroundColor(.black)
                .background(
                    RoundedRectangle(
                        cornerRadius: 7,
                        style: .continuous
                    )
                    .fill(color)
                )
        }
    }
}

/*
#Preview {
    StockScreen(app: AppObserve(), trader: TraderData.init(id: "1", name: "name"), stockId: "1")
}*/
