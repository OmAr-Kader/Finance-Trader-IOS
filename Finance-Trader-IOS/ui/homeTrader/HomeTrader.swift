//
//  HomeTrader.swift
//  Finance
//
//  Created by OmAr on 21/04/2024.
//

import SwiftUI
import Charts


struct HomeTrader : View {

    @StateObject var app: AppObserve
    let traderData: TraderData
    let isCompany: Bool = true

    @Inject
    private var theme: Theme
    
    @StateObject private var obs: HomeTraderObserve = HomeTraderObserve()

    private var items: [BottomBarItem] {
        return [
            BottomBarItem(icon: "search", title: "Search", color: theme.primary),
            BottomBarItem(icon: "graph", title: "Opportunities", color: theme.primary),
            BottomBarItem(icon: "portfolio", title: "Portfolio", color: theme.primary),
        ]
    }
    
    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                switch  state.selectedIndex {
                case 0: HomeTraderSearch()
                case 1: HomeTraderOpportunity(state: state, traderData: traderData, onModeChange: obs.loadStockMode, onTimeScope: obs.loadTimeScope, onNavigate: app.navigateTo)
                default: HomeTraderPortfolio(state: state, traderData: traderData, onModeChange: obs.loadMyStockMode, onTimeScope: obs.loadTimeScope, onNavigate: app.navigateTo, createSupply: obs.createSupply, setAddSheet: obs.setAddSheet)
                }
                BottomBar(
                    selectedIndex: state.selectedIndex,
                    items: items, backColor: theme.backDark
                ) { it in
                    obs.onPageSelected(it)
                    obs.loadData(it, traderId: traderData.id)
                }.onBottom().frame(height: 60)
            }
            LoadingScreen(isLoading: state.isLoading)
        }.onAppear {
            obs.loadData(state.selectedIndex, traderId: traderData.id)
        }.background(theme.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Trader").font(.headline).foregroundStyle(colorBarIOS)
                }
                if state.selectedIndex == 1 && isCompany {
                    ToolbarItem(placement: .primaryAction) {
                        ImageAsset(icon: "create", tint: colorBarIOS).frame(width: 28, height: 28).onTapGesture {
                            self.app.navigateTo(Screen.LISTING_STOCK_ROUTE(traderData: self.traderData, stockInfoData: nil))
                        }.animation(.default, value: state.selectedIndex)
                    }
                } else if state.selectedIndex == 0 {
                    ToolbarItem(placement: .primaryAction) {
                        ImageAsset(icon: "search", tint: colorBarIOS).frame(width: 28, height: 28).onTapGesture {
                            
                        }.animation(.default, value: state.selectedIndex)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    ImageAsset(icon: "compare", tint: colorBarIOS).frame(width: 28, height: 28).onTapGesture {
                        
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("Sign out") {
                        app.signOut {
                            app.navigateHome(Screen.SIGN_ROUTE)
                        } _: {
                            
                        }

                    }.foregroundColor(theme.textColor)
                }
            }.toolbarRole(.navigationStack)
            .navigationBarBackButtonHidden(true)
            .animation(.default, value: state.selectedIndex)
    }
}

struct HomeTraderSearch : View {
    var body: some View {
        FullZStack {
            Spacer()
        }
    }
}


struct HomeTraderOpportunity : View {
    
    @Inject
    private var theme: Theme
    
    let state: HomeTraderObserve.State
    let traderData: TraderData
    let onModeChange: (Int, ChartMode) -> Unit
    let onTimeScope: (Int, Int64) -> Unit
    let onNavigate: (Screen) -> ()

    var body: some View {
        VStack {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(Array(state.stocks.enumerated()), id: \.element.stockId) { index, date in
                            let stock = date as StockData
                            VStack {
                                StockChartHeadView(
                                    symbol: stock.symbol,
                                    isGain: stock.isGain,
                                    stockPrice: stock.lastPrice,
                                    timeScope: stock.timeScope
                                ) { it in
                                    onTimeScope(index, it)
                                } onClick: {
                                    onNavigate(Screen.STOCK_SCREEN_ROUTE(traderData: traderData, stockId: stock.id))
                                }
                                ScrollViewReader { value in
                                    ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                                        LazyHStack {
                                            ForEach(ChartMode.allCases, id: \.key) { data in
                                                ChartModeItemView(selectedMode: stock.mode, item: data) {
                                                    onModeChange(state.stocks.firstIndex(of: stock) ?? -1, data.key)
                                                }
                                            }
                                            .animation(.default, value: stock.mode)
                                        }
                                    }.frame(height: 60).onAppear {
                                        value.scrollTo( 5, anchor: .leading)
                                    }
                                }
                                ZStack {
                                    switch stock.mode {
                                    case .StockWave : StockWaveView(stock: stock, isLoading: stock.isLoading)
                                    case .StockSMA: StockSMAView(stock: stock, isLoading: stock.isLoading)
                                    case .StockEMA: StockEMAView(stock: stock, isLoading: stock.isLoading)
                                    case .StockRSI: StockRSIView(stock: stock, isLoading: stock.isLoading)
                                    case .StockTrad: StockTradView(stock: stock, isLoading: stock.isLoading)
                                    case .StockPrediction: StockPredictionView(stock: stock, isLoading: stock.isLoading)
                                    }
                                    LoadingBar(isLoading: stock.isLoading)
                                }.scrollDisabled(true)
                            }.background(theme.backDark).cornerRadius(15).padding(top: 15, leading: 15, bottom: 0, trailing: 15)
                                .animation(.spring(), value: stock.mode)
                        }
                    }
                }
            }
            Spacer()
        }
    }
}

