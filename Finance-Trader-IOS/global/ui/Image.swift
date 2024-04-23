import Foundation
import AVFoundation
import SwiftUI
import Combine

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

struct ImageCacheView: View {
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

extension [StockPointData] {
    
    @BackgroundActor
    func gradientCreator(_ stockBoarderWave: StockBoarder) -> Gradient {
        var stops: [Gradient.Stop] = []
        let green = Color.green.opacity(0.5)
        let red = Color.red.opacity(0.5)
        let greenTrans = Color.green.opacity(0.1)
        let redTrans = Color.red.opacity(0.1)
        
        let cutOut: Float64 = Float64(stockBoarderWave.minX)
        let timeline: Float64 = Float64(stockBoarderWave.maxX) - cutOut
        let gapY = stockBoarderWave.maxY - stockBoarderWave.minY
        for i in self.indices {
            let stock = self[i]
            let precent = Float64(round(((Float64(stock.time) - cutOut) / timeline) * 1000) / 1000) // round Fir Make in Format #.000
            let isLosing = stock.status == -1

            guard let preStock = self[safe: i - 1] else {
                stops.append(Gradient.Stop(color: isLosing ? red : green, location: precent))
                continue
            }
            let isPreLosing = preStock.status == -1
            
            if isPreLosing && isLosing {
                stops.append(Gradient.Stop(color: red, location: precent))
            } else if !isPreLosing && !isLosing {
                stops.append(Gradient.Stop(color: green, location: precent))
            } else if isPreLosing && !isLosing {
                let color = ((stock.value - preStock.value) / gapY) > 0.1 ? green : greenTrans
                stops.append(Gradient.Stop(color: redTrans, location: precent - 0.001))
                stops.append(Gradient.Stop(color: color, location: precent))
            } else if !isPreLosing && isLosing {
                let color = ((preStock.value - stock.value) / gapY) > 0.1 ? red : redTrans
                stops.append(Gradient.Stop(color: greenTrans, location: precent - 0.001))
                stops.append(Gradient.Stop(color: color, location: precent))
            }
        }
        return Gradient(stops: stops)
    }
}
