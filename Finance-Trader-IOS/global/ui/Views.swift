import SwiftUI
import _PhotosUI_SwiftUI

extension View {
    
    @inlinable public func padding(
        top: CGFloat? = nil,
        leading: CGFloat? = nil,
        bottom: CGFloat? = nil,
        trailing: CGFloat? = nil
    ) -> some View {
        return padding(
            EdgeInsets(
                top: top ?? 0,
                leading: leading ?? 0,
                bottom: bottom ?? 0,
                trailing: trailing ?? 0
            )
        )
    }
    
    @inlinable public func padding(
        all: CGFloat
    ) -> some View {
        return padding(
            EdgeInsets(
                top: all,
                leading: all,
                bottom: all,
                trailing: all
            )
        )
    }
    
    @inlinable public func onStart() -> some View {
        return HStack {
            self
            Spacer()
        }
    }
    
    @inlinable public func onEnd() -> some View {
        return HStack {
            Spacer()
            self
        }
    }
    
    @inlinable public func onCenter() -> some View {
        return HStack {
            Spacer(minLength: 0)
            self
            Spacer(minLength: 0)
        }
    }
    
    @inlinable public func onTop() -> some View {
        return VStack {
            self
            Spacer(minLength: 0)
        }
    }
    
    @inlinable public func onBottomEnd() -> some View {
        return HStack {
            Spacer()
            VStack(alignment: .center) {
                Spacer()
                self
            }
        }
    }
    
    @inlinable public func onBottom() -> some View {
        return VStack {
            Spacer()
            self
        }
    }

    
    @inlinable func safeArea() -> some View {
        if #available(iOS 17.0, *) {
            return safeAreaPadding()
        } else {
            return self
        }
    }
    
    @inlinable func onLeadingCurvedText(textColor: Color, backgroundColor: AnyGradient) -> some View {
        return padding(10)
        .frame(minWidth: 80)
        .foregroundColor(textColor)
        .background(backgroundColor)
        .clipShape(
            .rect(
                topLeadingRadius: 20,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
        )
        .transition(.move(edge: .trailing))
    }
    
    @inlinable func onTrailingCurvedText(textColor: Color, backgroundColor: AnyGradient) -> some View {
        return padding(10)
        .frame(minWidth: 80)
        .foregroundColor(textColor)
        .background(backgroundColor)
        .clipShape(
            .rect(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 20,
                topTrailingRadius: 20
            )
        )
        .transition(.move(edge: .trailing))
    }
    
    @inlinable func allCurvedText(textColor: Color, backgroundColor: AnyGradient) -> some View {
        return padding(10)
            .frame(minWidth: 80)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .clipShape(.rect(cornerRadius: 20))
            .transition(.move(edge: .leading))
    }
    
    /*@inlinable func safeAreaSpace(_ edges: Edge.Set) -> some View {
        if #available(iOS 17.0, *) {
            return safeAreaPadding(edges)
        } else {
            return safeAreaInset(edge: .bottom) {
                self
            }
        }
    }*/
    
    func onChange<T: Equatable>(_ it: T,_ action: @escaping (T) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            return onChange(of: it) { oldValue, newValue in
                action(newValue)
            }
        } else {
            return onChange(of: it) { newValue in
                action(newValue)
            }
        }
    }
    
    
    func onAppearTask(delay: TimeInterval, perform: @escaping () async -> Void) -> some View {
        if delay == 0 {
            task {
                await perform()
            }
        } else {
            task {
                do {
                    try await Task.sleep(delay)
                } catch {
                    return
                }
                await perform()
            }
        }
    }

}

public extension TimeInterval {
    var nanoseconds: UInt64 {
        return UInt64((self * 1_000_000_000).rounded())
    }
}

@available(iOS 13.0, macOS 10.15, *)
public extension Task where Success == Never, Failure == Never {
    static func sleep(_ duration: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: duration.nanoseconds)
    }
}

struct ButtonCurvedGradient : View {
    
    let text: String
    let cornerRadius: CGFloat
    let textColor: Color
    let color: AnyGradient
    let action: () -> ()

    var body: some View {
        Button(action: action) {
            Text(text)
                .padding(10)
                .frame(minWidth: 80)
                .foregroundColor(textColor)
                .background(
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                    .fill(color)
                )
        }
    }
}

struct CardButton : View {
    let onClick: (() -> Unit)
    let text: String
    let color: Color// = MaterialTheme.colorScheme.primary,
    let textColor: Color// = isSystemInDarkTheme().textForPrimaryColor
    let width: CGFloat// = 80
    let height: CGFloat// = 30
    let curve: CGFloat //height / 2
    let fontSize: CGFloat// = 11
    
