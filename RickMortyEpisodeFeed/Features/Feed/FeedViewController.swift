//
//  FeedViewController.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 12/09/2023.
//

import UIKit

class FeedViewController: UIViewController {
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        return label
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(textLabel)

        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            let url = URL(string: "https://rickandmortyapi.com/api")!
            let apiClient: APIClient = APIClientImpl(baseURL: url)
            let result: Result<Episodes, Error> = await apiClient.fetch(endpoint: EpisodesEndpoint())
            switch result {
                case .success(let feed):
                    // Do something with the fetched feed.
                    print(feed)
                case .failure(let error):
                    // Handle the error.
                    print(error)
                }
        }
    }

    private func setupConstraints() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
