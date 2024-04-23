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
            case 1: HomeTraderOpportunity(state: state) { obs.loadData(state.selectedIndex) }
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
                                StockWaveView(stocks: state.stocksWave, stockBoarder: state.stockBoarderWave, grad: state.grad)
                            }.groupBoxStyle(BoxGroupStyle(color: theme.backDark))
                                .padding()
                            Spacer().frame(height: 15)
                            GroupBox { //(title)
                                StockMultiView(stocks: state.stocksMutli, stockBoarder: state.stockBoarderMulti)
                            }.groupBoxStyle(BoxGroupStyle(color: Color(hue: 0.10, saturation: 0.10, brightness: 0.98)))
                                .padding()
                            Spacer().frame(height: 15)
                            GroupBox { //(title)
                                StockTradView(stocks: state.stocksWave, stockBoarder: state.stockBoarderWave)
                            }.groupBoxStyle(BoxGroupStyle(color: theme.backDark))
                                .padding()
                            Spacer().frame(height: 15)
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
