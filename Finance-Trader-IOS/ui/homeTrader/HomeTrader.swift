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
        FullZStack {
            switch  state.selectedIndex {
            case 0: HomeTraderSearch()
            case 1: HomeTraderOpportunity(state: state, onModeChange: obs.loadStockMode, onNavigate: app.navigateTo)
            default: HomeTraderPortfolio()
            }
            BottomBar(
                selectedIndex: state.selectedIndex,
                items: items, backColor: theme.backDark
            ) { it in
                obs.onPageSelected(it)
                obs.loadData(it)
            }.onBottom().frame(height: 60)
        }.onAppear {
            obs.loadData(state.selectedIndex)
        }.background(theme.background)
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
    let onModeChange: (Int, ChartMode) -> Unit
    let onNavigate: (Screen) -> ()
    
    var body: some View {
        VStack {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(state.stocks) { stock in
                            VStack {
                                StockChartHeadView(
                                    symbol: stock.symbol,
                                    isGain: stock.isGain,
                                    stockPrice: stock.lastPrice
                                ) {
                                    onNavigate(Screen.STOCK_SCREEN_ROUTE(traderData: TraderData(id: "1", name: "Name"), stockId: "1"))
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
    var body: some View {
        FullZStack {
            Spacer()
        }
    }
}

/*
#Preview {
    VStack {
        HomeTrader(app: AppObserve())
    }
}*/

