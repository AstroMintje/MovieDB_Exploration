import UIKit

class MovieListViewController: UIViewController {
    
    private var movies: [Movie] = []
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    private let viewModel = MovieListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Popular Movies"
    
        viewModel.delegate = self
        
        setupTableView()
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search movies"
        
        Task {
            await viewModel.loadInitialMovies()
        }
    }
    
    @objc private func handleRefresh()  {
        Task {
            await viewModel.loadInitialMovies()
            refreshControl.endRefreshing()
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.dataSource = self
        tableView.delegate = self
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCell")
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}

extension MovieListViewController: MovieListViewModelDelegate {
    
    func moviesDidUpdate() {
        tableView.reloadData()
    }
    func searchResultsDidUpdate() {
        tableView.reloadData()
    }
    func didEncounterError(_ error: any Error) {
        print("Something Went Wrong: \(error)")
    }
}

extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.currentItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie =  viewModel.currentItems[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = movie.title
        content.secondaryText = movie.releaseDate
        content.image = UIImage(systemName: "photo")
        content.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 90)
        content.imageProperties.maximumSize = CGSize(width: 60, height: 90)
        content.imageProperties.cornerRadius = 22
        cell.contentConfiguration = content
        
        cell.tag = indexPath.row
        
        if let posterPath = movie.posterPath {
            let urlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
            
            Task {
                let image = await ImageLoader.shared.loadImage(from: urlString)
                guard cell.tag == indexPath.row else { return }
                
                var updatedContent = cell.defaultContentConfiguration()
                updatedContent.text = movie.title
                updatedContent.secondaryText = movie.releaseDate
                updatedContent.image = image ?? UIImage(systemName: "photo")
                updatedContent.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 90)
                updatedContent.imageProperties.maximumSize = CGSize(width: 60, height: 90)
                updatedContent.imageProperties.cornerRadius = 22
                cell.contentConfiguration = updatedContent
            }
        }
        return cell
    }
}

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedMovie = viewModel.currentItems[indexPath.row]
        print("Tapped: \(selectedMovie.title)")
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadMoreMoviesIfNeeded(currentRow: indexPath.row)
        }
    }

extension MovieListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.search(query: query)
    }
}
