import UIKit

final class HomeViewController: UIViewController {
    
    private let listMovie = UITableView()
    private let viewModel = HomeViewModel()
    private let wholeArea = UIView()
    private let scrollView = UIScrollView()
    private let refreshControl = UIRefreshControl()
    
    private var listMovieHeightConstraint: NSLayoutConstraint!
    private var collectionView: UICollectionView!
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Movies"
        
        viewModel.delegate = self
        setupCollectionView()
        
        Task{
            await viewModel.loadSections()
        }
    }
    
    @objc private func handleRefresh()  {
        Task {
            await viewModel.loadSections()
            refreshControl.endRefreshing()
        }
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(wholeArea)
        
    }
    
    private func setupCollectionView() {
        view.addSubview(scrollView)
        scrollView.addSubview(wholeArea)
        
        let layout = createCarouselOnlyLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        
        listMovie.isScrollEnabled = false
        listMovie.rowHeight = UITableView.automaticDimension
        listMovie.estimatedRowHeight = 100
        listMovie.dataSource = self
        listMovie.delegate = self
        listMovie.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        listMovie.isScrollEnabled = false
        
        wholeArea.addSubview(collectionView)
        wholeArea.addSubview(listMovie)
     
        [scrollView, wholeArea, collectionView, listMovie] .forEach{ $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 1)
        listMovieHeightConstraint = listMovie.heightAnchor.constraint(equalToConstant: 1)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            wholeArea.topAnchor.constraint(equalTo: scrollView.topAnchor),
            wholeArea.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            wholeArea.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            wholeArea.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            wholeArea.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            collectionView.topAnchor.constraint(equalTo: wholeArea.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: wholeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: wholeArea.trailingAnchor),
            collectionViewHeightConstraint,
            
            listMovie.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            listMovie.leadingAnchor.constraint(equalTo: wholeArea.leadingAnchor),
            listMovie.trailingAnchor.constraint(equalTo: wholeArea.trailingAnchor),
            listMovie.bottomAnchor.constraint(equalTo: wholeArea.bottomAnchor),
            listMovieHeightConstraint
        ])
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    private func createCarouselOnlyLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            self.createCarouselSection()
        }
    }
        
    private func createCarouselSection() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(120),
            heightDimension: .absolute(220)
            )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(120),
            heightDimension: .absolute(220)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
            
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func sectionsDidUpdate() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        listMovie.reloadData()
        listMovie.layoutIfNeeded()
        
        collectionViewHeightConstraint.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        listMovieHeightConstraint.constant = listMovie.contentSize.height
    }
    func didEncounterError(_ error: any Error) {
        print("Failed to load home sections: \(error)")
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
    }
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        if section < 3{
            return viewModel.sections[section].movies.count
        } else {
            return viewModel.browseMovies.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section < 3 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            let movie = viewModel.sections[indexPath.section].movies[indexPath.item]
            cell.configure(with: movie)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieListCollectionViewCell else {
                return UICollectionViewCell()
            }
            let movie = viewModel.browseMovies[indexPath.item]
            cell.configure(with: movie)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        header.configure(title: viewModel.sections[indexPath.section].title)
        return header
    }
}
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = indexPath.section < 3
        ? viewModel.sections[indexPath.section].movies[indexPath.item]
        : viewModel.browseMovies[indexPath.item]
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard indexPath.section == 3 else { return }
        viewModel.loadMoreBrowseMoviesIfNeeded(currentRow: indexPath.item)
    }
}
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.browseMovies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.browseMovies[indexPath.row])
        return cell
    }
}
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = viewModel.browseMovies[indexPath.row]
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("willDisplay row \(indexPath.row) of \(viewModel.browseMovies.count)")
        viewModel.loadMoreBrowseMoviesIfNeeded(currentRow: indexPath.row)
        
        if indexPath.row == viewModel.browseMovies.count - 1 {
            listMovieHeightConstraint.constant = listMovie.contentSize.height
        }
    }
}
