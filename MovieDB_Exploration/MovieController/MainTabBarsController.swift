import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
    }
    
    private func setupTabs() {
        
        let popularNav = UINavigationController(rootViewController: HomeViewController())
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

//class MyViewController: UIViewController {
//    let abcdeView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .green
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 20
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    let myView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .red
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        return view
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(abcdeView)
//        abcdeView.addSubview(myView)
//        view.backgroundColor = .white
//        
//        abcdeView.frame = .init(x: 100, y: 100, width: 100, height: 100)
//        myView.frame = .init(x: abcdeView.bounds.minX, y: abcdeView.bounds.minY, width: 50, height: 50)
//        print("frame", abcdeView.frame, myView.frame)
//        print("bounds", abcdeView.bounds, myView.bounds)
//        myView.transform = .init(translationX: -10, y: -10)
//        print("frame", abcdeView.frame, myView.frame)
//        print("bounds", abcdeView.bounds, myView.bounds)
//    }
//}
//

