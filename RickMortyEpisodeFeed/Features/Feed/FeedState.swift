//
//  FeedState.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 14/09/2023.
//

import Combine

typealias FeedViewModelOutput = AnyPublisher<FeedState, Never>

enum FeedState {
    case idle
    case loading
    case success([EpisodeEntity])
    case failure(Error)
}
