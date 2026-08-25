import UIKit

class MovieListViewController: UIViewController {
    
    private var movies: [Movie] = []
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Popular Movies"
        
        setupTableView()
        
        Task {
            await loadMovies()
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCell")
    }
    
    private func loadMovies() async {
        do {
            let fetchedMovies = try await NetworkManager.shared.fetchPopularMovies()
            self.movies = fetchedMovies
            tableView.reloadData()
            print("Berhasil dapat \(fetchedMovies.count) film")
            print(fetchedMovies.first?.title ?? "kosong")
        } catch {
            print("Gagal fetch Movies: \(error)")
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
}
