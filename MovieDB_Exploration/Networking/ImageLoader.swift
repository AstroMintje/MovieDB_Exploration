import UIKit

final class ImageLoader {
    
    static let shared = ImageLoader()
    private init() {}
    
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String) async -> UIImage? {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            cache.setObject(image, forKey: urlString as NSString)
            return image
        } catch {
            return nil
        }
    }
}
