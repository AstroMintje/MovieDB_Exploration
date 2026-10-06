import UIKit

final class MovieListCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "MovieListCollectionViewCell"

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private var imageLoadTask: Task<Void, Never>?

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
        titleLabel.text = nil
        dateLabel.text = nil
    }

    private func setupViews() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        posterImageView.backgroundColor = .secondarySystemBackground

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2

        dateLabel.font = .preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = .secondaryLabel

        [posterImageView, titleLabel, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.widthAnchor.constraint(equalToConstant: 60),
            posterImageView.heightAnchor.constraint(equalToConstant: 90),

            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        dateLabel.text = movie.releaseDate
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "Movie title:\(movie.title)"

        guard let posterPath = movie.posterPath else { return }
        let urlString = "https://image.tmdb.org/t/p/w200\(posterPath)"

        imageLoadTask = Task {
            let image = await ImageLoader.shared.loadImage(from: urlString)
            guard !Task.isCancelled else { return }
            posterImageView.image = image ?? UIImage(systemName: "photo")
        }
    }
}