    init(
        onClick: @escaping () -> Unit,
        text: String,
        color: Color,
        textColor: Color,
        width: CGFloat = 80,
        height: CGFloat = 30,
        curve: CGFloat? = nil,
        fontSize: CGFloat = 11
    ) {
        self.onClick = onClick
        self.text = text
        self.color = color
        self.textColor = textColor
        self.width = width
        self.height = height
        self.curve = curve ?? height / 2
        self.fontSize = fontSize
    }
    
    var body: some View {
        VStack {
            Text(
                text
            ).lineLimit(1).foregroundColor(textColor).font(.system(size: fontSize))
        }.frame(width: width, height: height, alignment: .center).background(
            RoundedRectangle(cornerRadius: curve).fill((color))
        ).onTapGesture {
            onClick()
        }
    }
}

struct PagerTabButton : View {
    let theme: Theme
    let index: Int
    let text: String
    let currentPage: Int
    let onPageChange: (Int) -> Unit

    var body: some View {
        let isCurrentPage = currentPage == index
        let width: CGFloat = isCurrentPage ? 90 : 70
        let color: Color = isCurrentPage ? theme.primary : theme.secondary
        let corner: CGFloat = isCurrentPage ? 10 : 40
        Button {
            onPageChange(index)
        } label: {
            VStack(alignment: .center) {
                Text(text).foregroundStyle(theme.textForPrimaryColor)
                    .font(.system(size: width / 8)).lineLimit(1)
            }
        }.padding(leading: 6, trailing: 5).frame(width: width, height: width / 2).background(
            RoundedRectangle(cornerRadius: corner).fill(color)
        )

    }
}

struct PagerTabW<Content : View> : View {
    
    @Binding var currentPage: Int
    let list: [String]
    let theme: Theme
    @ViewBuilder var pageContent: () -> Content

    var body: some View {
        VStack {
            VStack {
                Spacer().frame(height: 15)
                HStack {
                    ForEach(0..<list.count, id: \.self) { index in
                        Spacer()
                        PagerTabButton(theme: theme, index: index, text: list[index], currentPage: currentPage, onPageChange: { it in
                            currentPage = it
                        })
                    }
                    Spacer()
                }
                Spacer().frame(height: 15)
                TabView(selection: $currentPage, content: pageContent).tabViewStyle(.page(indexDisplayMode: .never))
            }.background(theme.background.margeWithPrimary)
        }.clipShape(
            .rect(topLeadingRadius: 15, topTrailingRadius: 15)
        )
    }
}

struct PagerTab<Content : View> : View {
    
    let currentPage: Int
    let onPageChange: (Int) -> Unit
    let list: [String]
    let theme: Theme
    @ViewBuilder var pageContent: () -> Content

