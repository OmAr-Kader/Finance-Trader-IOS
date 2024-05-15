import SwiftUI
import _PhotosUI_SwiftUI


struct CreateArticleScreen : View {
    
    @StateObject var app: AppObserve
    
    @Inject
    private var theme: Theme
    @State private var scrollTo: Int = 0

    @StateObject private var obs: CreateArticleObservable = CreateArticleObservable()
    @State private var toast: Toast? = nil
    
    var body: some View {
        let state = obs.state
        let isArticleTitleError = state.isErrorPressed && state.article.title.isEmpty
        ZStack {
            if state.stockInfo.id.isEmpty {
                VStack {
                    Text("Choose An Article's Stock").foregroundStyle(theme.textColor).font(.headline).onCenter().padding(   )
                    StockCompareSearch(stocksSearch: state.stocksSearch, onSearch: obs.onSearch, addStock: obs.addStock)
                }.background(theme.backDark).cornerRadius(15).padding(top: 15, leading: 15, bottom: 0, trailing: 15)
            } else {
                VStack {
                    ImageArticleView(state: state) { url in
                        obs.setImageUri(it: url.absoluteString)
                    } nav: {}
                    ScrollViewReader { proxy in
                        ScrollView(Axis.Set.vertical) {
                            LazyVStack {
                                OutlinedTextField(text: state.article.title, onChange: { it in
                                    obs.setArticleTitle(it)
                                }, hint: "Enter Article Title", isError: isArticleTitleError, errorMsg: "Shouldn't be empty", theme: theme, cornerRadius: 10, lineLimit: 1, keyboardType: .default
                                ).padding(top: 5, leading: 20, bottom: 5, trailing: 20)
                                ForEach(Array(state.article.articleList.enumerated()), id: \.offset) { index, data in
                                    let it = data as ArticleTextData
                                    HStack(alignment: .center) {
                                        OutlinedTextField(
                                            text: it.text,
                                            onChange: { text in
                                                obs.changeAbout(it: text, index: index)
                                            },
                                            hint: it.isHeadline ? "Enter Article Headline" : "Enter Article",
                                            isError: false,
                                            errorMsg: "",
                                            theme: theme,
                                            cornerRadius: 15,
                                            lineLimit: nil,
                                            keyboardType: .default,
                                            font: CGFloat(it.font)
                                        )
                                        Button(action: {
                                            if (index == state.article.articleList.count - 1) {
                                                obs.makeFontDialogVisible()
                                                scrollTo = state.article.articleList.count + 4
                                            } else {
                                                obs.removeAboutIndex(index: index)
                                            }
                                        }, label: {
                                            VStack {
                                                VStack {
                                                    ImageAsset(
                                                        icon: index == (state.article.articleList.count - 1) ? "plus" : "delete",
                                                        tint: theme.textColor
                                                    )
                                                }.padding(7).background(
                                                    theme.background.margeWithPrimary(0.3)
                                                )
                                            }.clipShape(Circle())
                                        }).frame(width: 40, height: 40)
                                    }.padding(top: 5, leading: 20, bottom: 5, trailing: 20)
                                }
                                if state.isFontDialogVisible {
                                    AboutArticleCreator { it in
                                        obs.addAbout(type: it)
                                    }
                                }
                            }
                        }.onChange(scrollTo) { value in
                            proxy.scrollTo(value)
                        }
                    }
                    Spacer()
                    ButtonCurvedGradient(text: "Upload", cornerRadius: 15, textColor: theme.textForPrimaryColor, color: theme.primary.gradient) {
                        obs.insertArticle(stockInfo: state.stockInfo) {
                            app.backPress()
                        } failed: {
                            toast = Toast(style: .error, message: "Failed")
                        }
                        
                    }
                }
            }
            LoadingScreen(isLoading: state.isLoading)
        }.animation(.easeOut, value: state.stockInfo).toastView(toast: $toast).withCustomBackButton {
            app.backPress()
        }.onAppear {
            obs.loadData()
        }
    }
}


struct ImageArticleView : View {
    let state: CreateArticleObservable.State
    let imagePicker: (URL) -> Unit
    let nav: () -> Unit
    
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack {
            if state.article.imageUri.isEmpty {
                FullZStack {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        ImageAsset(icon: "upload", tint: .white)
                            .frame(width: 60, height: 60).padding(5)
                    }.onChange(selectedItem, forChangePhoto(imagePicker)).frame(
                        width: 60, height: 60, alignment: .center
                    )
                }.frame(height: 200).background(
                    UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.64).toC
                )
            } else {
                ZStack {
                    FullZStack {
                        ImageCacheView(state.article.imageUri)
                            .frame(height: 200)
                    }.frame(height: 200)
                    FullZStack {
                        HStack {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images
                            ) {
                                ImageAsset(icon: "upload", tint: .white)
                                    .frame(width: 45, height: 45).padding(5)
                            }.onChange(selectedItem, forChangePhoto(imagePicker)).frame(
                                width: 45, height: 45, alignment: .center
                            )
                            Spacer().frame(width: 20)
                            ImageAsset(icon: "photo", tint: .white)
                                .frame(width: 45, height: 45).padding(5).onTapGesture {
                                    nav()
                                }
                        }
                    }.frame(height: 200).background(
                        UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.64).toC
                    )
                }
            }
        }
    }
}


struct AboutArticleCreator : View {
    let addAbout: (Int) -> ()
    
    @Inject private var theme: Theme
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Button(action: {
                    addAbout(14)
                }, label: {
                    Text("Small Font").foregroundStyle(theme.textColor)
                }).padding(5)
                Divider().frame(width: 1, height: 30).foregroundStyle(Color.gray)
                Button(action: {
                    addAbout(18)
                }, label: {
                    Text("Big Font").foregroundStyle(theme.textColor)
                }).padding(5)
            }.padding(5).frame(maxHeight: 300).background(theme.backDarkThr)
        }.clipShape(RoundedRectangle(cornerRadius: 20)).shadow(radius: 2)
    }
}
