import Foundation
import RealmSwift

class Article : Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var stockId: String
    @Persisted var stockInfo: StockInfo?
    @Persisted var imageUri: String
    @Persisted var releasedDate: Int64
    @Persisted var title: String
    @Persisted var articleList: List<ArticleText>
    
    override init() {
        super.init()
        self.stockId = ""
        self.imageUri = ""
        self.releasedDate = 0
        self.title = ""
        self.articleList = List()
    }
    
    @BackgroundActor
    convenience init(articleData: ArticleData, stockInfo: StockInfo) {
        self.init()
        if !articleData.id.isEmpty {
            self._id = try! ObjectId.init(string: articleData.id)
        }
        self.stockId = articleData.stockId
        self.stockInfo = stockInfo
        self.imageUri = articleData.imageUri
        self.releasedDate = currentTime
        self.title = articleData.title
        self.articleList = articleData.articleList.toArticleText()
    }

    @BackgroundActor
    func copy(_ articleData: ArticleData) -> Self {
        self.imageUri = articleData.imageUri
        self.title = articleData.title
        self.articleList = articleData.articleList.toArticleText()
        return self
    }
    
}

class ArticleText: EmbeddedObject {
    
    @Persisted var font: Int = 14
    @Persisted var text: String = ""
    
    override init() {
        text = ""
        font = 0
    }
    
    convenience init(font: Int, text: String) {
        self.init()
        self.text = text
        self.font = font
    }
    
}

struct ArticleData : Hashable {
    
    let id: String
    let stockId: String
    let releasedDate: Int64
    private(set) var imageUri: String
    private(set) var title: String
    private(set) var articleList: [ArticleTextData]

    
    init() {
        self.id = ""
        self.stockId = ""
        self.releasedDate = currentTime
        self.imageUri = ""
        self.title = ""
        self.articleList = []
    }
    
    init(id: String, stockId: String, imageUri: String, title: String, articleList: [ArticleTextData]) {
        self.id = id
        self.stockId = stockId
        self.imageUri = imageUri
        self.title = title
        self.releasedDate = currentTime
        self.articleList = articleList
    }

    @BackgroundActor
    init(article: Article, stockId: String?) {
        self.id = article._id.stringValue
        self.stockId = stockId!
        self.releasedDate = article.releasedDate
        self.imageUri = article.imageUri
        self.title = article.title
        self.articleList = article.articleList.toArticleTextData()
    }
    
    mutating func copy(id: String? = nil, stockId: String? = nil, imageUri: String? = nil, title: String? = nil, articleList: [ArticleTextData]? = nil) -> Self {
        self.imageUri = imageUri ?? self.imageUri
        self.title = title ?? self.title
        self.articleList = articleList ?? self.articleList
        return self
    }

    mutating func append(article: ArticleTextData) -> Self {
        var articles = self.articleList
        articles.append(article)
        self.articleList = articles
        return self
    }
}


struct ArticleTextData : ForSubData {
    
    let font: Int
    var text: String
    let isHeadline: Bool
    
    init() {
        font = 14
        text = ""
        isHeadline = false
    }

    init(font: Int, text: String) {
        self.font = font
        self.text = text
        self.isHeadline = font == 18
    }
    
    mutating func copy(text: String) -> Self {
        self.text = text
        return self
    }
}
