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
        }
    }
}

//https://www.swiftyplace.com/blog/swiftcharts-create-charts-and-graphs-in-swiftui
struct HomeTraderSearch : View {
    var body: some View {
        VStack {
            
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
        FullZStack {
            VStack {
                Button {
                    onRefresh()
                } label: {
                    Text("Refresh")
                        .padding(20)
                }.onEnd()
                Group {
                    ScrollView(Axis.Set.vertical, showsIndicators: false) {
                        LazyVStack {
                            GroupBox { //(title)
                                ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                                    LazyHStack {
                                        Button {
                                            onModeChange(.StockWave)
                                        } label: {
                                            Text("Wave")
                                                .padding(10)
                                        }
                                        Button {
                                            onModeChange(.StockMulti)
                                        } label: {
                                            Text("Multi")
                                                .padding(10)
                                        }
                                        Button {
                                            onModeChange(.StockSMA)
                                        } label: {
                                            Text("SMA")
                                                .padding(10)
                                        }
                                        Button {
                                            onModeChange(.StockEMA)
                                        } label: {
                                            Text("EMA")
                                                .padding(10)
                                        }
                                        Button {
                                            onModeChange(.StockRSI)
                                        } label: {
                                            Text("RSI")
                                                .padding(10)
                                        }
                                        Button {
                                            onModeChange(.StockTrad)
                                        } label: {
                                            Text("Trad")
                                                .padding(10)
                                        }
                                        Button {
                                            onModeChange(.StockPrediction)
                                        } label: {
                                            Text("Prediction")
                                                .padding(10)
                                        }
                                    }
                                }
                                switch state.mode {
                                case .StockWave : StockWaveView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient)
                                case .StockMulti: StockMultiView(stocks: state.stocks, stockBoarder: state.stockBoarder)
                                case .StockSMA: StockSMAView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient)
                                case .StockEMA: StockEMAView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient)
                                case .StockRSI: StockRSIView(stock: state.stock, stockBoarder: state.stockBoarder)
                                case .StockTrad: StockTradView(stock: state.stock, stockBoarder: state.stockBoarder)
                                case .StockPrediction: StockPredictionView(stock: state.stock, stockPrediction: state.stockPrediction, stockBoarder: state.stockBoarder, grad: state.gradient, gradPred: state.gradientPred)
                                }
                            }.groupBoxStyle(BoxGroupStyle(color: theme.backDark))
                                .padding()
                        }
                    }
                }.onBottom()
            }
        }
    }
}

struct HomeTraderPortfolio : View {
    var body: some View {
        VStack {
            
        }
    }
}
