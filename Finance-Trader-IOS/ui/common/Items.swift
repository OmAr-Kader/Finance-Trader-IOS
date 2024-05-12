import SwiftUI


struct StockChartHeadView : View {
    
    let symbol: String
    let isGain: Bool
    let stockPrice: Float64
    let timeScope: Int64
    let onTimeScope: (Int64) -> ()
    let onClick: () -> ()
    
    @State private var angle: Double = 0
    
    let timeScopes: [(key: Int64 , value: String)] = [
        (3, "Last 3 days"),
        (7, "last week"),
        (14, "last 2 weeks"),
        (28, "last 4 weeks"),
        (84, "last 12 weeks"),
    ]
    
    @Inject
    private var theme: Theme
    
    var body: some View {
        HStack(alignment: .center) {
            Text(symbol).foregroundStyle(theme.textColor).frame(minWidth: 80).onTapGesture {
                onClick()
            }
            HStack {
                Text("Prce:").foregroundStyle(theme.textColor).font(.subheadline)
                ImageAsset(icon: isGain ? "up" : "down", tint: isGain ? .green : .red).frame(width: 10, height: 10)
                Text(stockPrice.toStr() + " $").foregroundStyle(isGain ? .green : .red).font(.subheadline)
            }.padding().onTapGesture {
                onClick()
            }
            Spacer()
            Menu {
                Picker("Time Scope", selection: Binding(get: {
                    timeScope
                }, set: { it in
                    onTimeScope(it)
                })) {
                    ForEach(timeScopes, id: \.key) { (key, value) in
                        Text(value)
                    }
                }
            } label: {
                ImageAsset(icon: "down", tint: theme.primary).frame(width: 15, height: 15).foregroundColor(.clear).padding()
            }
        }.frame(height: 40)
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
