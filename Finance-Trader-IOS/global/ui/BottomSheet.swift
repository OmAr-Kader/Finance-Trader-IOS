import SwiftUI

extension View {

    func bottomSheet<V>(
        _ backDark: Color,
        _ isPresentSheet: Binding<Bool>,
        _ detentHeight: Binding<CGFloat>,
        @ViewBuilder content: @escaping () -> V
    ) -> some View where V : View {
        return sheet(isPresented: isPresentSheet) {
            VStack(content: content)
            .padding(.top)
                .readHeight(backDark)
                .onPreferenceChange(HeightPreferenceKey.self) { height in
                    if let height {
                        detentHeight.wrappedValue = height
                    }
                }
                .presentationDetents([.height(detentHeight.wrappedValue)])
                .background(backDark)
        }
    }
}

extension View {
    func readHeight(_ backDark: Color) -> some View {
        self.modifier(ReadHeightModifier(backDark: backDark))
    }
}

private struct ReadHeightModifier: ViewModifier {
    let backDark: Color
    private var sizeView: some View {
        GeometryReader { geometry in
            backDark.preference(key: HeightPreferenceKey.self, value: geometry.size.height)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}


struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        guard let nextValue = nextValue() else { return }
        value = nextValue
    }
}
