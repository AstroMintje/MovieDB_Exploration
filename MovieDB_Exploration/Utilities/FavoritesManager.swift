import Foundation

final class FavoritesManager {
    
    static let shared = FavoritesManager()
    private init() {}
    
    private let defaults = UserDefaults.standard
    private let key = "favoriteMovies"
    
    private var favorites: [Movie] {
        get {
            guard let data = defaults.data(forKey: key) else{ return [] }
            return (try? JSONDecoder().decode([Movie].self, from: data)) ?? []
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: key)
        }
    }
    func isFavorite(id: Int) -> Bool {
        favorites.contains {$0.id == id}
//        { movie in movie.id == id }
    }
    func toggleFavorite(movie: Movie) {
        if let index = favorites.firstIndex(where: { $0.id == movie.id}) {
            favorites.remove(at: index)
        } else {
            favorites.append(movie)
        }
    }
    func getAllFavorites() -> [Movie] {
        favorites
    }
}
