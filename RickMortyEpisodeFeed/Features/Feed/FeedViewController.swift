//
//  FeedViewController.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 12/09/2023.
//

import UIKit
import Combine

final class FeedViewController: UIViewController {
    private let viewModel: FeedViewModel

    private var cancellables = Set<AnyCancellable>()

    private let tableViewDataSource = EpisodesTableViewDataSource()
    private let tableViewDelegate = EpisodesTableViewDelegate()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = tableViewDataSource
        table.delegate = tableViewDelegate
        table.register(
            EpisodeCell.self,
            forCellReuseIdentifier: EpisodeCell.reuseIdentifier
        )
        table.rowHeight = 96
        return table
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No Rick & Morty episodes!"
        label.isHidden = true
        return label
    }()

    init(feedViewModel: FeedViewModel) {
        self.viewModel = feedViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bind(to: viewModel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = view.bounds
    }

    private func setupConstraints() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bind(to viewModel: FeedViewModel) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()

        viewModel.getEpisodes()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] state in
                render(state)
            })
            .store(in: &cancellables)
    }

    private func render(_ state: FeedState) {
        switch state {
        case .idle:
            debugPrint("render state idle")
        case .loading:
            debugPrint("render state loading")
        case .success(let episodes):
            debugPrint("render state success: \(episodes)")
            tableViewDataSource.update(with: episodes)
            tableView.reloadData()
        case .failure(let error):
            debugPrint("render state failure: \(error)")
        }
    }
}
