protocol HomeViewModelDelegate: AnyObject {
    func sectionsDidUpdate()
    func didEncounterError(_ error: Error)
}

final class HomeViewModel {
    
    weak var delegate: HomeViewModelDelegate?
    private(set) var sections: [MovieSection] = []
    private(set) var browseMovies: [Movie] = []
    
    private var currentPage = 1
    private var totalPage = 1
    private var isLoadingMoreBrowse = false
    
    func loadSections() async {
        do {
            async let popular = NetworkManager.shared.fetchPopularMovies()
            async let topRated = NetworkManager.shared.fetchTopRatedMovies()
            async let nowPlaying = NetworkManager.shared.fetchNowPlayingMovies()
            
            let (popularResponse, topRatedResponse, nowPlayingResponse) = try await (popular, topRated, nowPlaying)
            
            self.sections = [
                MovieSection(title: "Popular", movies: popularResponse.results),
                MovieSection(title: "Top Rated", movies: topRatedResponse.results),
                MovieSection(title: "Now Playing", movies: nowPlayingResponse.results)
            ]
            
            self.browseMovies = nowPlayingResponse.results
            self.totalPage = nowPlayingResponse.totalPages
            
            delegate?.sectionsDidUpdate()
        } catch {
            delegate?.didEncounterError(error)
        }
    }
    func loadMoreBrowseMoviesIfNeeded(currentRow: Int) {
        guard currentRow >= browseMovies.count - 5 else { return }
        guard !isLoadingMoreBrowse else { return }
        guard currentPage < totalPage else { return }
        
        isLoadingMoreBrowse = true
        
        Task {
            do{
                let nextPage = currentPage + 1
                let response = try await NetworkManager.shared.fetchNowPlayingMovies(page: nextPage)
                self.browseMovies.append(contentsOf: response.results)
                self.currentPage = nextPage
                self.totalPage = response.totalPages
                self.delegate?.sectionsDidUpdate()
            } catch {
                delegate?.didEncounterError(error)
            }
            isLoadingMoreBrowse = false
        }
    }
}

