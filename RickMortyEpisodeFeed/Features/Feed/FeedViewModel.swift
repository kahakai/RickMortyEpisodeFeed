//
//  FeedViewModel.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Combine

final class FeedViewModel {
    private let episodeRepository: EpisodeRepositoryProtocol

    init(episodeRepository: EpisodeRepositoryProtocol) {
        self.episodeRepository = episodeRepository
    }

    func getEpisodes() -> FeedViewModelOutput {
        return episodeRepository.fetchAll()
            .asResult()
            .map { result -> FeedState in
                switch result {
                case .success(let episodes):
                    return FeedState.success(episodes)
                case .failure(let error):
                    return FeedState.failure(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
