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
    }

    private func setupConstraints() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
