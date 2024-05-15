import Foundation
import SwiftUI

class ArticleObservable : ObservableObject {
    
    
    private var scope = Scope()

    @Inject
    private var project: Project
    
    @MainActor
    @Published var state = State()

    @MainActor
    func loadData(_ articleId: String) {
        loadingMainStatus(true)
        self.scope.launchRealm {
            await self.project.article.getArticle(id: articleId) { it in
                guard let _article = it.value else {
                    self.scope.launchMain {
                        self.loadingMainStatus(false)
                    }
                    return
                }
                let article = ArticleData(article: _article, stockId: _article.stockId)
                self.scope.launchMain {
                    self.state = self.state.copy(article: article, isLoading: false)
                }
            }
        }
    }
    
    @MainActor
    private func loadingMainStatus(_ it: Bool) {
        if it == true {
            self.state = self.state.copy(isLoading: it)
        } else {
            withAnimation {
                self.state = self.state.copy(isLoading: it)
            }
        }
    }
    
    struct State {
        var article: ArticleData = ArticleData()
        var isLoading: Bool = false

        var dummy: Int = 1

        mutating func copy(
            article: ArticleData? = nil,
            isLoading: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.article = article ?? self.article
            self.isLoading = isLoading ?? self.isLoading
            self.dummy = dummy ?? self.dummy
            return self
        }
    }
    
}
