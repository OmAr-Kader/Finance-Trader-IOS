import SwiftUI

struct NegotiateSheet : View {
    
    let supplyDemandData: SupplyDemandData?
    let pushNegotiate: (SupplyDemandData, Int64, Float64) -> ()
    
    @State private var shares: String = ""
    @State private var price: String = ""

    @Inject
    private var theme: Theme
    
    @StateObject private var obs: ExchangeObserve = ExchangeObserve()
    
    var body: some View {
        if supplyDemandData == nil {
            VStack {}
        } else {
            let supplyDemandData = self.supplyDemandData!
            Text("Negotiate A " + (supplyDemandData.isSupply ? "Supply" : "Demand")).foregroundStyle(theme.textColor).onCenter()
            HStack {
                HStack {
                    Text("Shares:").foregroundStyle(theme.textColor).font(.title3)
                    Text(String(supplyDemandData.shares)).foregroundStyle(theme.textHintColor).font(.title3)
                }
                Spacer()
                HStack {
                    Text("Prce:").foregroundStyle(theme.textColor).font(.title3)
                    Text(String(supplyDemandData.price) + " $").foregroundStyle(theme.textColor).font(.title3)
                }
                Spacer()
            }.padding()
            HStack {
                OutlinedTextField(
                    text: self.shares,
                    onChange: { it in
                        self.shares = it
                    },
                    hint: "Enter your desired Shares",
                    isError: Int64(shares) == nil,
                    errorMsg: "Shouldn't be empty",
                    theme: theme,
                    cornerRadius: 25,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.numberPad
                ).padding()
            }
            HStack {
                OutlinedTextField(
                    text: self.price,
                    onChange: { it in
                        self.price = it
                    },
                    hint: "Enter your desired Price",
                    isError: Float64(price) == nil,
                    errorMsg: "Shouldn't be empty",
                    theme: theme,
                    cornerRadius: 25,
                    lineLimit: 1,
                    keyboardType: UIKeyboardType.numberPad
                ).padding()
            }
            Button {
                guard let share = Int64(shares) else {
                    return
                }
                guard let pri = Float64(price) else {
                    return
                }
                pushNegotiate(supplyDemandData, share, pri)
            } label: {
                Text("Done")
                    .padding(10)
                    .frame(minWidth: 80)
                    .foregroundColor(.black)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 15,
                            style: .continuous
                        )
                        .fill(Color.green.gradient)
                    )
            }.padding().onCenter()
        }
    }
}

struct AddSheet : View {
    
    let isHaveShares: Bool
    let pushNegotiate: (Int64, Float64, Bool) -> ()
    
    @State private var isSupply: Bool = false
    @State private var shares: String = ""
    @State private var price: String = ""

    @Inject
    private var theme: Theme
    
    @StateObject private var obs: ExchangeObserve = ExchangeObserve()
    
    var body: some View {
        if isHaveShares {
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    isSupply = true
                }) {
                    Text("Supply")
                        .padding(10)
                        .frame(minWidth: 80)
                        .foregroundColor(isSupply ? .black : theme.textColor)
                        .background(
                            isSupply ? theme.primary.gradient : theme.background.gradient
                        )
                        .clipShape(
                            .rect(
                                topLeadingRadius: 20,
                                bottomLeadingRadius: 20,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 0
                            )
                        )
                        .transition(.move(edge: .trailing))
                        .animation(.easeInOut(duration: 0.5), value: isSupply)
                }
                Button(action: {
                    isSupply = false
                }) {
                    Text("Demand")
                        .padding(10)
                        .frame(minWidth: 80)
                        .foregroundColor(!isSupply ? .black : theme.textColor)
                        .background(
                            !isSupply ? theme.primary.gradient : theme.background.gradient
                        ).clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 20,
                                topTrailingRadius: 20
                            )
                        )
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut(duration: 0.5), value: isSupply)
                }
                Spacer()
            }.padding()
        } else {
            Text("Creata a Demand")
                .padding(10)
                .frame(minWidth: 80)
                .foregroundColor(.black)
                .background(theme.primary.gradient).clipShape(.rect(cornerRadius: 20))
                .transition(.move(edge: .leading))
                .animation(.easeInOut(duration: 0.5), value: isSupply)
        }
        HStack {
            OutlinedTextField(
                text: self.shares,
                onChange: { it in
                    self.shares = it
                },
                hint: "Enter your desired Shares",
                isError: Int64(shares) == nil,
                errorMsg: "Shouldn't be empty",
                theme: theme,
                cornerRadius: 25,
                lineLimit: 1,
                keyboardType: UIKeyboardType.numberPad
            ).padding()
        }
        HStack {
            OutlinedTextField(
                text: self.price,
                onChange: { it in
                    self.price = it
                },
                hint: "Enter your desired Price",
                isError: Float64(price) == nil,
                errorMsg: "Shouldn't be empty",
                theme: theme,
                cornerRadius: 25,
                lineLimit: 1,
                keyboardType: UIKeyboardType.numberPad
            ).padding()
        }
        Button {
            guard let share = Int64(shares) else {
                return
            }
            guard let pri = Float64(price) else {
                return
            }
            pushNegotiate(share, pri, isSupply)
        } label: {
            Text("Done")
                .padding(10)
                .frame(minWidth: 80)
                .foregroundColor(.black)
                .background(
                    RoundedRectangle(
                        cornerRadius: 15,
                        style: .continuous
                    )
                    .fill(Color.green.gradient)
                )
        }.padding().onCenter()
    }
}


enum SupplyDemandScreenMode : Hashable {
    case IsOwnerEdit
    case IsBuy
    case IsBuyNegotiate
    case IsAcceptSell
    case IsSellNegotiate
    case IsSellNegotiateNotEnough
}
