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

    private var cancellables = Set<AnyCancellable>()

    init(
        apiClient: APIClient,
        persistenceController: PersistenceController
    ) {
        self.apiClient = apiClient
        self.persistenceController = persistenceController
    }

    func fetchAll() -> AnyPublisher<[EpisodeEntity], Error> {
        return fetchAllLocal()
            .flatMap { [self] episodes in
                guard episodes.isEmpty else {
                    return Just(episodes)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return fetchAllRemote()
            }
            .eraseToAnyPublisher()
    }

    private func fetchAllLocal() -> AnyPublisher<[EpisodeEntity], Error> {
        let managedContext = persistenceController.container.viewContext
        let request = Episode.fetchRequest()

        return persistenceController
            .publisher(context: managedContext, fetch: request)
            .map { episodes in
                episodes.map { episode in
                    EpisodeEntity(
                        code: episode.episode!,
                        name: episode.name!,
                        date: episode.date!
                    )
                }
            }
            .mapError { nserror in
                nserror as Error
            }
            .eraseToAnyPublisher()
    }

    private func fetchAllRemote() -> AnyPublisher<[EpisodeEntity], Error> {
        return Future<[EpisodeEntity], Error> { [self] promise in
            Task {
                let endpoint = EpisodesEndpoint()
                let result: Result<EpisodesResponse, Error> =
                    await apiClient.fetch(endpoint: endpoint)
                
                switch result {
                case .success(let response):
                    let saveResult = save(episodes: response.results)

                    switch saveResult {
                    case .success(let localEpisodes):
                        let episodeEntities = localEpisodes.map { episode in
                            EpisodeEntity(
                                code: episode.episode!,
                                name: episode.name!,
                                date: episode.date!
                            )
                        }

                        return promise(.success(episodeEntities))
                    case .failure(let error):
                        return promise(.failure(error))
                    }
                case .failure(let error):
                    return promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func save(episodes: [RemoteEpisode]) -> Result<[Episode], Error> {
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

        do {
            try managedContext.save()
            return .success(localEpisodes)
        } catch {
            return .failure(error)
        }
    }
}
