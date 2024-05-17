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

extension [StockPointData] {
    
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

extension [StockInfo] {
    
    @BackgroundActor
    func toStockInfoData() -> [StockInfoData] {
        return self.map { it in
            StockInfoData(stockInfo: it)
        }
    }
    
}

extension List<ArticleText> {
    
    @BackgroundActor
    func toArticleTextData() -> [ArticleTextData] {
        return self.toList().map { it in
            ArticleTextData(font: it.font, text: it.text)
        }
    }
}

extension [ArticleTextData] {
    
    @BackgroundActor
    func toArticleText() -> List<ArticleText> {
        return self.map { it in
            ArticleText(font: it.font, text: it.text)
        }.toRealmList()
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


extension [Article] {
    
    @BackgroundActor
    func toArticleData() -> [ArticleData] {
        return self.map { it in
            ArticleData(article: it, stockId: it.stockId)
        }
    }
}

extension [SupplyDemand] {
    
    @BackgroundActor
    func toSupplyDemandData() -> [SupplyDemandData] {
        return self.map { it in
            SupplyDemandData(supplyDemand: it, stockId: it.stockInfo?._id.stringValue)
        }
    }
}

extension [StockSession] {
    
    @BackgroundActor
    func toStockData() -> [StockData] {
        return self.map { it in
            StockData(it, stockId: it.stockInfo!._id.stringValue)
        }
    }
}


extension LinkingObjects<StockSession> {
    
    @BackgroundActor
    func toStockData(stockId: String) -> [StockData] {
        return self.map { it in
            StockData(it, stockId: stockId)
        }
    }
}
