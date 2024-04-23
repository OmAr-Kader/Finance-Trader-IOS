import SwiftUI

//https://itwenty.me/posts/05-swiftui-drawerview-p1/
struct DrawerView<MainContent: View, DrawerContent: View>: View {

    @Binding var isOpen: Bool
    let overlayColor: Color
    let theme: Theme
    @ViewBuilder let main: () -> MainContent
    @ViewBuilder let drawer: () -> DrawerContent

    private let overlap: CGFloat = 0.7
    private let overlayOpacity = 0.7
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if isOpen {
                main()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        overlayColor.opacity(overlayOpacity)
                            .ignoresSafeArea(.all, edges: [.bottom])
                            .onTapGesture {
                                withAnimation {
                                    isOpen.toggle()
                                }
                            }
                    )
            } else {
                main()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if isOpen {
                drawer().frame(width: 250)
                    .ignoresSafeArea(.all, edges: [.bottom])
                    .transition(.move(edge: .leading))
            }
        }
    }
}

struct DrawerText : View {
    
    let itemColor: Color
    let text: String
    let textColor: Color
    let action: () -> Unit
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(.system(size: 20))
                .frame(height: 56)
                .foregroundStyle(textColor)
                .padding(leading: 16, trailing: 24)
                .onStart()
        }.frame(width: 250, height: 56, alignment: .center).background(itemColor)
    }
}

struct DrawerItem : View {
    
    let itemColor: Color
    let icon: String
    let text: String
    let textColor: Color
    let action: () -> Unit
    
    var body: some View {
        Button(action: action) {
            HStack {
                ImageAsset(icon: icon, tint: textColor)
                    .frame(width: 25, height: 25)
                Text(
                    text
                ).font(.system(size: 20))
                    .foregroundStyle(textColor)
            }.padding(leading: 16, trailing: 24).onStart()
        }.frame(width: 250)

    }
}

/*
 Surface(
     modifier = Modifier
         .fillMaxWidth()
         .height(
             56.0.dp//NavigationDrawerTokens.ActiveIndicatorHeight
         ),
     color = MaterialTheme.colorScheme.primary,
 ) {
     Row(
         Modifier.padding(start = 16.dp, end = 24.dp),
         verticalAlignment = Alignment.CenterVertically
     ) {
         Text(
             "Curso",
             color = isSystemInDarkTheme().textForPrimaryColor
         )
     }
 }*/
