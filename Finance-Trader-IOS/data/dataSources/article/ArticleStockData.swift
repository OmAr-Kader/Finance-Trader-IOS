import Foundation
import Combine

class ArticleStockData {
    
    let repository: ArticleStockRepo
    
    init(repository: ArticleStockRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func insertArticle(_ article: Article,_ invoke: @escaping @BackgroundActor (Article?) async -> Unit) async {
        await repository.insertArticle(article, invoke)
    }
    
    @BackgroundActor
    func updateStockInfo(
        articleData: ArticleData
    ) async -> ResultRealm<Article?> {
        return await repository.updateStockInfo(articleData: articleData)
    }
    
    @BackgroundActor
    func getArticleLive(id: String, invoke: @escaping @BackgroundActor (Article?) -> Unit) async -> AnyCancellable? {
        return await repository.getArticleLive(id: id, invoke: invoke)
    }
    
    @BackgroundActor
    func getArticle(
        id: String,
        invoke: @BackgroundActor (ResultRealm<Article?>) -> Unit
    ) async {
        await repository.getArticle(id: id, invoke: invoke)
    }
    
    @BackgroundActor
    func getAllArticles(
        invoke: @BackgroundActor (ResultRealm<[Article]>) -> Unit
    ) async {
        await repository.getAllArticles(invoke: invoke)
    }
    
    @BackgroundActor
    func getAllArticlesLive(invoke: @escaping @BackgroundActor ([Article]?) -> Unit) async -> AnyCancellable? {
        return await repository.getAllArticlesLive(invoke: invoke)
    }
}
