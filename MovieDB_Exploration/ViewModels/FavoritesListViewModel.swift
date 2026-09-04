protocol FavoritesListViewModelDelegate: AnyObject {
    func favoritesDidUpdate()
}

final class FavoritesListViewModel {
    weak var delegate: FavoritesListViewModelDelegate?
    private(set) var favorites: [Movie] = []
    
    func loadFavorites() {
        favorites = FavoritesManager.shared.getAllFavorites()
        delegate?.favoritesDidUpdate()
    }
}
