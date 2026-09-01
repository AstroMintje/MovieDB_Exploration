import UIKit

protocol MovieListViewModelDelegate: AnyObject {
    func moviesDidUpdate()
    func searchResultsDidUpdate()
    func didEncounterError(_ error: Error)
}

//class Something {
//    let movieListVM = MovieListViewModel()
//    
//    func asdasdkmal() {
//        print(movieListVM.movies)
//        movieListVM.movies.removeAll()
//    }
//}
 
final class MovieListViewModel {
    
    weak var delegate: MovieListViewModelDelegate?
    
    private(set) var movies: [Movie] = []
    private(set) var searchResults: [Movie] = []
    private(set) var isSearching = false
    
    var currentItems: [Movie] {
        isSearching ? searchResults : movies
    }
    private var currentPage = 1
    private var totalPages = 1
    private var isLoadingMoreMovies = false
    private var searchTask: Task<Void, Never>?
    
    func loadInitialMovies() async {
        do{
            let response = try await NetworkManager.shared.fetchPopularMovies()
            self.movies = response.results
            self.totalPages = response.totalPages
            print("ViewModel: got \(movies.count) movies, calling delegate")
            delegate?.moviesDidUpdate()
        }catch {
            print("ViewModel: error - \(error)")
            delegate?.didEncounterError(error)
        }
    }
    
    func loadMoreMoviesIfNeeded(currentRow: Int) {
        guard currentRow >= movies.count - 5 else { return }
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
                delegate?.moviesDidUpdate()
            } catch {
                delegate?.didEncounterError(error)
            }
            isLoadingMoreMovies = false
        }
    }
    func search (query: String) {
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            isSearching = false
            delegate?.searchResultsDidUpdate()
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(query: query)
        }
    }
    
    func performSearch(query: String) async {
        do {
            let response = try await NetworkManager.shared.searchMovies(query: query)
            self.searchResults = response.results
            self.isSearching = true
            delegate?.searchResultsDidUpdate()
        } catch {
            if !Task.isCancelled {
                print("Search failed: \(error)")
            }
        }
    }
    
}

