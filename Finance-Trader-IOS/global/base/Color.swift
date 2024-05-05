import SwiftUI

extension UIUserInterfaceStyle {
    var isDarkMode: Bool {
        if self == .light {
            return false
        } else if self == .dark {
            return true
        }
        return false
    }
}

extension UIViewController {
    var appDelegate: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
   }
}

extension UIColor {
    
    var toC: Color {
        return Color(self)
    }
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }

}

extension Color {
    
    var toUic: UIColor {
        UIColor(self)
    }
    
    var margeWithPrimary: Color {
        return (toUic * 0.85 + Purple40.toUic * 0.15).toC
    }

    func margeWithPrimary(_ f: Double = 0.15) -> Color {
        return (toUic * (1.0 - f) + Purple40.toUic * f).toC
    }
    
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}

func addColor(_ color1: UIColor, with color2: UIColor) -> UIColor {
    var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

    // add the components, but don't let them go above 1.0
    return UIColor(red: min(r1 + r2, 1), green: min(g1 + g2, 1), blue: min(b1 + b2, 1), alpha: (a1 + a2) / 2)
}

func multiplyColor(_ color: UIColor, by multiplier: CGFloat) -> UIColor {
    var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    return UIColor(red: r * multiplier, green: g * multiplier, blue: b * multiplier, alpha: a)
}

func +(color1: UIColor, color2: UIColor) -> UIColor {
    return addColor(color1, with: color2)
}

func *(color: UIColor, multiplier: Double) -> UIColor {
    return multiplyColor(color, by: CGFloat(multiplier))
}

func rateColor(rate: Double) -> Color {
    return Color(UIColor(.yellow) * 0.5 + .darkGray * 0.5)
}

var Purple80: Color {
    return Color(red: 208 / 255, green: 188 / 255, blue: 255 / 255)
}
 
var Purple40: Color {
    return Color(red: 102 / 255, green: 80 / 255, blue: 164 / 255)
}

var DarkGray: Color {
    return Color(red: 22 / 255, green: 22 / 255, blue: 22 / 255)
}

var LightViolet: Color {
    return Color(red: 229 / 255, green: 215 / 255, blue: 232 / 255)
}

var shadowColor: Color {
    //Color(red: 0, green: 0, blue: 0, opacity: 50)
    return UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5).toC
}

var PurpleGrey80: Color {
    return Color(red: 204  / 255, green: 194 / 255, blue: 220 / 255)
}
var Pink80: Color {
    return Color(red: 239 / 255,green: 184 / 255, blue: 200 / 255)
}

var PurpleGrey40: Color {
    return Color(red: 98 / 255, green: 91 / 255, blue: 113 / 255)
}

var Pink40: Color {
    return Color(red: 125 / 255, green: 82 / 255, blue: 96 / 255)
}

var Green: Color {
    return Color(red: 1 / 255, green: 189 / 255, blue: 1 / 255)
}

var Blue: Color {
    return Color(red: 13 / 255, green: 23 / 255, blue: 213 / 255)
}

var Yellow: Color {
    return Color(red: 224 / 255, green: 224 / 255, blue: 12 / 255)
}

var BackSec: Color {
    return Color(red: 61 / 255, green: 61 / 255, blue: 61 / 255)
}

var BackSecDark: Color {
    return Color(red: 201 / 255, green: 201 / 255, blue: 201 / 255)
}

var colorBarIOS: Color {
    return Color(red: 9 / 255, green: 131 / 255, blue: 1)
}
