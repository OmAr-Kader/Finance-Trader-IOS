import SwiftUI

struct StockChartHeadView : View {
    
    let stock: StockData
    let onTimeScope: (Int64) -> ()
    let onClick: () -> ()
    
    @State private var angle: Double = 0
    
    @Inject
    private var theme: Theme
    
    var body: some View {
        HStack(alignment: .center) {
            Text(stock.symbol).foregroundStyle(theme.textColor).frame(minWidth: 80).onTapGesture {
                onClick()
            }
            Spacer()
            VStack {
                HStack {
                    Text("Prce:").foregroundStyle(theme.textColor).font(.subheadline)
                    ImageAsset(icon: stock.isGain ? "up" : "down", tint: stock.isGain ? .green : .red).frame(width: 10, height: 10)
                    Text(stock.lastPrice.toStr() + " $").foregroundStyle(stock.isGain ? .green : .red).font(.subheadline)
                }.padding().frame(height: 20).onTapGesture {
                    onClick()
                }
                Menu {
                    Picker("Time Scope", selection: Binding(get: {
                        stock.timeScope
                    }, set: { it in
                        onTimeScope(it)
                    })) {
                        ForEach(timeScopes, id: \.key) { (key, value) in
                            Text(value)
                        }
                    }
                } label: {
                    HStack {
                        if !stock.stringData.isEmpty {
                            Text(stock.stringData).foregroundStyle(theme.textColor).font(.subheadline)
                            ImageAsset(icon: "down", tint: theme.primary).frame(width: 10, height: 10)
                        }
                    }.foregroundColor(.clear).padding().frame(height: 20)
                }
            }.padding()
        }
    }
}

struct ChartModeItemView : View {
    
    let selectedMode: ChartMode
    let item: (key: ChartMode, value: String)
    let onClick: () -> ()
    
    @Inject private var theme: Theme
    var body: some View {
        Button(action: onClick) {
            Text(item.value)
                .padding(10)
                .frame(minWidth: 80)
                .foregroundColor(selectedMode == item.key ? theme.background : theme.textColor)
                .background(
                    RoundedRectangle(
                        cornerRadius: 15,
                        style: .continuous
                    )
                    .fill(selectedMode == item.key ? theme.primary.gradient : Color.clear.gradient)
                )
        }.padding(leading: 5, trailing: 5)
    }
}
