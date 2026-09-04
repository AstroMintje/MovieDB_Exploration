import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://api.themoviedb.org/3"
    
    private func performRequest<T: Decodable>(url:URL) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Secrets.tmdbAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data,response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).self ~= httpResponse.statusCode
        else {
            throw NetworkError.invalidResponse
        }
        do{
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
    
    func fetchPopularMovies(page: Int = 1) async throws -> MovieResponse {
        guard let url = URL(string: "\(baseURL)/movie/popular?language=en-US&page=\(page)")
        else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    func searchMovies(query: String) async throws -> MovieResponse {
        guard var components = URLComponents(string: "\(baseURL)/search/movie") else{
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Secrets.tmdbAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        do {
            return try JSONDecoder().decode(MovieResponse.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
    
    func fetchTopRatedMovies (page: Int = 1) async throws -> MovieResponse {
        guard let url = URL(string: "\(baseURL)/movie/top_rated?language=en-US&page=\(page)") else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    func fetchNowPlayingMovies (page: Int = 1) async throws -> MovieResponse {
        guard let url = URL(string: "\(baseURL)/movie/now_playing?language=en-US&page=\(page)") else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    func fetchMovieDetails(id: Int) async throws -> MovieDetail {
        guard var components = URLComponents(string: "\(baseURL)/movie/\(id)") else{
            throw NetworkError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "append_to_response", value: "credits")
        ]
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
}
