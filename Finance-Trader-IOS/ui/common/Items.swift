import SwiftUI


struct StockChartHeadView : View {
    
    let symbol: String
    let isGain: Bool
    let stockPrice: Float64
    let onClick: () -> ()
    
    @Inject
    private var theme: Theme
    
    var body: some View {
        HStack(alignment: .center) {
            Text(symbol).foregroundStyle(theme.textColor).frame(minWidth: 80)
            HStack {
                Text("Prce:").foregroundStyle(theme.textColor).font(.subheadline)
                ImageAsset(icon: isGain ? "up" : "down", tint: isGain ? .green : .red).frame(width: 10, height: 10)
                Text(String(stockPrice) + " $").foregroundStyle(isGain ? .green : .red).font(.subheadline)
            }.padding()
        }.frame(height: 40).onTapGesture {
            onClick()
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
