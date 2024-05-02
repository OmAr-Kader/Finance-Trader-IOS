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
            case 1: HomeTraderOpportunity(state: state, onModeChange: obs.loadStocks, onNavigate: app.navigateTo) { obs.loadData(state.selectedIndex, mode: state.mode) }
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
    let onNavigate: (Screen) -> ()
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
                    VStack {
                        HStack(alignment: .center) {
                            Text(getTitle(stockSymbol: state.stock.symbol, mode: state.mode)).foregroundStyle(theme.textColor).frame(minWidth: 80)
                        }.frame(height: 40).onTapGesture {
                            onNavigate(Screen.STOCK_SCREEN_ROUTE(traderData: TraderData(id: "1", name: "Name"), stockId: "1"))
                        }
                        switch state.mode {
                        case .StockWave : StockWaveView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient, isLoading: state.isLoading)
                        case .StockMulti: StockMultiView(stocks: state.stocks, stockBoarder: state.stockBoarder,  isLoading: state.isLoading)
                        case .StockSMA: StockSMAView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient,  isLoading: state.isLoading)
                        case .StockEMA: StockEMAView(stock: state.stock, stockBoarder: state.stockBoarder, grad: state.gradient,  isLoading: state.isLoading)
                        case .StockRSI: StockRSIView(stock: state.stock, stockBoarder: state.stockBoarder,  isLoading: state.isLoading)
                        case .StockTrad: StockTradView(stock: state.stock, stockBoarder: state.stockBoarder,  isLoading: state.isLoading)
                        case .StockPrediction: StockPredictionView(stock: state.stock, stockPrediction: state.stockPrediction, stockBoarder: state.stockBoarder, grad: state.gradient, gradPred: state.gradientPred,  isLoading: state.isLoading)
                        }
                    }
                    LoadingBar(isLoading: state.isLoading)
                }
            }.background(theme.backDark)
                .cornerRadius(15).background(theme.background).padding()
            Spacer()
        }
    }
    
    func getTitle(stockSymbol: String, mode: ChartMode) -> String {
        return switch mode {
        case .StockMulti : "Comparison"
        case .StockPrediction : "AI Predictions"
        default : stockSymbol
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