    var body: some View {
        ZStack {
            theme.background.margeWithPrimary
                .clipShape(.rect(topLeadingRadius: 15, topTrailingRadius: 15))
                .ignoresSafeArea(edges: .bottom)
            VStack {
                Spacer().frame(height: 15)
                HStack {
                    ForEach(0..<list.count, id: \.self) { index in
                        Spacer()
                        PagerTabButton(theme: theme, index: index, text: list[index], currentPage: currentPage, onPageChange: onPageChange)
                    }
                    Spacer()
                }
                Spacer().frame(height: 15)
                TabView(selection: Binding(get: {
                    currentPage
                }, set: { it in
                    onPageChange(it)
                }), content: pageContent).tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}
/*
SubTopScreenButton
    .toolbar{
        ToolbarItem(placement: .navigationBarLeading) {
            // Button
        }
    }
*/
struct ProfileItems : View {
    let icon: String
    let color: Color
    let theme: Theme
    let title: String
    let numbers: String

    var body: some View {
        VStack(alignment: .center) {
            ImageAsset(icon: icon, tint: color).frame(width: 30, height: 30)
            Text(title).font(.system(size: 10)).padding(3).foregroundStyle(theme.textColor)
            Text(numbers)
                .font(.system(size: 10))
                .padding(3)
                .foregroundStyle(theme.textHintColor)
        }.padding(10)
    }
}

struct CardAnimationButton : View {
    let isChoose: Bool
    let isProcess: Bool
    let text: String
    let color: Color
    let secondaryColor: Color
    let textColor: Color
    let onClick: () -> Unit

    var body: some View {
        
        let animated = isChoose ? 10 : 40
        let animatedSize = isChoose ? 100 : 80
        let c: Color = if (isChoose) {
            color
        } else {
            if (isProcess) {
                Color.gray
            } else {
                secondaryColor
            }
        }
        Button(action: onClick, label: {
            FullZStack {
                if (!isChoose || !isProcess) {
                    Text(text)
                        .lineLimit(1)
                        .foregroundColor(textColor)
                        .font(.system(size: CGFloat(animatedSize) / 9))
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                }
            }
        }).padding(top: 5, leading: 0, bottom: 5, trailing: 0)
            .background(
                RoundedRectangle(cornerRadius: CGFloat(animated))
                    .fill(c)
            ).frame(width: CGFloat(animatedSize), height: CGFloat(animatedSize) / 2)
    }
}

struct FullZStack<Content> : View where Content : View {
        
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            VStack {
                Spacer(minLength: 0)
                self.content()
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
    }
}

func forChangePhoto(_ image: @escaping (URL) -> Void) -> ((PhotosPickerItem?) -> Void){
    return { newIt in
        logger(
            "imageUri",
            String(newIt == nil)
        )
        if (newIt != nil) {
            getURL(item: newIt!) { result in
                switch result {
                case .success(let url):
                    image(url)
                    logger("imageUri", url.absoluteString)
                case .failure(let failure):
                    logger(
                        "imagUri",
                        failure.localizedDescription
                    )
                }
            }
        }
    }
}

struct MultipleFloatingButton: View {
    let icon: String
    let theme: Theme
    let actionArt: () -> Void
    let actionCourse: () -> Void
    @State var isExtend: Bool = false
    
    @ViewBuilder var buttonContent: some View {
        ZStack {
            Button(action: {
                withAnimation {
                    isExtend.toggle()
                }
            }) {
                ImageAsset(icon: icon, tint: theme.textForPrimaryColor)
                    .padding(15)
                    .rotationEffect(isExtend ? Angle(degrees: -45) : Angle(degrees: 0))
                    .frame(width: 60, height: 60)
            }
            .tint(theme.textForPrimaryColor)
            .frame(width: 60, height: 60)
            .background(theme.primary)
            .cornerRadius(30)
            .shadow(radius: 10)
            .onBottomEnd()
        }.padding(trailing: 20)
    }
    
    @ViewBuilder var buttonExpendContent: some View {
        ZStack {
            ZStack {
                VStack {
                    Button(action: {
                        actionArt()
                        withAnimation {
                            isExtend.toggle()
                        }
                    }) {
                        HStack {
                            ImageAsset(icon: "plus", tint: theme.textForPrimaryColor)
                                .padding(3)
                                .frame(width: 25, height: 25)
                            Text("Article")
                                .padding(leading: -3)
                                .foregroundStyle(theme.textForPrimaryColor)
                                .font(.system(size: 14))
                                .lineLimit(1)
                        }.frame(alignment: .center)
                    }
                    .frame(width: 120, height: 50)
                    .background(theme.secondary)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    Spacer().frame(height: 20)
                    Button(action: {
                        actionCourse()
                        withAnimation {
                            isExtend.toggle()
                        }
                    }) {
                        HStack {
                            ImageAsset(icon: "plus", tint: theme.textForPrimaryColor)
                                .padding(3)
                                .frame(width: 25, height: 25)
                            Text("Course")
                                .padding(leading: -3)
                                .foregroundStyle(theme.textForPrimaryColor)
                                .font(.system(size: 14))
                                .lineLimit(1)
                        }.frame(alignment: .center)
                    }
                    .frame(width: 120, height: 50)
                    .background(theme.secondary)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }.onBottomEnd()
            }.padding(bottom: 100, trailing: 20)
        }
    }
    
    var body: some View {
        buttonContent
        if isExtend {
            buttonExpendContent.background(
                VStack {
                    Spacer()
                    ZStack {
                        Image(
                            uiImage: UIImage(
                                named: theme.isDarkMode ? "circle.black" : "circle.white"
                            ) ?? UIImage()
                        ).resizable()
                            .imageScale(.medium)
                            .aspectRatio(contentMode: .fit)
                    }
                }
            ).onTapGesture {
                withAnimation {
                    isExtend.toggle()
                }
            }
        }/* else {
            buttonContent
        }*/
    }
}

struct FloatingButton: View {
    let icon: String
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Button(action: action) {
                ImageAsset(icon: icon, tint: theme.textForPrimaryColor)
                    .padding(15)
                    .frame(width: 60, height: 60)
            }
            .tint(theme.textForPrimaryColor)
            .frame(width: 60, height: 60)
            .background(theme.primary)
            .cornerRadius(30)
            .shadow(radius: 10)
            .onBottomEnd()
        }.padding(trailing: 20)
    }
}

struct UpperNavBar : View {
    
