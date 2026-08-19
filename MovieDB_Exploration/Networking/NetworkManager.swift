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
    
    func fetchPopularMovies() async throws -> [Movie] {
        guard let url = URL(string: "\(baseURL)/movie/popular?language=en-US&page=1")
        else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Secrets.tmdbAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")
         
        let (data,response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
        else {
            throw NetworkError.invalidResponse
        }
        
        do{
            let decode = try JSONDecoder().decode(MovieResponse.self, from: data)
            return decode.results
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
