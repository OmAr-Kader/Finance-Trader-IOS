import Foundation
import AVFoundation
import SwiftUI
import Combine
import _PhotosUI_SwiftUI

struct ImageAsset : View {
    
    let icon: String
    let tint: Color
    
    var body: some View {
        Image(
            uiImage: UIImage(
                named: icon
            )?.withTintColor(UIColor(tint)) ?? UIImage()
        ).resizable()
            .renderingMode(.template)
            .foregroundColor(tint)
            .background(Color.clear)
            .imageScale(.medium)
            .aspectRatio(contentMode: .fill)
    }
}

struct ImageCacheView : View {
    
    private let urlString: String
    private let isVideoPreview: Bool
    private let contentMode: ContentMode
    @StateObject private var obs: UrlImageModel
    
    init(_ urlString: String, isVideoPreview: Bool = false, contentMode: ContentMode = .fit) {
        self.urlString = urlString
        self.isVideoPreview = isVideoPreview
        self.contentMode = contentMode
        self._obs = StateObject(
            wrappedValue: UrlImageModel(url: URL(string: urlString), isPreview: isVideoPreview)
        )
    }
    
    var body: some View {
        Image(uiImage: obs.image ?? UIImage())
            .resizable()
            .renderingMode(.original)
            .background(Color.clear)
            .imageScale(.large)
            .aspectRatio(contentMode: contentMode)
            .onChange(urlString) { it in
                if obs.image == nil {
                    obs.inti(url: URL(string: urlString), isPreview: isVideoPreview)
                }
            }
    }
    
}


class UrlImageModel: ObservableObject {
    @Published var image: UIImage?
    private var url: URL?
    private var cancellable: AnyCancellable?
    private var imageCache = ImageCache.getImageCache()

    init(url: URL?, isPreview: Bool) {
        self.url = url
        if isPreview {
            loadVideo()
        } else {
            loadImage()
        }
    }
    
    func inti(url: URL?, isPreview: Bool) {
        self.url = url
        if isPreview {
            loadVideoFromURL()
        } else {
            loadImage()
        }
    }

    func loadImage() {
        if loadImageFromCache() {
            print("Cache hit")
            return
        }
        print("Cache missing, loading from url")
        loadImageFromUrl()
    }
    
    func loadVideo() {
        if loadImageFromCache() {
            print("Cache hit")
            return
        }
        print("Cache missing, loading from url")
        loadVideoFromURL()
    }

    func loadImageFromCache() -> Bool {
        guard let url = url else {
            return false
        }
        guard let cacheImage = imageCache[url] else {
            return false
        }
        image = cacheImage
        return true
    }

    func loadImageFromUrl() {
        guard let url = url else {
            return
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            // set image into cache!
            .handleEvents(receiveOutput: { [weak self] image in
                print("WWW URL => " + String(image == nil))
                guard let image = image else {return}
                if self == nil {
                    return
                }
                Task { @MainActor [weak self] in
                    self?.image = image
                    self?.imageCache[url] = image
                }
            })
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    /*private func loadImageFromURL() {
        print("WWW URL => " + (url?.absoluteString ?? "NULL"))
        guard let url = url else {
            return
        }
        print("WWW URL => " + url.absoluteString)
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error ?? "unknown error")
                return
            }

            guard let data = data else {
                print("No data found")
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let loadedImage = UIImage(data: data) else { return }
                print("WWW URL => " + "LOADED")
                self?.image = loadedImage
                self?.imageCache[url] = loadedImage
            }
        }.resume()
    }*/
    
    private func loadVideoFromURL() {
        guard let url = url else {
            return
        }
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            self.image = thumbnail
            self.imageCache[url] = image
        } catch {

        }
    }
}

class ImageCache {
    var cache = NSCache<NSURL, UIImage>()

    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()

    static func getImageCache() -> ImageCache {
        return imageCache
    }
}

struct PhotoPiceker<Content : View> : View {

    @State private var selectedItem: PhotosPickerItem?

    let pickerType: PHPickerFilter
    @ViewBuilder let content: () -> Content
    let imagePicked: (URL) -> Unit
    var body: some View {

        PhotosPicker(
            selection: $selectedItem,
            matching: pickerType
        ) {
            //ImageAsset(icon: "upload", tint: .white).frame(width: 45, height: 45).padding(5)
            content()
        }.onChange(selectedItem, forChangePhoto(imagePicked))
    }
}

struct DataPicker : View {

    @Inject private var theme: Theme
    
    let isDateTimeError: Bool
    let dataPicked: (Int64) -> ()

    var body: some View {
        VStack {
            DatePicker("Enter Timeline Date", selection: Binding(get: {
                Date.now
            }, set: { it in
                dataPicked(Int64(it.timeIntervalSince1970) * 1000)
            }), displayedComponents: [.date, .hourAndMinute])
            .labelsHidden()
            .frame(maxHeight: 400)
            .foregroundColor(isDateTimeError ? theme.error : theme.textColor
            )
        }.frame(maxHeight: 400).padding(5).background(
            RoundedRectangle(cornerRadius: 5).stroke(isDateTimeError ? theme.error : Color.clear, lineWidth: 1)
        )
    }
}
