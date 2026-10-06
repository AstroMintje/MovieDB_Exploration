import UIKit

final class MovieCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MovieCollectionViewCell"
    
    private let posterImageView = UIImageView()
    private var imageLoadTask: Task<Void,Never>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        posterImageView.image = UIImage(systemName: "photo")
        
    }
        private func setupViews() {
            posterImageView.contentMode = .scaleAspectFill
            posterImageView.clipsToBounds = true
            posterImageView.layer.cornerRadius = 6
            posterImageView.backgroundColor = .secondarySystemBackground
            posterImageView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(posterImageView)
            NSLayoutConstraint.activate([
                posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        }
        func configure(with movie: Movie) {
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = "Movie title:\(movie.title)"
            
            guard let posterPath = movie.posterPath else {
                return
            }
            let urlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
            
            imageLoadTask = Task {
                let image = await ImageLoader.shared.loadImage(from: urlString)
                guard !Task.isCancelled else { return }
                posterImageView.image = image ?? UIImage(systemName: "photo")
            }
        }
    }
