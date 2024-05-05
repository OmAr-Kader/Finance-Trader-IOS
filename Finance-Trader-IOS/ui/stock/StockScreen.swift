import SwiftUI


struct StockScreen : View {
    
    @StateObject var app: AppObserve
    let trader: TraderData
    let stockId: String

    @State private var addHeight: CGFloat = 0
    @State private var negotiateHeight: CGFloat = 0

    @Inject
    private var theme: Theme
    
    @StateObject private var obs: StockObserve = StockObserve()
    
    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                Spacer().frame(height: 40)
                ScrollView {
                    LazyVStack {
                        VStack {
                            StockChartHeadView(
                                symbol: state.stock.symbol,
                                isGain: state.stock.isGain,
                                stockPrice: state.stock.lastPrice
                            ) {
                                
                            }
                            ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(ChartMode.allCases, id: \.key) { (key: ChartMode, value: String) in
                                        ChartModeItemView(selectedMode: state.stock.mode, item: (key, value)) {
                                            obs.loadStocks(mode: key)
                                        }
                                    }
                                    .animation(.default, value: state.stock.mode)
                                }
                            }.frame(height: 60)
                            ZStack {
                                switch state.stock.mode {
                                case .StockWave : StockWaveView(stock: state.stock, isLoading: state.isLoading)
                                case .StockSMA: StockSMAView(stock: state.stock, isLoading: state.isLoading)
                                case .StockEMA: StockEMAView(stock: state.stock, isLoading: state.isLoading)
                                case .StockRSI: StockRSIView(stock: state.stock, isLoading: state.isLoading)
                                case .StockTrad: StockTradView(stock: state.stock, isLoading: state.isLoading)
                                case .StockPrediction: StockPredictionView(stock: state.stock, isLoading: state.isLoading)
                                }
                                LoadingBar(isLoading: state.isLoading)
                            }.scrollDisabled(true)
                        }.background(theme.backDark).cornerRadius(15).padding(top: 15, leading: 15, bottom: 0, trailing: 15)
                        StockDetailView(stockInfo: state.stockInfo) {
                            obs.setAddSheet(true)
                        }
                        Spacer().frame(height: 15)
                        ForEach(state.supplyDemands, id: \.id) { supplyDemand in
                            SupplyDemandItemView(supplyDemand: supplyDemand) { it in
                                switch it {
                                case .IsAcceptSell: obs.sellShare(supplyDemandData: supplyDemand, trader: trader, stockInfo: state.stockInfo)
                                case .IsOwnerEdit: obs.showSupplyDemandSheet(supplyDemandData: supplyDemand)
                                case .IsBuy: obs.buyShare(supplyDemandData: supplyDemand, trader: trader, stockInfo: state.stockInfo)
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
                AddSheet(isHaveShares: state.isHaveShares) { shares, prices, isSupply in
                    
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
            BackButton {
                app.backPress()
            }
            LoadingScreen(isLoading: state.isLoading)
        }.onAppear {
            obs.loadData(trader: trader, isDarkMode: theme.isDarkMode)
        }.background(theme.background)
    }
}

struct StockChartHeadView : View {
    
    let symbol: String
    let isGain: Bool
    let stockPrice: Float64
    let onClick: () -> ()
    
    @Inject
    private var theme: Theme
    
    var body: some View {
        HStack(alignment: .center) {
            Text(symbol).foregroundStyle(theme.textColor).frame(minWidth: 80).onTapGesture {
                onClick()
            }
            HStack {
                Text("Prce:").foregroundStyle(theme.textColor).font(.subheadline)
                ImageAsset(icon: isGain ? "up" : "down", tint: isGain ? .green : .red).frame(width: 10, height: 10)
                Text(String(stockPrice) + " $").foregroundStyle(isGain ? .green : .red).font(.subheadline)
            }.padding()
        }.frame(height: 40)
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
                Text(stockInfo.name).foregroundStyle(theme.textColor).font(.headline.bold()).padding().onStart()
                Spacer()
                HStack {
                    Text("Shares:").foregroundStyle(theme.textColor).font(.subheadline)
                    Text(String(stockInfo.numberOfShares)).foregroundStyle(theme.textHintColor).font(.subheadline)
                }.padding().onStart()
                Spacer()
            }
            Spacer()
            StockHolderChartView(holders: stockInfo.stockholders).padding()
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

                }
            } else if status == .IsDemandAndIsHaveShares {
                SupplyDemandButton(text: "Accept & Sell", color: Color.red.gradient) {
                    onNavigate(.IsSellNegotiate)
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
