import Foundation
import SwiftUI

class CreateArticleObservable : ObservableObject {
    
    private var scope = Scope()

    @Inject
    private var project: Project
    
    @MainActor
    @Published var state = State()

    @MainActor
    func loadData() {
        loadingMainStatus(true)
        self.scope.launchRealm {
            await self.project.stockInfo.getAllStockInfo { it in
                let stocks = it.value.toStockInfoData()
                self.scope.launchMain {
                    self.state = self.state.copy(stocksInfo: stocks, stocksSearch: stocks, isLoading: false)
                }
            }
        }
    }
    
    @MainActor
    func addStock(_ stockInfoData: StockInfoData) {
        self.state = self.state.copy(article: state.article.append(article: ArticleTextData(font: 18, text: "")), stockInfo: stockInfoData)
    }
    
    @MainActor
    func insertArticle(stockInfo: StockInfoData, invoke: @escaping @MainActor () -> (), failed: @escaping @MainActor () -> ()) {
        loadingMainStatus(true)
        let state = state
        self.scope.launchRealm {
            await self.project.article.insertArticle(Article(articleData: state.article, stockInfo: StockInfo(stockInfoData: stockInfo))) { it in
                guard it != nil else {
                    self.scope.launchMain {
                        failed()
                        self.loadingMainStatus(false)
                    }
                    return
                }
                self.scope.launchMain {
                    invoke()
                }
            }
        }
    }
    
    @MainActor
    func addAbout(type: Int) {
        state = state.copy(article: state.article.append(article: ArticleTextData(font: type, text: "")), isFontDialogVisible: false)
    }
    
    @MainActor
    func changeAbout(it: String, index: Int) {
        var listT: [ArticleTextData] = state.article.articleList
        listT[index] = listT[index].copy(text: it)
        let articleList = listT
        state = state.copy(article: state.article.copy(articleList: articleList), dummy: state.dummy + 1)
    }
    
    @MainActor
    func removeAboutIndex(index: Int) {
        var listT: [ArticleTextData] = state.article.articleList
        listT.remove(at: index)
        let articleList = listT
        state = state.copy(article: state.article.copy(articleList: articleList), dummy: state.dummy + 1)
    }
    
    @MainActor
    func setArticleTitle(_ it: String) {
        state = state.copy(article: state.article.copy(title: it), dummy: state.dummy + 1)
    }

    func setImageUri(it: String) {
        self.scope.launchMain {
            self.state = self.state.copy(article: self.state.article.copy(imageUri: it), dummy: self.state.dummy + 1)
        }
    }
    
    @MainActor
    func makeFontDialogVisible() {
        state = state.copy(isFontDialogVisible: true)
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
    
    private func loadingStatus(_ it: Bool) {
        if it == true {
            self.scope.launchMain {
                self.state = self.state.copy(isLoading: it)
            }
        } else {
            self.scope.launchMain {
                withAnimation {
                    self.state = self.state.copy(isLoading: it)
                }
            }
        }
    }

    @MainActor
    func onSearch(str: String) {
        let state = self.state
        self.scope.launchMed {
            let stocksSearch = if str.isEmpty {
                state.stocksInfo
            } else {
                state.stocksInfo.filter { it in
                    it.name.range(of: str, options: .caseInsensitive) != nil || it.symbol.range(of: str, options: .caseInsensitive) != nil
                }
            }
            self.scope.launchMain {
                self.state = self.state.copy(stocksSearch: stocksSearch)
            }
        }
    }
    
    struct State {
        var article: ArticleData = ArticleData()
        var stockInfo: StockInfoData = StockInfoData()
        var stocksInfo: [StockInfoData] = []
        var stocksSearch: [StockInfoData] = []
        var isLoading: Bool = false
        var isFontDialogVisible: Bool = false
        var isErrorPressed: Bool = false
        var dummy: Int = 1

        mutating func copy(
            article: ArticleData? = nil,
            stockInfo: StockInfoData? = nil,
            stocksInfo: [StockInfoData]? = nil,
            stocksSearch: [StockInfoData]? = nil,
            isLoading: Bool? = nil,
            isErrorPressed: Bool? = nil,
            isFontDialogVisible: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.article = article ?? self.article
            self.stockInfo = stockInfo ?? self.stockInfo
            self.stocksInfo = stocksInfo ?? self.stocksInfo
            self.stocksSearch = stocksSearch ?? self.stocksSearch
            self.isLoading = isLoading ?? self.isLoading
            self.isErrorPressed = isErrorPressed ?? self.isErrorPressed
            self.isFontDialogVisible = isFontDialogVisible ?? self.isFontDialogVisible
            self.dummy = dummy ?? self.dummy
            return self
        }
    }
    
}
