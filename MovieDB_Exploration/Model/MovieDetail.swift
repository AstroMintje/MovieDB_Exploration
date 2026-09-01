struct Genre: Codable {
    let id: Int
    let name: String
}

struct CastMember: Codable {
    let id: Int
    let name: String
    let character: String
}

struct Credits: Codable {
    let cast: [CastMember]
}

struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String?
    let voteAverage: Double
    let runtime: Int?
    let genres: [Genre]
    let credits: Credits?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, credits
        case releaseDate = "release_date"
        case posterPath = "poster_path" 
        case voteAverage = "vote_average"
    }
}

