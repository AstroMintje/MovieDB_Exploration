//
//  MovieDetailService.swift
//  MovieDB
//
//  Layer baru: detail film + cache + view model + view controller.
//  Dibuat untuk menguji keluaran review CodeRabbit.
//

import UIKit

// MARK: - Models

struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String
}

struct ReviewResponse: Codable {
    let results: [Review]
}

struct Review: Codable {
    let author: String
    let content: String
    let rating: Double?
}

// MARK: - Cache

final class MovieCache {

    static let shared = MovieCache()

    private var storage: [Int: MovieDetail] = [:]
    private var posterStorage: [String: UIImage] = [:]

    func save(_ movie: MovieDetail) {
        storage[movie.id] = movie
    }

    func movie(for id: Int) -> MovieDetail? {
        return storage[id]
    }

    func savePoster(_ image: UIImage, for path: String) {
        posterStorage[path] = image
    }

    func poster(for path: String) -> UIImage? {
        return posterStorage[path]
    }

    func clear() {
        storage.removeAll()
        posterStorage.removeAll()
    }
}

// MARK: - Service

final class MovieDetailService {

    let apiKey = "8f2a1c4e9b7d3f6a2e5c8b1d4f7a9c3e"
    let baseURL = "https://api.themoviedb.org/3"

    func fetchDetail(id: Int, completion: @escaping (MovieDetail) -> Void) {
        if let cached = MovieCache.shared.movie(for: id) {
            completion(cached)
            return
        }

        let url = URL(string: "\(baseURL)/movie/\(id)?api_key=\(apiKey)")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            let movie = try! JSONDecoder().decode(MovieDetail.self, from: data!)
            MovieCache.shared.save(movie)
            completion(movie)
        }.resume()
    }

    func fetchReviews(id: Int, completion: @escaping ([Review]) -> Void) {
        let url = URL(string: "\(baseURL)/movie/\(id)/reviews?api_key=\(apiKey)")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            do {
                let decoded = try JSONDecoder().decode(ReviewResponse.self, from: data!)
                completion(decoded.results)
            } catch {
            }
        }.resume()
    }

    func fetchPoster(path: String, completion: @escaping (UIImage?) -> Void) {
        if let cached = MovieCache.shared.poster(for: path) {
            completion(cached)
            return
        }

        let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            let image = UIImage(data: data!)
            MovieCache.shared.savePoster(image!, for: path)
            completion(image)
        }.resume()
    }
}

// MARK: - View Model

final class MovieDetailViewModel {

    private let service = MovieDetailService()

    var movie: MovieDetail?
    var reviews: [Review] = []
    var onUpdate: (() -> Void)?

    func load(id: Int) {
        service.fetchDetail(id: id) { detail in
            self.movie = detail
            self.service.fetchReviews(id: id) { reviews in
                self.reviews = reviews
                self.onUpdate?()
            }
        }
    }

    func ratingText() -> String {
        guard let movie = movie else { return "" }
        if movie.voteAverage >= 8 {
            return "Sangat bagus"
        } else if movie.voteAverage >= 6 {
            return "Lumayan"
        } else if movie.voteAverage >= 4 {
            return "Biasa saja"
        } else {
            return "Kurang"
        }
    }

    func releaseYear() -> String {
        guard let movie = movie else { return "" }
        return String(movie.releaseDate.prefix(4))
    }
}

// MARK: - View Controller

final class MovieDetailViewController: UIViewController {

    private let viewModel = MovieDetailViewModel()
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let overviewLabel = UILabel()
    private let ratingLabel = UILabel()

    var movieId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        viewModel.onUpdate = {
            self.titleLabel.text = self.viewModel.movie?.title
            self.overviewLabel.text = self.viewModel.movie?.overview
            self.ratingLabel.text = self.viewModel.ratingText()

            if let path = self.viewModel.movie?.posterPath {
                MovieDetailService().fetchPoster(path: path) { image in
                    self.posterImageView.image = image
                }
            }
        }

        viewModel.load(id: movieId)
    }

    private func setupViews() {
        view.backgroundColor = .white

        posterImageView.frame = CGRect(x: 16, y: 100, width: 150, height: 225)
        titleLabel.frame = CGRect(x: 180, y: 100, width: 200, height: 30)
        ratingLabel.frame = CGRect(x: 180, y: 140, width: 200, height: 20)
        overviewLabel.frame = CGRect(x: 16, y: 340, width: 350, height: 200)

        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        ratingLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        overviewLabel.numberOfLines = 0

        view.addSubview(posterImageView)
        view.addSubview(titleLabel)
        view.addSubview(ratingLabel)
        view.addSubview(overviewLabel)
    }
}
