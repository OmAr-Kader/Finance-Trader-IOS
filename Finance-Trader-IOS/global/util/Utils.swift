import Foundation
//import SwiftDate

typealias Unit = Void


var currentTime: Int64 {
    return Int64(Date.now.timeIntervalSince1970 * 1000.0)
}


@inlinable func catchy(completion: () throws -> ()) {
    do {
        try completion()
    } catch {
        print("==>" + error.localizedDescription)
    }
}

@inlinable func catchyR<R>(completion: () throws -> R) -> R? {
    do {
        return try completion()
    } catch let error {
        loggerError("catchy", error.localizedDescription)
        return nil
    }
}

extension Array {
    
    @inlinable func ifEmpty(_ defaultValue: () -> ()) {
        if self.isEmpty {
            defaultValue()
        }
    }
    
    @inlinable func ifNotEmpty<R>(_ defaultValue: ([Element]) -> R) -> R? {
        if (!self.isEmpty) {
            return defaultValue(self)
        } else {
            return nil
        }
    }
    
    subscript (safe index: Index) -> Element? {
        0 <= index && index < count ? self[index] : nil
    }
}

extension String {

    var firstCapital: String {
        // 1
        let firstLetter = self.prefix(1).capitalized
        // 2
        let remainingLetters = self.dropFirst().lowercased()
        // 3
        return firstLetter + remainingLetters
    }
    
    var firstSpace: String {
        let it = self.firstIndex(of: " ")
        if (it == nil) {
            return self
        } else {
            // Get range 4 places from the start, and 6 from the end.
            let r = self.index(self.startIndex, offsetBy: 0)...self.index(it!, offsetBy: 0)
            return self[r].base
        }
    }
    
    @inlinable func ifNotEmpty<R>(defaultValue: (String) -> R) -> R? {
        if (!self.isEmpty) {
            return defaultValue(self)
        } else {
            return nil
        }
    }
    
    @inlinable func ifEmpty(defaultValue: () -> Self) -> Self {
        if (self.isEmpty) {
            return defaultValue()
        } else {
            return self
        }
    }
    
    func toTime() -> Int64 {
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "dd MMM yy"
        return dateFormatter.date(from: self)!.toTimeInmillis
    }

    func toTimeDate() -> Date {
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.timeZone = .gmt
        dateFormatter.dateFormat = "dd MMM yy"
        return dateFormatter.date(from: self)!
    }

}


extension Int {

    func saveMin(_ num: Int) ->  Int {
        let min = self - num
        return min < 0 ? 0 : min
    }
}

extension Date {
    
    var toTimeInmillis: Int64 {
        return Int64(timeIntervalSince1970 * 1000.0)
    }
    
    func convertToTimeZone(_ initTimeZone: TimeZone,_ timeZone: TimeZone) -> Date {
         let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
         return addingTimeInterval(delta)
    }
}

extension Int64 {
    
    var fetchHour: Int {
        return  Calendar.current.component(.hour,
              from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    var fetchMinute: Int {
        return Calendar.current.component(.minute,
              from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    var toDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }
    
    var toDateConverted: Date {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000).convertToTimeZone(.gmt, .current)
    }
    
    func fetchTimeFromCalender(hour: Int, minute: Int) -> Int64 {
        let time = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0,
             of: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )!.timeIntervalSince1970 * 1000.0
        return Int64(time)
    }
    
    //https://help.talend.com/r/en-US/8.0/data-preparation-user-guide/list-of-date-and-date-time-formats
    var toStr: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM" //"dd MMM yy" //"d MMM yyyy"//"YY/MM/dd"
        return dateFormatter.string(
            from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    var toStrDMY: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy"
        return dateFormatter.string(
            from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    var toStrDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(
            from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    var toStrMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(
            from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    var toStrYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(
            from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    var toStrHMS: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(
            from: Date(timeIntervalSince1970: Double(integerLiteral: self) / 1000.0)
        )
    }
    
    var toMillionOrBillon: String {
        if self > 1000000000 {
            String(Float64(self) / 1000000000) + "B"
        } else if self > 1000000 {
            String(Float64(self) / 1000000) + "M"
        } else {
            String(self)
        }
    }
}

extension Float64 {
    
    var toString: String {
        String(format: "%g", self)
    }
    
    func toStr(toPlaces: Int = 2) -> String {
        String(format: "%.\(toPlaces)f", self)
    }
    
    func rounded(toPlaces places:Int) -> Float64 {
        let divisor = pow(10.0, Float64(places))
        return (self * divisor).rounded() / divisor
    }

}

