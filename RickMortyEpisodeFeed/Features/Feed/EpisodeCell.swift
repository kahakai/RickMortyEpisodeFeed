//
//  EpisodeCell.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 14/09/2023.
//

import UIKit

final class EpisodeCell: UITableViewCell {
    static let reuseIdentifier = String(describing: EpisodeCell.self)

    private let codeLabel = UILabel()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }

    func configure(with episode: EpisodeEntity) {
        codeLabel.text = episode.code
        nameLabel.text = episode.name
        dateLabel.text = episode.date.description
    }

    private func setup() {
        contentView.addSubview(codeLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
    }

    private func layout() {
        codeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            codeLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            codeLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
        ])

        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
        ])

        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
}
