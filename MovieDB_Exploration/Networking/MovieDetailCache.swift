import Foundation

final class MovieDetailCache{
    static let shared = MovieDetailCache()
    private init(){}
    
    private var cache: [Int: MovieDetail] = [:]
    
    func get(id: Int) -> MovieDetail? {
        return cache[id]
    }
    
    func set(id: Int, detail: MovieDetail) {
        cache[id] = detail
    }
    
}
