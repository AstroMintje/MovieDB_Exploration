import UIKit

final class MovieTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "MovieTableViewCell"
    
    private let posterContainerView = UIView()
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
        
    private var imageLoadTask: Task<Void, Never>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterContainerView.layer.shadowPath = UIBezierPath(roundedRect: posterContainerView.bounds, cornerRadius: 22).cgPath
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
        posterImageView.backgroundColor = .secondarySystemBackground
        posterImageView.layer.cornerRadius = 22
        posterImageView.layer.shadowColor = UIColor.black.cgColor
        posterImageView.layer.shadowRadius = 4
        posterImageView.layer.shadowOpacity = 0.15
        posterImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 4
        
        dateLabel.font = .preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = .secondaryLabel
        
        [posterImageView, titleLabel, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
//            posterImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            posterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            posterImageView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
        ])
            }
    func configure(with movie: Movie){
        titleLabel.text = movie.title
       dateLabel.text = movie.releaseDate
        
        guard let posterPath = movie.posterPath else { return }
        let urlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
        imageLoadTask = Task {
            let image = await ImageLoader.shared.loadImage(from: urlString)
            guard !Task.isCancelled else { return }
            posterImageView.image = image ?? UIImage(systemName: "photo")
        }
    }
}
  



