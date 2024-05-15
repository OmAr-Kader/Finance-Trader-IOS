import SwiftUI

struct OutlinedTextField : View {
    
    let text: String
    let onChange: (String) -> Unit
    let hint: String
    let isError: Bool
    let errorMsg: String
    let theme: Theme
    let cornerRadius: CGFloat
    let lineLimit: Int?
    let keyboardType: UIKeyboardType?
    let backColor: Color?
    let font: CGFloat
    let isInitFocused: Bool
    
    @FocusState private var isFocused: Bool

    init(text: String, onChange: @escaping (String) -> Unit, hint: String, isError: Bool, errorMsg: String, theme: Theme, cornerRadius: CGFloat, lineLimit: Int?, keyboardType: UIKeyboardType?, backColor: Color? = nil, font: CGFloat? = nil, isInitFocused: Bool = false
    ) {
        self.text = text
        self.onChange = onChange
        self.hint = hint
        self.isError = isError
        self.errorMsg = errorMsg
        self.theme = theme
        self.cornerRadius = cornerRadius
        self.lineLimit = lineLimit
        self.keyboardType = keyboardType
        self.backColor = backColor
        self.font = font ?? 14
        self.isInitFocused = isInitFocused
    }

    var body: some View {
        VStack {
            
            TextField(
                "",
                text: Binding(get: {
                    text
                }, set: { it, t in
                    onChange(it)
                }),
                axis: lineLimit == nil ? Axis.vertical : Axis.horizontal
            ).placeholder(when: text.isEmpty, alignment: .leading) {
                Text(hint).foregroundColor(theme.textHintColor)
            }.foregroundStyle(theme.textColor)
                .font(.system(size: font))
                .padding(
                    EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 15)
                )
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(lineLimit)
                .focused($isFocused)
                .keyboardType(keyboardType ?? .default)
                .preferredColorScheme(theme.isDarkMode ? .dark : .light)
                .autocapitalization(.none)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backColor ?? .clear)
                        .stroke(
                            isError ? theme.error : (isFocused ? theme.primary : theme.secondary),
                            lineWidth: backColor == nil ? 1.5 : 0
                        )
                ).onTapGesture {
                    isFocused = true
                }.onAppearTask(delay: isInitFocused ? 0.35 : 0) {
                    if isInitFocused {
                        await MainActor.run {
                            isFocused = true
                        }
                    }
                }.onDisappear {
                    isFocused = false
                }
            if isError {
                HStack {
                    Text(errorMsg).padding(
                        EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
                    ).foregroundStyle(theme.error)
                        .font(.system(size: 14))
                    Spacer()
                }
            }
        }
    }
}


struct OutlinedTextFieldButton : View {
    
    let text: String
    let onClick: () -> Unit
    let isError: Bool
    let theme: Theme

    var body: some View {
        VStack {
            Button(action: onClick) {
                Text(
                    text
                ).foregroundStyle(theme.textColor)
                    .font(.system(size: 14))
                    .padding(
                        EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 15)
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .preferredColorScheme(theme.isDarkMode ? .dark : .light)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(
                                isError ? theme.error : theme.secondary,
                                lineWidth: 1.5
                            )
                    )
            }
        }
    }
}

struct OutlinedSecureField : View {
    
    let text: String
    let onChange: (String) -> Unit
    let hint: String
    let isError: Bool
    let errorMsg: String
    let theme: Theme
    let cornerRadius: CGFloat
    let lineLimit: Int?
    let keyboardType: UIKeyboardType?

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            SecureField(
                "",
                text: Binding(get: {
                    text
                }, set: { it, t in
                    onChange(it)
                })
            ).placeholder(when: text.isEmpty, alignment: .leading) {
                Text(hint).foregroundColor(theme.textHintColor)
            }.foregroundStyle(theme.textColor)
                .font(.system(size: 14))
                .padding(
                    EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 15)
                )
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(lineLimit)
            .focused($isFocused)
            .keyboardType(keyboardType ?? .default)
            .preferredColorScheme(theme.isDarkMode ? .dark : .light)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isError ? theme.error : (isFocused ? theme.primary : theme.secondary),
                        lineWidth: 1.5
                    )
            ).onTapGesture {
                isFocused = true
            }
            if isError {
                HStack {
                    Text(errorMsg).padding(
                        EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
                    ).foregroundStyle(theme.error)
                        .font(.system(size: 14))
                    Spacer()
                }
            }
        }
    }
}


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
