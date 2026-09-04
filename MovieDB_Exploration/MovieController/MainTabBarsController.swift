import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
    }
    
    private func setupTabs() {
        
        let popularNav = UINavigationController(rootViewController: MovieListViewController())
        let popularTab = UITab(title: "Popular", image: UIImage(systemName: "film"), identifier: "popular") { _ in popularNav
        }
        
        let favoritesNav = UINavigationController(rootViewController: FavoritesListViewController())
        let favoritesTab = UITab(title: "Favorites", image: UIImage(systemName: "heart"), identifier: "favorites") { _ in favoritesNav
        }
        
        let searchTab = UISearchTab { _ in
            UINavigationController(rootViewController: SearchViewController())
        }
        
        self.tabs = [popularTab, favoritesTab, searchTab]
    }
}


