import SwiftUI


struct BackButtonModifier: ViewModifier {
    let onBackPressed: () -> Unit
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton(action: onBackPressed)
                }
            }
    }
}

extension View {
    func withCustomBackButton(_ onBackPressed: @escaping () -> Unit) -> some View {
        modifier(BackButtonModifier(onBackPressed: onBackPressed))
    }

}


struct BackButton: View {

    let title: String
    let action: () -> Void
    
    init(title: String = "", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                action()
            }) {
                HStack {
                    Image(
                        uiImage: UIImage(
                            named: "chevron.backward"
                        )?.withTintColor(
                            UIColor(Color.cyan)
                        ) ?? UIImage()
                    ).resizable()
                        .imageScale(.medium)
                        .scaledToFit().frame(
                            width: 20, height: 22, alignment: .topLeading
                        )
                    Text(
                        "Back"
                    ).font(.system(size: 17))
                        .foregroundStyle(
                            Color(red: 9 / 255, green: 131 / 255, blue: 1)
                        ).padding(leading: -7)
                }.frame(width: 90, height: 45)
            }.onStart()
            Spacer()
            Text(title).font(.headline).foregroundStyle(Color(red: 9 / 255, green: 131 / 255, blue: 1)).onCenter()
            Spacer()
        }.onTop()
    }
}


struct ToolBarButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer().frame(height: 10)
            Button(action: {
                action()
            }) {
                VStack {
                    VStack {
                        ImageAsset(
                            icon: icon,
                            tint: Color.black
                        )
                    }.padding(7).background(Color.red)
                }.clipShape(Circle())
            }.frame(width: 35, height: 35)
        }
    }
}

