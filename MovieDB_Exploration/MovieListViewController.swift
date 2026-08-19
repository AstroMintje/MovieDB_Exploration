//
//  ViewController.swift
//  MovieDB_Exploration
//
//  Created by Michael Mintje on 04/08/26.
//

import UIKit

class MovieListViewController: UIViewController {
    
    private var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Popular Movies"
        
        Task {
            await loadMovies()
        }
    }
    private func loadMovies() async {
        do {
            let fetchedMovies = try await NetworkManager.shared.fetchPopularMovies()
            self.movies = fetchedMovies
            print("Berhasil dapat \(fetchedMovies.count) film")
            print(fetchedMovies.first?.title ?? "kosong")
        } catch {
            print("Gagal fetch Movies: \(error)")
        }
    }
}

