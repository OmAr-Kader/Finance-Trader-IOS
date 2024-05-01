import Foundation
import RealmSwift


extension List {
    
    func toList() -> [Element] {
        var list: [Element] = [Element]()
        self.forEach { it in
            list.append(it)
        }
        return list
    }

}

extension Array<String> {
    
    func toRealmList() -> List<String> {
        let realmList: List<String> = List()
        self.forEach { it in
            realmList.append(it)
        }
        return realmList
    }

}

extension Array where Element : EmbeddedObject {
    
    func toRealmList() -> List<Element> {
        let realmList: List<Element> = List()
        self.forEach { it in
            realmList.append(it)
        }
        return realmList
    }

}

extension Array where Element : Object {
    
    func toRealmList() -> List<Element> {
        let realmList: List<Element> = List()
        self.forEach { it in
            realmList.append(it)
        }
        return realmList
    }
}

extension [StockBoarder] {
    
    @BackgroundActor
    func minAndMaxValues(_ mode: ChartMode, values: (_ stockBoarder: StockBoarder) -> (), failed: () -> ()) {
        var minXStock: [Int64] = []
        var maxXStock: [Int64] = []
        var minYStock: [Float64] = []
        var maxYStock: [Float64] = []
        self.forEach { stockBoarder in
            minXStock.append(stockBoarder.minX)
            maxXStock.append(stockBoarder.maxX)
            minYStock.append(stockBoarder.minY)
            maxYStock.append(stockBoarder.maxY)
        }
        guard let minX = minXStock.sorted().first else {
            failed()
            return
        }
        guard let maxX = maxXStock.sorted().last else {
            failed()
            return
        }
        guard let minY = minYStock.sorted().first else {
            failed()
            return
        }
        guard let maxY = maxYStock.sorted().last else {
            failed()
            return
        }
        values(StockBoarder(minX: minX, maxX: maxX, minY: minY, maxY: maxY))
    }
    
}

extension [StockData] {
    
    @BackgroundActor
    func minAndMaxValues(_ mode: ChartMode, values: (_ stockBoarder: StockBoarder) -> (), failed: () -> ()) {
        var minXStock: [Int64] = []
        var maxXStock: [Int64] = []
        var minYStock: [Float64] = []
        var maxYStock: [Float64] = []
        self.forEach { stock in
            stock.values.minAndMaxValues(mode) { stockBoarder in
                minXStock.append(stockBoarder.minX)
                maxXStock.append(stockBoarder.maxX)
                minYStock.append(stockBoarder.minY)
                maxYStock.append(stockBoarder.maxY)
            } failed: {
                
            }
        }
        guard let minX = minXStock.sorted().first else {
            failed()
            return
        }
        guard let maxX = maxXStock.sorted().last else {
            failed()
            return
        }
        guard let minY = minYStock.sorted().first else {
            failed()
            return
        }
        guard let maxY = maxYStock.sorted().last else {
            failed()
            return
        }
        values(StockBoarder(minX: minX, maxX: maxX, minY: minY, maxY: maxY))
    }
    
    func injectColor() -> [StockData] {
        let colors: [ColorUI] = [.blue, .green, .red, .orange, .pink, .purple, .mint, .cyan, .teal]
        var stocks = self
        for i in self.indices {
            stocks[i].color = colors[safe: i] ?? ColorUI.random()
        }
        return stocks
    }

}

extension [StockPointData] {
    
    @BackgroundActor
    func minAndMaxValues(_ mode: ChartMode, values: (_ stockBoarder: StockBoarder) -> (), failed: () -> ()) {
        let xSorted = self.sorted { $0.time < $1.time }
        let ySorted = switch mode {
        case .StockSMA: self.sorted { $0.sma < $1.sma }
        case .StockEMA: self.sorted { $0.ema < $1.ema }
        case .StockRSI: self.sorted { $0.rsi < $1.rsi }
        default: self.sorted { $0.value < $1.value }
        }
        guard let minX = xSorted.first?.time else {
            failed()
            return
        }
        guard let maxX = xSorted.last?.time else {
            failed()
            return
        }
        guard let minY = switch mode {
        case .StockSMA: ySorted.first?.sma
        case .StockEMA: ySorted.first?.ema
        case .StockRSI: ySorted.first?.rsi
        default: ySorted.first?.value
        } else {
            failed()
            return
        }
        guard let maxY = switch mode {
        case .StockSMA: ySorted.last?.sma
        case .StockEMA: ySorted.last?.ema
        case .StockRSI: ySorted.last?.rsi
        default : ySorted.last?.value
        } else {
            failed()
            return
        }
        values(StockBoarder(minX: minX, maxX: maxX, minY: minY, maxY: maxY))
    }
    
    @BackgroundActor
    func toStockPoint() -> List<StockPoint> {
        return self.map { it in
            StockPoint(stockPointData: it)
        }.toRealmList()
    }
    
}



extension List<StockPoint> {
    
    @BackgroundActor
    func toStockPointData() -> [StockPointData] {
        return self.toList().map { it in
            StockPointData(stock: it)
        }
    }
}




extension [StockHolderData] {
    
    
    @BackgroundActor
    func toStockHolder() -> List<StockHolder> {
        return self.map { it in
            StockHolder(holderId: it.holderId, holderShares: it.holderShares)
        }.toRealmList()
    }
    
}



extension List<StockHolder> {
    
    @BackgroundActor
    func toStockHolderData() -> [StockHolderData] {
        return self.toList().map { it in
            StockHolderData(holderId: it.holderId, holderShares: it.holderShares)
        }
    }
}


