protocol MovieDetailViewModelDelegate: AnyObject {
    func movieDetailDidUpdate()
    func didEncounterError(_ error: Error)
}

final class MovieDetailViewModel {
    
    weak var delegate: MovieDetailViewModelDelegate?
    private(set) var movieDetail: MovieDetail?
    
    func loadMovieDetail(id: Int) async{
        do{
            let detail = try await NetworkManager.shared.fetchMovieDetails(id: id)
            self.movieDetail = detail
            self.delegate?.movieDetailDidUpdate()
        } catch{
            delegate?.didEncounterError(error)
        }
    }
}
