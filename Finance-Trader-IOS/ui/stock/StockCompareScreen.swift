import SwiftUI

struct StockCompareScreen : View {
    
    @StateObject var app: AppObserve

    @Inject
    private var theme: Theme
    
    @StateObject private var obs: StockCompareObserve = StockCompareObserve()
    @State private var toast: Toast? = nil

    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                VStack {
                    StockCompareTimeScope(state: state, onTimeScope: obs.onTimeScope)
                    StockMultiView(stocks: state.stocks, stockBoarderMulti: state.stockBoarderMulti, isLoading: state.isLoading)
                }.background(theme.backDarkSec).cornerRadius(15).padding(top: 15, leading: 15, bottom: 0, trailing: 15)
                VStack {
                    StockCompareSearch(stocksSearch: state.stocksSearch, onSearch: obs.onSearch, addStock: obs.addStock)
                }.background(theme.backDark).cornerRadius(15).padding(top: 15, leading: 15, bottom: 0, trailing: 15)
            }.onAppear {
                obs.loadData()
            }
            LoadingScreen(isLoading: state.isLoading)
        }.toastView(toast: $toast)
            .background(theme.background)
            .withCustomBackButton {
                app.backPress()
            }.toolbarRole(.navigationStack)
    }
}


struct StockCompareTimeScope : View {
    
    let state: StockCompareObserve.State
    let onTimeScope: (Int64) -> Unit
    
    @Inject
    private var theme: Theme
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            VStack {
                if !state.stringData.isEmpty {
                    Menu {
                        Picker("Time Scope", selection: Binding(get: {
                            state.timeScope
                        }, set: { it in
                            onTimeScope(it)
                        })) {
                            ForEach(timeScopes, id: \.key) { (key, value) in
                                Text(value)
                            }
                        }
                    } label: {
                        HStack {
                            Text(state.stringData).foregroundStyle(theme.textColor).font(.subheadline)
                            ImageAsset(icon: "down", tint: theme.primary).frame(width: 10, height: 10)
                        }.foregroundColor(.clear).padding().frame(height: 20)
                    }
                } else {
                    Spacer()
                }
            }.padding()
        }
    }
}

struct StockCompareSearch : View {
    
    let stocksSearch: [StockInfoData]
    let onSearch: @MainActor (String) -> ()
    let addStock: @MainActor (StockInfoData) -> ()
    
    @State private var search: String = ""

    @Inject
    private var theme: Theme
    
    var body: some View {
        ScrollView {
            LazyVStack {
                HStack {
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
                }.background(theme.backDark)
                ForEach(Array(stocksSearch.enumerated()), id: \.element.id) { index, date in
                    let stockInfo = date as StockInfoData
                    HStack(alignment: .center) {
                        Text(stockInfo.name).foregroundStyle(theme.textColor).frame(minWidth: 80)
                        Spacer()
                    }.padding(all: 3).onTapGesture {
                        addStock(stockInfo)
                    }
                }
                Spacer().frame(height: 15)
            }
        }
    }
}
