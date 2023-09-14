//
//  EpisodesTableViewDataSource.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 14/09/2023.
//

import UIKit

final class EpisodesTableViewDataSource: NSObject {
    private var data = [EpisodeEntity]()

    func update(with episodes: [EpisodeEntity]) {
        data = episodes
    }
}

extension EpisodesTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EpisodeCell.reuseIdentifier,
            for: indexPath
        ) as? EpisodeCell else {
            return EpisodeCell()
        }

        let episode = data[indexPath.row]
        cell.configure(with: episode)

        return cell
    }
}
