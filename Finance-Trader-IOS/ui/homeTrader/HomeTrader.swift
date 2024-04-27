//
//  HomeTrader.swift
//  Finance
//
//  Created by OmAr on 21/04/2024.
//

import SwiftUI
import Charts


struct HomeTrader : View {
    
    @Inject
    private var theme: Theme
    
    @StateObject var app: AppObserve
    @StateObject var obs: HomeTraderObserve = HomeTraderObserve()

    var items: [BottomBarItem] {
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
            case 1: HomeTraderOpportunity(state: state, onModeChange: obs.loadStocks) { obs.loadData(state.selectedIndex, mode: state.mode) }
            default: HomeTraderPortfolio()
            }
            BottomBar(
                selectedIndex: state.selectedIndex,
                items: items, backColor: theme.backDark
            ) { it in
                obs.onPageSelected(it)
                obs.loadData(it, mode: state.mode)
            }.onBottom().frame(height: 60)
        }.onAppear {
            obs.loadData(state.selectedIndex, mode: state.mode)
        }.background(theme.background)
    }
}

//https://www.swiftyplace.com/blog/swiftcharts-create-charts-and-graphs-in-swiftui
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
    let onModeChange: (ChartMode) -> Unit
    let onRefresh: () -> Unit
    
    var body: some View {
        VStack {
            VStack {
                ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(ChartMode.allCases, id: \.key) { (key: ChartMode, value: String) in
                            Button {
                                onModeChange(key)
                            } label: {
                                Text(value)
                                    .padding()
                                    .frame(minWidth: 80)
                                    .foregroundColor(state.mode == key ? .black : theme.textColor)
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: 15,
                                            style: .continuous
                                        )
                                        .fill(state.mode == key ? theme.primary.gradient : Color.clear.gradient)
                                    )
                            }
                        }
                        .animation(.default, value: state.mode)
                    }
                }.frame(height: 60).padding()
                ZStack {
                    switch state.mode {
                    case .StockWave : StockWaveView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient, isLoading: state.isLoading)
                    case .StockMulti: StockMultiView(stocks: state.stocks, stockBoarder: state.stockBoarder, isLoading: state.isLoading)
                    case .StockSMA: StockSMAView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient, isLoading: state.isLoading)
                    case .StockEMA: StockEMAView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient, isLoading: state.isLoading)
                    case .StockRSI: StockRSIView(stock: state.stock, stockBoarder: state.stockBoarder, isLoading: state.isLoading)
                    case .StockTrad: StockTradView(stock: state.stock, stockBoarder: state.stockBoarder, isLoading: state.isLoading)
                    case .StockPrediction: StockPredictionView(stock: state.stock, stockPrediction: state.stockPrediction, stockBoarder: state.stockBoarder, grad: state.gradient, gradPred: state.gradientPred, isLoading: state.isLoading)
                    }
                    LoadingBar(isLoading: state.isLoading)
                }
            }.background(theme.backDark)
                .cornerRadius(15).background(theme.background).padding()
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
