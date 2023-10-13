//
//  EpisodeRepository.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Foundation
import Combine

final class EpisodeRepository: EpisodeRepositoryProtocol {
    private let apiClient: APIClient
    private let persistenceController: PersistenceController

    init(
        apiClient: APIClient,
        persistenceController: PersistenceController
    ) {
        self.apiClient = apiClient
        self.persistenceController = persistenceController
    }

    func fetchAll() -> AnyPublisher<[EpisodeEntity], Error> {
        return fetchAllLocal()
            .flatMap { [self] (episodes: [Episode]) in
                guard episodes.isEmpty else {
                    return Just(episodes)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return fetchAllRemote()
            }
            .map { (newEpisodes: [Episode]) in
                return newEpisodes.map { episode in
                    EpisodeEntity(
                        code: episode.episode!,
                        name: episode.name!,
                        date: episode.date!
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    private func fetchAllLocal() -> AnyPublisher<[Episode], Error> {
        let managedContext = persistenceController.container.viewContext
        let request = Episode.fetchRequest()

        return persistenceController
            .publisher(context: managedContext, fetch: request)
            .mapError { nserror in
                nserror as Error
            }
            .eraseToAnyPublisher()
    }

    private func fetchAllRemote() -> AnyPublisher<[Episode], Error> {
        return Future<EpisodesResponse, Error> { [self] promise in
            Task {
                let endpoint = EpisodesEndpoint()
                let result: Result<EpisodesResponse, Error> =
                    await apiClient.fetch(endpoint: endpoint)
                
                switch result {
                case .success(let response):
                    return promise(.success(response))
                case .failure(let error):
                    return promise(.failure(error))
                }
            }
        }
        .asyncMap { [self] response in
            let remoteEpisodes = response.results
            return try await save(episodes: remoteEpisodes)
        }
        .eraseToAnyPublisher()
    }

    private func save(episodes: [RemoteEpisode]) async throws -> [Episode] {
        let managedContext = persistenceController.container.viewContext

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"

        let iso8601DateFormatter = ISO8601DateFormatter()

        let localEpisodes = episodes.map { remoteEpisode in
            let episode = Episode(context: managedContext)
            episode.id = Int64(remoteEpisode.id)
            episode.name = remoteEpisode.name
            episode.date = dateFormatter.date(from: remoteEpisode.airDate)
                ?? iso8601DateFormatter.date(from: remoteEpisode.created)!
            episode.episode = remoteEpisode.episode
            return episode
        }

        try managedContext.save()
        
        return localEpisodes
    }
}
