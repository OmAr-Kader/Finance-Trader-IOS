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

extension [StockData] {
    
    @BackgroundActor
    func minAndMaxValues(values: (_ stockBoarder: StockBoarder) -> (), failed: () -> ()) {
        var minXStock: [Int64] = []
        var maxXStock: [Int64] = []
        var minYStock: [Float64] = []
        var maxYStock: [Float64] = []
        self.forEach { stock in
            stock.values.minAndMaxValues { stockBoarder in
                minXStock.append(stockBoarder.minX)
                maxXStock.append(stockBoarder.maxX)
                minYStock.append(stockBoarder.minY)
                maxYStock.append(stockBoarder.maxY)
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

}

extension [StockPointData] {
    
    @BackgroundActor
    func minAndMaxValues(values: (_ stockBoarder: StockBoarder) -> ()) {
        let xSorted = self.sorted { $0.time < $1.time }
        let ySorted = self.sorted { $0.value < $1.value }
        guard let minX = xSorted.first?.time else {
            return
        }
        guard let maxX = xSorted.last?.time else {
            return
        }
        guard let minY = ySorted.first?.value else {
            return
        }
        guard let maxY = ySorted.last?.value else {
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




