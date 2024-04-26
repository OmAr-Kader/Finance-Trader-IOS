import SwiftUI

struct Theme {
    let isDarkMode: Bool
    let isDarkStatusBarText: Bool
    let primary: Color
    let secondary: Color
    let background: Color
    let surface: Color
    let onPrimary: Color
    let onSecondary: Color
    let onBackground: Color
    let onSurface: Color
    let backDark: Color
    let backDarkSec: Color
    let backDarkThr: Color
    let backGreyTrans: Color
    let textColor: Color
    let textForPrimaryColor: Color
    let textGrayColor: Color
    let error: Color
    let textHintColor: Color
    let textHintAlpha: Color
    let backDarkAlpha: Color
    let primaryAlpha: Color

    init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        if (isDarkMode) {
            self.isDarkStatusBarText = true
            self.primary = Purple80
            self.secondary = PurpleGrey80
            self.background = DarkGray
            self.surface = DarkGray
            self.onPrimary = Color.white
            self.onSecondary = BackSecDark
            self.onBackground = Color(red: 28 / 255, green: 27 / 255, blue: 31 / 255)
            self.onSurface = Color.white
            self.backDark = Color(red: 41 / 255, green: 41 / 255, blue: 41 / 255)
            self.backDarkSec = Color(red: 61 / 255, green: 61 / 255, blue: 61 / 255)
            self.backDarkThr = Color(red: 100 / 255, green: 100 / 255, blue: 100 / 255)
            self.backGreyTrans = UIColor(_colorLiteralRed: 85 / 255, green: 85 / 255, blue: 85 / 255, alpha: 0.33).toC
            self.textColor = Color.white
            self.textForPrimaryColor = Color.black
            self.textGrayColor = Color(UIColor.lightGray)
            self.error = Color(red: 255 / 255, green: 21 / 255, blue: 21 / 255)
            self.textHintColor = Color(red: 175 / 255, green: 175 / 255, blue: 175 / 255)
            self.textHintAlpha = UIColor(_colorLiteralRed: 175 / 255, green: 175 / 255, blue: 175 / 255, alpha: 0.5).toC
            self.backDarkAlpha = UIColor(_colorLiteralRed: 31 / 255, green: 31 / 255, blue: 31 / 255, alpha: 0.5).toC
            self.primaryAlpha = UIColor(_colorLiteralRed: 208 / 255, green: 188 / 255, blue: 255 / 255, alpha: 0.5).toC
        } else {
            self.isDarkStatusBarText = false
            self.primary = Purple40
            self.secondary = PurpleGrey40
            self.background = .white
            self.surface = .white
            self.onPrimary = Color.black
            self.onSecondary = BackSec
            self.onBackground = Color(red: 28 / 255, green: 27 / 255, blue: 31 / 255)
            self.onSurface = Color.black
            self.backDark = Color(red: 241 / 255, green: 241 / 255, blue: 241 / 255)
            self.backDarkSec = Color(red: 201 / 255, green: 201 / 255, blue: 201 / 255)
            self.backDarkThr = Color(red: 172 / 255, green: 172 / 255, blue: 172 / 255)
            self.backGreyTrans = UIColor(_colorLiteralRed: 170 / 255, green: 170 / 255, blue: 170 / 255, alpha: 0.33).toC
            self.textColor = Color.black
            self.textForPrimaryColor = Color.white
            self.textGrayColor = Color(UIColor.darkGray)
            self.error = Color(red: 155 / 255, green: 0, blue: 0)
            self.textHintColor = Color(red: 80 / 255, green: 80 / 255, blue: 80 / 255)
            self.textHintAlpha = UIColor(_colorLiteralRed: 80 / 255, green: 80 / 255, blue: 80 / 255, alpha: 0.5).toC
            self.backDarkAlpha = UIColor(_colorLiteralRed: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 0.5).toC
            self.primaryAlpha = UIColor(_colorLiteralRed: 102 / 255, green: 80 / 255, blue: 164 / 255, alpha: 0.5).toC
        }
    }
    
    /*func colorScheme(screen: Screen) -> ColorScheme {
        return screen == .SPLASH_SCREEN_ROUTE ? (isDarkMode ? ColorScheme.dark : ColorScheme.light) : (isDarkStatusBarText ? ColorScheme.light : ColorScheme.dark)
    }*/
    
    func textFieldColor(isError: Bool, isEmpty: Bool) -> Color {
        if (isError) {
            return error
        } else {
            return isEmpty ? Color.black.opacity(0.7) : Color.black
        }
    }
}
