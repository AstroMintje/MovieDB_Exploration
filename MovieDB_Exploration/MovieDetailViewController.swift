import UIKit

final class MovieDetailViewController: UIViewController {
    
    private let movie: Movie
    private let viewModel = MovieDetailViewModel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let posterImageView = UIImageView()
    private let infoStackView = UIStackView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let additionalInfoLabel = UILabel()
    private let overviewLabel = UILabel()
    private let castScrollView = UIScrollView()
    private let castStackView = UIStackView()
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = movie.title
        
        viewModel.delegate = self
        
        setupLayout()
        configureContent()
        loadPosterImage()
        
        Task{
            print("Task started, about to fetch detail")
            await viewModel.loadMovieDetail(id: movie.id)
            print("Task finished calling loadMovieDetail")
        }
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(posterImageView)
        contentView.addSubview(infoStackView)
        
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.clipsToBounds = true
        posterImageView.backgroundColor = .black
        
        infoStackView.axis = .vertical
        infoStackView.spacing = 8
        infoStackView.isLayoutMarginsRelativeArrangement = true
        infoStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        titleLabel.font = .boldSystemFont(ofSize: 25)
        titleLabel.numberOfLines = 0
        
        metaLabel.font = .systemFont(ofSize: 14)
        metaLabel.textColor = .secondaryLabel
        metaLabel.numberOfLines = 0
        
        additionalInfoLabel.font = .systemFont(ofSize: 12)
        additionalInfoLabel.textColor = .tertiaryLabel
        additionalInfoLabel.numberOfLines = 0
        
        overviewLabel.font = .systemFont(ofSize: 14)
        overviewLabel.numberOfLines = 0
        
        castStackView.axis = .horizontal
        castStackView.spacing = 6
        
        castScrollView.showsHorizontalScrollIndicator = false
        castScrollView.addSubview(castStackView)
        
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(metaLabel)
        infoStackView.addArrangedSubview(additionalInfoLabel)
        infoStackView.addArrangedSubview(overviewLabel)
        infoStackView.addArrangedSubview(castScrollView)
        
        [scrollView, contentView, posterImageView, infoStackView, castStackView, castScrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let infoStackBottomConstraint = infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        infoStackBottomConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            posterImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 400),
            
            infoStackView.topAnchor.constraint(equalTo: posterImageView.bottomAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            castStackView.leadingAnchor.constraint(equalTo: castScrollView.leadingAnchor),
            castStackView.trailingAnchor.constraint(equalTo: castScrollView.trailingAnchor),
            castStackView.topAnchor.constraint(equalTo: castScrollView.topAnchor),
            castStackView.bottomAnchor.constraint(equalTo: castScrollView.bottomAnchor),
            castStackView.heightAnchor.constraint(equalTo: castScrollView.heightAnchor),
            castScrollView.heightAnchor.constraint(equalToConstant: 36),
            
            infoStackBottomConstraint
            
        ])
    }
    private func configureContent() {
        titleLabel.text = movie.title
        let rating = String(format: "%.1f", movie.voteAverage)
        metaLabel.text = "\(movie.releaseDate)\n⭐️ \(rating)/10"
        overviewLabel.text = movie.overview
    }
    
    private func loadPosterImage() {
        guard let posterPath = movie.posterPath else { return }
        let urlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
        
        Task{
            let image = await ImageLoader.shared.loadImage(from: urlString)
            posterImageView.image = image
        }
    }
    private func makeCastChip(name: String) -> UIView {
        let label = UILabel()
        label.text = name
        label.font = .systemFont(ofSize:13)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])
        
    return container
    }
}

extension MovieDetailViewController: MovieDetailViewModelDelegate {
    func movieDetailDidUpdate() {
        guard let detail = viewModel.movieDetail else { return }
        
        let genreNames = detail.genres.map { $0.name }.joined(separator: ", ")
        let runtimeText = detail.runtime.map { "\($0) min" } ?? "N/A"
        additionalInfoLabel.text = "\(runtimeText) • \(genreNames)"
        
        if let cast = detail.credits?.cast{
            castStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for member in cast.prefix(10) {
                let chip = makeCastChip(name: member.name)
                castStackView.addArrangedSubview(chip)
            }
        }
    }
    func didEncounterError(_ error: Error) {
        print("Failed to load movie details: \(error)")
    }
}