struct HomeTraderPortfolio : View {
    
    @Inject
    private var theme: Theme
    
    let state: HomeTraderObserve.State
    let traderData: TraderData
    let onModeChange: (Int, ChartMode) -> Unit
    let onTimeScope: (Int, Int64) -> Unit
    let onNavigate: (Screen) -> ()
    let createSupply: (Bool, String, String, Int64, Float64, @escaping @MainActor () -> (), @escaping @MainActor () -> ()) -> ()
    let setAddSheet: (Bool, String) -> ()

    @State private var addHeight: CGFloat = 0

    @State private var toast: Toast? = nil

    var body: some View {
        VStack {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(Array(state.myStocks.enumerated()), id: \.element.stockId) { index, date in
                            let stock = date as StockData
                            VStack {
                                StockChartHeadView(
                                    symbol: stock.symbol,
                                    isGain: stock.isGain,
                                    stockPrice: stock.lastPrice,
                                    timeScope: stock.timeScope
                                ) { it in
                                    onTimeScope(index, it)
                                } onClick: {
                                    onNavigate(Screen.STOCK_SCREEN_ROUTE(traderData: traderData, stockId: stock.id))
                                }
                                ScrollViewReader { value in
                                    ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                                        LazyHStack {
                                            ForEach(ChartMode.allCases, id: \.key) { data in
                                                ChartModeItemView(selectedMode: stock.mode, item: data) {
                                                    onModeChange(state.myStocks.firstIndex(of: stock) ?? -1, data.key)
                                                }
                                            }
                                            .animation(.default, value: stock.mode)
                                        }
                                    }.frame(height: 60).onAppear {
                                        value.scrollTo( 5, anchor: .leading)
                                    }
                                }
                                ZStack {
                                    switch stock.mode {
                                    case .StockWave : StockWaveView(stock: stock, isLoading: stock.isLoading)
                                    case .StockSMA: StockSMAView(stock: stock, isLoading: stock.isLoading)
                                    case .StockEMA: StockEMAView(stock: stock, isLoading: stock.isLoading)
                                    case .StockRSI: StockRSIView(stock: stock, isLoading: stock.isLoading)
                                    case .StockTrad: StockTradView(stock: stock, isLoading: stock.isLoading)
                                    case .StockPrediction: StockPredictionView(stock: stock, isLoading: stock.isLoading)
                                    }
                                    LoadingBar(isLoading: stock.isLoading)
                                }.scrollDisabled(true)
                                Button {
                                    setAddSheet(true, stock.stockId)
                                } label: {
                                    Text("Sell")
                                        .padding(10)
                                        .frame(minWidth: 80)
                                        .foregroundColor(.black)
                                        .background(
                                            RoundedRectangle(
                                                cornerRadius: 15,
                                                style: .continuous
                                            )
                                            .fill(Color.red.gradient)
                                        )
                                }.padding().onCenter()
                            }.background(theme.backDark).cornerRadius(15).padding(top: 15, leading: 15, bottom: 0, trailing: 15)
                                .animation(.spring(), value: stock.mode)
                        }
                    }
                }
            }
            Spacer()
        }.bottomSheet(
            theme.backDarkSec,
            Binding(get: {
                state.isAddSheet
            }, set: { it in
                setAddSheet(it, state.supplyStockId)
            }),
            $addHeight
        ) {
            AddSheet(addSheetMode: .Supply) { shares, prices, isSupply in
                if state.supplyStockId.isEmpty {
                    setAddSheet(false, state.supplyStockId)
                    return
                }
                createSupply(isSupply, traderData.id, state.supplyStockId, shares, prices) {
                    setAddSheet(false, state.supplyStockId)
                } _: {
                    toast = Toast(style: .error, message: "Failed")
                }
            }
        }
    }
}