    let list: [String]
    let currentIndex: Int
    let theme: Theme
    let onClick: (Int) -> Unit
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(0..<list.count, id: \.self) { index in
                        let it = list[index]
                        OutlinedButton(action: onClick, text: it, index: index, animate: currentIndex == index, theme: theme).id(index)
                    }
                }.frame(height: 50)
            }.onChange(currentIndex) { value in
                proxy.scrollTo(value)
            }
        }
    }
}

struct OutlinedButton : View {
    
    let action: (Int) -> Unit
    let text: String
    let index: Int
    let animate: Bool
    let theme: Theme

    private var containerColor: Color {

        animate ? theme.primary : Color.clear
    }
    
    private var contentColor: Color {
        animate ? theme.textForPrimaryColor : theme.textColor
    }
    
    var body: some View {
        Button {
            action(index)
        } label: {
            if animate {
                Text(text)
                    .foregroundStyle(theme.textForPrimaryColor)
                    .lineLimit(1)
                    .frame(height: 40)
                    .font(.system(size: 12))
                    //.padding(top: 5, leading: 15, bottom: 5, trailing: 15)
                    .padding(leading: 15, trailing: 15)
                    .background(
                        RoundedRectangle(cornerRadius: 20).fill(theme.primary)
                    ).animation(.linear(duration: 0.5), value: animate)
            } else {
                Text(text)
                    .foregroundStyle(theme.textColor)
                    .lineLimit(1)
                    .frame(height: 40)
                    .font(.system(size: 12))
                    //.padding(top: 5, leading: 15, bottom: 5, trailing: 15)
                    .padding(leading: 15, trailing: 15)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.primary, lineWidth: 1)
                    ).animation(.linear(duration: 0.5), value: animate)
            }
        }
    }
}

struct ListBody<D : ForData, Content: View> : View {
    private let list: [D]
    private var itemColor: Color = Color.clear
    private let bodyClick: (D) -> Unit
    private let content: (D) -> Content
    
    init(
        list: [D],
        itemColor: Color? = nil,
        bodyClick: @escaping (D) -> Unit,
        @ViewBuilder content: @escaping (D) -> Content
    ) {
        self.list = list
        self.itemColor = itemColor ?? self.itemColor
        self.bodyClick = bodyClick
        self.content = content
    }

    var body: some View {
        ScrollView(Axis.Set.vertical) {
            LazyVStack {
                ForEach(list) { it in
                    Button {
                        bodyClick(it)
                    } label: {
                        content(it)
                    }.frame(height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(itemColor)
                        )
                }
            }
        }
    }
}

struct ListBodyEdit<D : ForData, Content: View> : View {
    let list: [D]
    let itemColor: Color = Color.clear
    let content: (D) -> Content

    var body: some View {
        ScrollView(Axis.Set.vertical) {
            LazyVStack {
                ForEach(list) { it in
                    ZStack {
                        content(it)
                    }.frame(height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(itemColor)
                        )
                }.id(UUID().uuidString)
            }.id(UUID().uuidString)
        }.id(UUID().uuidString)
    }
}


struct ListBodyEditAdditional<D, Content: View, Additional: View> : View {
    let list: [D]
    var itemColor: Color = Color.clear
    let nav: (D) -> Unit
    @ViewBuilder let additionalItem: (() -> Additional)
    @ViewBuilder let content: (D) -> Content

    var body: some View {
        VStack {
            ScrollView(Axis.Set.vertical) {
                LazyVStack {
                    additionalItem()
                    ForEach(0..<list.count, id: \.self) { index in
                        let it = list[index]
                        Button {
                            nav(it)
                        } label: {
                            content(it)
                        }.frame(height: 80)
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 15).fill(itemColor)
                            )
                    }
                }
            }
        }
    }
}

struct ImageForCurveItem : View {
    let imageUri: String
    let size: CGFloat
    let cornerRadius: CGFloat
    
    init(imageUri: String, size: CGFloat, cornerRadius: CGFloat? = nil) {
        self.imageUri = imageUri
        self.size = size
        self.cornerRadius = cornerRadius ?? 15
    }

    var body: some View {
        VStack {
            ImageCacheView(imageUri, contentMode: .fill)
                .frame(width: size, height: size, alignment: .center)
        }.frame(width: size, height: size, alignment: .center)
            .clipShape(
                .rect(cornerRadius: cornerRadius)
            )
    }
}

