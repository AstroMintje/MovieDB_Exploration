import UIKit

class MovieListViewController: UIViewController {
    
    private var movies: [Movie] = []
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
   
    private var currentPage = 1
    private var totalPages = 1
    private var isLoadingMoreMovies = false
    private var searchTask: Task<Void, Never>?
    private var isSearching = false
    private var searchResults: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Popular Movies"
    
        setupTableView()
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "seach movies"
        
        Task {
            await loadMovies()
        }
    }
    
    @objc private func handleRefresh()  {
        Task {
            await loadMovies()
            refreshControl.endRefreshing()
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
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
    
    private func loadMovies() async {
        do {
            let response = try await NetworkManager.shared.fetchPopularMovies()
            self.movies = response.results
            self.totalPages = response.totalPages
            tableView.reloadData()
            print("Berhasil dapat \(response.results.count) film")
        } catch {
            print("Gagal fetch Movies: \(error)")
        }
    }
    @MainActor
    private func loadMoreMoviesIfNeeded() {
        guard !isLoadingMoreMovies else { return }
        guard currentPage < totalPages else { return }
        
        isLoadingMoreMovies = true
        
        Task {
            do {
                let nextPage = currentPage + 1
                let response = try await NetworkManager.shared.fetchPopularMovies(page: nextPage)
                
                self.movies.append(contentsOf: response.results)
                self.currentPage = nextPage
                self.totalPages = response.totalPages
                self.tableView.reloadData()
            } catch {
                print("Failed to Load More Movies: \(error)")
            }
            isLoadingMoreMovies = false
        }
    }
    @MainActor
    private func performSearch(query:String) async {
        do {
            let response = try await NetworkManager.shared.searchMovies(query: query)
            self.searchResults = response.results
            self.isSearching = true
            self.tableView.reloadData()
        } catch {
            if !Task.isCancelled {
                print("Search failed: \(error)")
            }
        }
    }
}

extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchResults.count : movies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie = isSearching ? searchResults[indexPath.row] : movies[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = movie.title
        content.secondaryText = movie.releaseDate
        cell.contentConfiguration = content
        
        return cell
    }
}

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedMovie = movies[indexPath.row]
        print("Tapped: \(selectedMovie.title)")
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isNearBottom = indexPath.row >= movies.count - 5
        
        if isNearBottom {
            loadMoreMoviesIfNeeded()
        }
    }
}

extension MovieListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            isSearching = false
            tableView.reloadData()
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(query: query)
        }
    }
}

