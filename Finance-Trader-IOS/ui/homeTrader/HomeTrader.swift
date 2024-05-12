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
            BottomBarItem(icon: "article", title: "Portfolio", color: theme.primary),
        ]
    }
    
    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                switch  state.selectedIndex {
                case 0: HomeTraderSearch(state: state, traderData: traderData, onSearch: obs.onSearch, onNavigate: app.navigateTo)
                case 1: HomeTraderOpportunity(state: state, traderData: traderData, onModeChange: obs.loadStockMode, onTimeScope: obs.loadTimeScope, onNavigate: app.navigateTo)
                case 2: HomeTraderPortfolio(state: state, traderData: traderData, onModeChange: obs.loadMyStockMode, onTimeScope: obs.loadTimeScope, onNavigate: app.navigateTo, createSupply: obs.createSupply, setAddSheet: obs.setAddSheet)
                default: HomeTraderArticle()
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
                            obs.setIsSearch()
                        }.animation(.default, value: state.selectedIndex)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    ImageAsset(icon: "compare", tint: colorBarIOS).frame(width: 28, height: 28).onTapGesture {
                        app.navigateTo(Screen.STOCK_COMPARE_ROUTE)
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
    
    @Inject
    private var theme: Theme
    
    let state: HomeTraderObserve.State
    let traderData: TraderData
    let onSearch: (String) -> ()
    let onNavigate: (Screen) -> ()
    
    @State private var search: String = ""
    @State private var isSearch: Bool = false

    var body: some View {
        VStack {
            VStack {
                //VStack { }.frame(height: 10)
                if isSearch {
                    HStack {
                        Spacer()
                        OutlinedTextField(
                            text: search,
                            onChange: { it in
                                search = it
                                onSearch(it)
                            },
                            hint: "Search",
                            isError: false,
                            errorMsg: "Shouldn't be empty",
                            theme: theme,
                            cornerRadius: 15,
                            lineLimit: 1,
                            keyboardType: UIKeyboardType.default,
                            backColor: theme.background,
                            isInitFocused: true
                        ).padding()
                        Spacer()
                    }.background(theme.backDarkSec)
                }
                ScrollView {
                    LazyVStack {
                        ForEach(Array(state.stocksSearch.enumerated()), id: \.element.id) { index, date in
                            let stockInfo = date as StockInfoData
                            HStack(alignment: .center) {
                                Text(stockInfo.name).foregroundStyle(theme.textColor).frame(minWidth: 80)
                                Spacer()
                                HStack {
                                    Text("Prce:").foregroundStyle(theme.textColor).font(.subheadline)
                                    ImageAsset(icon: stockInfo.isGain ? "up" : "down", tint: stockInfo.isGain ? .green : .red).frame(width: 10, height: 10)
                                    Text(stockInfo.stockPrice.toStr() + " $").foregroundStyle(stockInfo.isGain ? .green : .red).font(.subheadline)
                                }.padding().frame(height: 20)
                                Spacer()
                            }.padding(all: 5).onTapGesture {
                                onNavigate(Screen.STOCK_SCREEN_ROUTE(traderData: traderData, stockId: stockInfo.id))
                            }
                        }
                    }
                }
            }
            Spacer()
        }.onChange(state.isSearch) { it in
            if it {
                withAnimation(.bouncy(duration: 0.35)) {
                    isSearch = true
                }
            } else {
                withAnimation(.bouncy(duration: 0.35)) {
                    isSearch = false
                }
                search = ""
            }
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
                            ChartMainView(
                                stock: stock, traderData: traderData, onModeChange: { it in
                                    onModeChange(index, it)
                                }, onTimeScope: { it in
                                    onTimeScope(index, it)
                                }, onNavigate: onNavigate
                            ) {
                                Spacer(minLength: 0)
                            }
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
                            ChartMainView(
                                stock: stock, traderData: traderData, onModeChange: { it in
                                    onModeChange(index, it)
                                }, onTimeScope: { it in
                                    onTimeScope(index, it)
                                }, onNavigate: onNavigate
                            ) {
                                ButtonCurvedGradient(cornerRadius: 15, color: Color.red.gradient) {
                                    setAddSheet(true, stock.stockId)
                                }.padding().onCenter()
                            }
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

struct HomeTraderArticle : View {
    var body: some View {
        FullZStack {
            Spacer()
        }
    }
}