struct EditButton: View {
    let color: Color
    let textColor: Color
    let sideButtonClicked: () -> Unit
    
    var body: some View {
        VStack {
            Button {
                sideButtonClicked()
            } label: {
                VStack {
                    Spacer()
                    ImageAsset(icon: "edit", tint: textColor).frame(width: 20, height: 20, alignment: .center).padding(7)
                    Spacer()
                }
            }.background(color).frame(width: 40, alignment: .center)
        }.clipShape(
            .rect(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 15,
                topTrailingRadius: 15
            )
        )
    }
}


struct TextFullPageScrollable : View {
    let text: String
    let textColor: Color

    var body: some View {
        //GeometryReader { geometry in
        ScrollView(Axis.Set.vertical) {
            VStack(alignment: .leading) {
                Text(text)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(textColor)
                    .font(.system(size: 14))
                    .padding(leading: 20, trailing: 20)
                    .lineLimit(nil).onStart()
            }
        }
        //}
    }
}


struct RadioDialog : View {
    
    let current: String
    let list: [String]
    let onDismiss: () -> Unit
    let onClick: (String) -> Unit
    var body: some View {
        ScrollView(Axis.Set.vertical) {
            VStack {
                ForEach(0..<list.count, id: \.self) { index in
                    let it: String = list[index]
                    Button(action: {
                        onClick(it)
                    }) {
                        HStack {
                            RadioButton(selected: it == current) {
                                onClick(it)
                            }
                            Text(it).padding(leading: 10)
                            Spacer()
                        }.padding(16)
                    }
                }
            }
        }
        Button("Cancel", role: .cancel) {
            onDismiss()
        }
    }
}

struct RadioButton: View {
    let selected: Bool
    let onClick: () -> Unit
    var body: some View {
        Group{
            if selected {
                ZStack{
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }.onTapGesture {onClick()}
            } else {
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .onTapGesture {onClick()}
            }
        }
    }
}

struct DialogDateTimePicker : View {
    let dateTime: Int64
    let mode: Int
    let theme: Theme
    let changeMode: () -> Unit
    let snake: (String) -> Unit
    let close: () -> Unit
    let invoke: (Int64) -> Unit
    @State var current: Int64 = currentTime
    @State private var date = Date.now

    var body: some View {
        FullZStack {
            if mode == 1 {
                DatePicker("Enter Timeline Date", selection: $date, in: Date.now...)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxHeight: 400)
            } else if mode == 2 {
                DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .frame(maxHeight: 400)
            }
        }.frame(maxHeight: 400).onAppear {
            let time = dateTime != -1 ? dateTime : current
            date = Date(timeIntervalSince1970: Double(time) / 1000)
        }
        Button("Confirm", role: .destructive) {
            if (mode == 1) {
                changeMode()
            } else {
                let t: Int64 = Int64(date.timeIntervalSince1970 * 1000)
                if (t < current) {
                    snake("Invalid Date")
                    return
                }
                invoke(t)
            }
        }
        Button("Cancel", role: .cancel) {
            close()
        }
    }
}


struct BoxGroupStyle: GroupBoxStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding(.top, 30)
            .padding(20)
            .background(color)
            .cornerRadius(20)
            .overlay(
                configuration.label.padding(10),
                alignment: .topLeading
            )
    }
}

struct LoadingBar : View {
    
    @Inject
    private var theme: Theme
    
    let isLoading: Bool
    
    var body: some View {
        if !isLoading {
            Spacer(minLength: 0)
        } else {
            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: theme.primary)).frame(width: 20, height: 20).onCenter().controlSize(.large)
        }
    }
}
struct LoadingScreen : View {
    
    @Inject
    private var theme: Theme
    
    let isLoading: Bool
    
    var body: some View {
        if !isLoading {
            Spacer(minLength: 0)
        } else {
            FullZStack {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: theme.primary)).frame(width: 20, height: 20).onCenter().controlSize(.large)
            }.background(theme.backDarkAlpha).onTapGesture {
                
            }
        }
    }
}
/**
 
 
 @Composable
 fun LoadingScreen(
     isLoading: Boolean,
     theme: Theme,
 ) {
     if (isLoading) {
         Card(
             modifier = Modifier.fillMaxSize().clickable { },
             colors = CardDefaults.cardColors(containerColor = theme.backDarkAlpha),
         ) {
             Box(
                 modifier = Modifier.fillMaxSize(),
                 contentAlignment = Alignment.Center
             ) {
                 CircularProgressIndicator(
                     modifier = Modifier,
                     color = theme.primary,
                 )
             }
         }
     } else return
 }
*/
