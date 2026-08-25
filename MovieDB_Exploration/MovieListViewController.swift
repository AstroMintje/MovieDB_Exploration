import UIKit

class MovieListViewController: UIViewController {
    
    private var movies: [Movie] = []
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
   
    private var currentPage = 1
    private var totalPages = 1
    private var isLoadingMoreMovies = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Popular Movies"
        
        setupTableView()
        
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
}



extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie = movies[indexPath.row]
        
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

