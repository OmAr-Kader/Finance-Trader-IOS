import SwiftUI


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
                .foregroundColor(selectedMode == item.key ? .black : theme.textColor)
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
