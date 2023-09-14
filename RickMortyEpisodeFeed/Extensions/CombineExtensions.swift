//
//  CombineExtensions.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 14/09/2023.
//

import Combine

extension Publisher {
    func asResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        self
            .map(Result.success)
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
}
