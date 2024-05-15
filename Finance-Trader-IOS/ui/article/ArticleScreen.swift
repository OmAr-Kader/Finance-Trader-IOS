import SwiftUI


struct ArticleScreen : View {
    
    @StateObject var app: AppObserve
    
    let articleId: String

    @Inject
    private var theme: Theme
    
    @StateObject private var obs: ArticleObservable = ArticleObservable()
    
    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                ImageCacheView(
                    state.article.imageUri)
                .frame(height: 200)
                HStack {
                    Text(
                        state.article.title
                    ).foregroundStyle(theme.textColor)
                        .font(.system(size: 22))
                        .padding(leading: 5, trailing: 5).onStart()
                    Spacer()
                }
                Spacer().frame(height: 10)
                ScrollView(Axis.Set.vertical) {
                    VStack(alignment: .leading) {
                        ForEach(Array(state.article.articleList.enumerated()), id:\.offset) { idx, data in
                            let articleText = data as ArticleTextData
                            Text(articleText.text)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(theme.textColor)
                                .font(.system(size: CGFloat(articleText.font)))
                                .padding(leading: 20, bottom: articleText.isHeadline ? 1: 5, trailing: 20)
                                .lineLimit(nil)
                                .onStart()
                        }
                    }
                }
            }
            LoadingScreen(isLoading: state.isLoading)
        }.background(theme.backDark).withCustomBackButton {
            app.backPress()
        }.onAppear {
            obs.loadData(articleId)
        }
    }
}
