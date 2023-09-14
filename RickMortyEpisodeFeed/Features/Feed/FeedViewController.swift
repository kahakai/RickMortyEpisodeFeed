//
//  FeedViewController.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 12/09/2023.
//

import UIKit
import Combine

final class FeedViewController: UIViewController {
    private let feedViewModel: FeedViewModel

    private var cancellables = Set<AnyCancellable>()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        return label
    }()

    init(feedViewModel: FeedViewModel) {
        self.feedViewModel = feedViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(textLabel)

        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        feedViewModel.getEpisodes()
            .sink(receiveValue: { state in
                switch state {
                case .idle:
                    print("idle")
                case .loading:
                    print("loading")
                case .success(let episodes):
                    print("success: \(episodes)")
                case .failure(let error):
                    print("failure: \(error)")
                }
            })
            .store(in: &cancellables)
    }

    private func setupConstraints() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
