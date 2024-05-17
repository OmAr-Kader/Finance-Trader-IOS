import Foundation
import Combine
import RealmSwift

class ArticleStockRepoImp : BaseRepoImp, ArticleStockRepo {
    
    @BackgroundActor
    func insertArticle(_ article: Article,_ invoke: @escaping @BackgroundActor (Article?) async -> Unit) async {
        await invoke(insert(article).value)
    }
    
    @BackgroundActor
    func updateStockInfo(
        articleData: ArticleData
    ) async -> ResultRealm<Article?> {
        return await edit(try! ObjectId(string: articleData.id)) { it in
            it.copy(articleData)
        }
    }
    
    @BackgroundActor
    func getArticleLive(id: String, invoke: @escaping @BackgroundActor (Article?) -> Unit) async -> AnyCancellable? {
        return await querySingleFlow(
            invoke,
            "getArticleLive\(id)",
            "%K == %@",
            "_id", try! ObjectId(string: id)
        )
    }
    
    @BackgroundActor
    func getArticle(
        id: String,
        invoke: @BackgroundActor (ResultRealm<Article?>) -> Unit
    ) async {
        await querySingle(
            invoke,
            "getArticle\(id)",
            "%K == %@",
            "_id", try! ObjectId(string: id)
        )
    }
    
    @BackgroundActor
    func getAllArticles(
        invoke: @BackgroundActor (ResultRealm<[Article]>) -> Unit
    ) async {
        await queryAll(invoke)
    }
    
    @BackgroundActor
    func getAllArticlesLive(invoke: @escaping @BackgroundActor ([Article]?) -> Unit) async -> AnyCancellable?  {
        return await queryAllFlow(invoke, "getAllArticlesLive")
    }
    
}
