//
//  EpisodeRepositoryProtocol.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 14/09/2023.
//

import Combine

protocol EpisodeRepositoryProtocol {
    func fetchAll() -> AnyPublisher<[EpisodeEntity], Error>
}
