import Foundation

protocol MovieDetailViewModelDelegate: AnyObject {
    func movieDetailDidUpdate()
    func didEncounterError(_ error: Error)
}

final class MovieDetailViewModel {
    
    weak var delegate: MovieDetailViewModelDelegate?
    private(set) var movieDetail: MovieDetail?
    
        func loadMovieDetail(id: Int) async{
            if let cached = MovieDetailCache.shared.get(id: id) {
                self.movieDetail = cached
                delegate?.movieDetailDidUpdate()
                return
            }
        do{
            let detail = try await NetworkManager.shared.fetchMovieDetails(id: id)
            MovieDetailCache.shared.set(id: id, detail: detail)
            self.movieDetail = detail
            delegate?.movieDetailDidUpdate()
        } catch{
            delegate?.didEncounterError(error)
        }
    }
}
