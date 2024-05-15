import Foundation
import Combine

protocol ArticleStockRepo {
    
    @BackgroundActor
    func insertArticle(_ article: Article,_ invoke: @escaping @BackgroundActor (Article?) async -> Unit) async
    
    @BackgroundActor
    func updateStockInfo(
        articleData: ArticleData
    ) async -> ResultRealm<Article?>
    
    @BackgroundActor
    func getArticleLive(id: String, invoke: @escaping @BackgroundActor (Article?) -> Unit) async -> AnyCancellable?
    
    @BackgroundActor
    func getArticle(
        id: String,
        invoke: @BackgroundActor (ResultRealm<Article?>) -> Unit
    ) async
    
    @BackgroundActor
    func getAllArticles(
        invoke: @BackgroundActor (ResultRealm<[Article]>) -> Unit
    ) async
    
}
