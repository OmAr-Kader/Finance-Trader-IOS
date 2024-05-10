import SwiftUI

enum AddSheetMode {
    case SupplyAndDemand
    case Supply
    case Demand
}

struct AddSheet : View {
    
    let addSheetMode: AddSheetMode
    let onSupplyDemand: (Int64, Float64, Bool) -> ()
    
    @State private var isSupply: Bool = false
    @State private var isPressed: Bool = false
    @State private var shares: String = ""
    @State private var price: String = ""

    @Inject
    private var theme: Theme
    
    var body: some View {
        switch addSheetMode {
        case .SupplyAndDemand:
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    isSupply = true
                }) {
                    Text("Supply")
                        .onLeadingCurvedText(textColor: isSupply ? theme.textForPrimaryColor : theme.textColor, backgroundColor: isSupply ? theme.primary.gradient : theme.background.gradient)
                        .animation(.easeInOut(duration: 0.5), value: isSupply)
                }
                Button(action: {
                    isSupply = false
                }) {
                    Text("Demand")
                        .onTrailingCurvedText(textColor: isSupply ? theme.textForPrimaryColor : theme.textColor, backgroundColor: isSupply ? theme.primary.gradient : theme.background.gradient)
                        .animation(.easeInOut(duration: 0.5), value: isSupply)
                }
                Spacer()
            }.padding()
        case .Demand: Text("Creata a Demand").allCurvedText(textColor: theme.textForPrimaryColor, backgroundColor: theme.primary.gradient)
        case .Supply: Text("Creata a Supply").allCurvedText(textColor: theme.textForPrimaryColor, backgroundColor: theme.primary.gradient)
        }
        HStack {
            OutlinedTextField(
                text: self.shares,
                onChange: { it in
                    self.shares = it
                    isPressed = false
                },
                hint: "Enter your desired Shares",
                isError: isPressed && Int64(shares) == nil,
                errorMsg: "Wrong Formatted",
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
                    isPressed = false
                },
                hint: "Enter your desired Price",
                isError: isPressed && Float64(price) == nil,
                errorMsg: "Wrong Formatted",
                theme: theme,
                cornerRadius: 25,
                lineLimit: 1,
                keyboardType: UIKeyboardType.numberPad
            ).padding()
        }
        Button {
            guard let share = Int64(shares) else {
                withAnimation {
                    isPressed = true
                }
                return
            }
            guard let pri = Float64(price) else {
                withAnimation {
                    isPressed = true
                }
                return
            }
            onSupplyDemand(share, pri, isSupply)
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

struct NegotiateSheet : View {
    
    let supplyDemandData: SupplyDemandData?
    let pushNegotiate: (SupplyDemandData, Int64, Float64) -> ()
    
    @State private var shares: String = ""
    @State private var price: String = ""
    @State private var isPressed: Bool = false

    @Inject
    private var theme: Theme
        
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
                    Text("Price:").foregroundStyle(theme.textColor).font(.title3)
                    Text(String(supplyDemandData.price) + " $").foregroundStyle(theme.textColor).font(.title3)
                }
                Spacer()
            }.padding()
            HStack {
                OutlinedTextField(
                    text: self.shares,
                    onChange: { it in
                        self.shares = it
                        isPressed = false
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
                        isPressed = false
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
                    withAnimation {
                        isPressed = true
                    }
                    return
                }
                guard let pri = Float64(price) else {
                    withAnimation {
                        isPressed = true
                    }
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

enum SupplyDemandScreenMode : Hashable {
    case IsOwnerEdit
    case IsOwnerDelete
    case IsBuy
    case IsBuyNegotiate
    case IsAcceptSell
    case IsSellNegotiate
    case IsSellNegotiateNotEnough
}
