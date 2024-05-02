import SwiftUI


struct StockScreen : View {
    
    @StateObject var app: AppObserve
    let trader: TraderData
    let stockId: String

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
                            HStack(alignment: .center) {
                                Text(state.stockInfo.symbol).foregroundStyle(theme.textColor).frame(minWidth: 80)
                                HStack {
                                    Text("Prce:").foregroundStyle(theme.textColor).font(.subheadline)
                                    ImageAsset(icon: state.stockInfo.isGain ? "up" : "down", tint: state.stockInfo.isGain ? .green : .red).frame(width: 10, height: 10)
                                    Text(String(state.stockInfo.stockPrice) + " $").foregroundStyle(state.stockInfo.isGain ? .green : .red).font(.subheadline)
                                }.padding()
                            }.frame(height: 40)
                            ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(ChartMode.allCasesNotMulti, id: \.key) { (key: ChartMode, value: String) in
                                        Button {
                                            obs.loadStocks(mode: key)
                                        } label: {
                                            Text(value)
                                                .padding(10)
                                                .frame(minWidth: 80)
                                                .foregroundColor(state.mode == key ? .black : theme.textColor)
                                                .background(
                                                    RoundedRectangle(
                                                        cornerRadius: 15,
                                                        style: .continuous
                                                    )
                                                    .fill(state.mode == key ? theme.primary.gradient : Color.clear.gradient)
                                                )
                                        }.padding(leading: 5, trailing: 5)
                                    }
                                    .animation(.default, value: state.mode)
                                }
                            }.frame(height: 60)
                            ZStack {
                                switch state.mode {
                                case .StockWave : StockWaveView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient, isLoading: state.isLoading)
                                case .StockSMA: StockSMAView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient,  isLoading: state.isLoading)
                                case .StockEMA: StockEMAView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient,  isLoading: state.isLoading)
                                case .StockRSI: StockRSIView(stock: state.stock, stockBoarder: state.stockBoarder,  isLoading: state.isLoading)
                                case .StockTrad: StockTradView(stock: state.stock, stockBoarder: state.stockBoarder,  isLoading: state.isLoading)
                                case .StockPrediction: StockPredictionView(stock: state.stock, stockPrediction: state.stockPrediction, stockBoarder: state.stockBoarder, grad: state.gradient, gradPred: state.gradientPred,  isLoading: state.isLoading)
                                default: VStack {}
                                }
                                LoadingBar(isLoading: state.isLoading)
                            }.scrollDisabled(true)
                        }.background(theme.backDark)
                            .cornerRadius(15).padding(top: 15, leading: 15, bottom: 0, trailing: 15)
                        Text(state.stockInfo.name).foregroundStyle(theme.textColor).font(.headline.bold()).padding().onStart()
                        HStack(alignment: .top) {
                            HStack {
                                Text("Shares:").foregroundStyle(theme.textColor).font(.subheadline)
                                Text(String(state.stockInfo.numberOfShares)).foregroundStyle(theme.textHintColor).font(.subheadline)
                            }.padding()
                            Spacer()
                            StockHolderChartView(holders: state.stockInfo.stockholders).padding()
                            Spacer()
                        }
                        HStack {
                            Text("Supplys And Demands")
                                .foregroundStyle(theme.textColor).font(.headline.bold()).padding().onStart()
                            Spacer()
                            Button {

                            } label: {
                                ImageAsset(icon: "plus", tint: .black)
                                    .frame(width: 20, height: 20)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(theme.primary))
                            }
                            Spacer().frame(width: 15)
                        }
                        Spacer().frame(height: 15)
                        ForEach(state.supplyDemands, id: \.id) { supplyDemand in
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
                                SupplyDemandActios(status: supplyDemand.status) { it in
                                    
                                }
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
                        Spacer()
                    }
                }
            }
            BackButton {
                app.backPress()
            }.onTop().onStart()
        }.onAppear {
            obs.loadData(trader: trader, isDarkMode: theme.isDarkMode)
        }.background(theme.background)
    }
}

struct SupplyDemandActios : View {
    
    let status: SupplyDemandCases
    let onNavigate: (Screen) -> Unit

    @Inject
    private var theme: Theme
    
    var body: some View {
        HStack {
            Spacer()
            if status == .IsOwnerThat {
                SupplyDemandButton(text: "Edit", color: Color.green.gradient) {
                    
                }
                Spacer()
                SupplyDemandButton(text: "Cancel", color: Color.red.gradient) {

                }
            } else if status == .IsDemandAndIsHaveShares {
                SupplyDemandButton(text: "Accept & Sell", color: Color.red.gradient) {
                    
                }
                Spacer()
                SupplyDemandButton(text: "Negotiate", color: theme.primary.gradient) {

                }
            } else if status == .IsDemandAndNotHaveEnough {
                SupplyDemandButton(text: "Negotiate", color: theme.primary.gradient) {

                }
            } else if status == .IsDemandAndNotHave {
                VStack {}
            } else if status == .IsSupply {
                SupplyDemandButton(text: "Buy", color: Color.green.gradient) {
                    
                }
                Spacer()
                SupplyDemandButton(text: "Negotiate", color: theme.primary.gradient) {

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
