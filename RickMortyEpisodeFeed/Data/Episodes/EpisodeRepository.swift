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
        let managedContext = persistenceController.container.viewContext
        let request = Episode.fetchRequest()

        return persistenceController
            .publisher(context: managedContext, fetch: request)
            .flatMap { episodes in
                return Future<[Episode], NSError> { [self] promise in
                    guard episodes.isEmpty else {
                        return promise(.success(episodes))
                    }

                    Task {
                        let result = await refreshAll()

                        switch result {
                        case .success(let newEpisodes):
                            return promise(.success(newEpisodes))
                        case .failure(let error):
                            return promise(.failure(error as NSError))
                        }
                    }
                }
            }
            .map { (episodesPublisher: [Episode]) in
                episodesPublisher.map { episode in
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

    private func refreshAll() async -> Result<[Episode], Error> {
        let episodesEndpoint = EpisodesEndpoint()
        let episodesResult: Result<EpisodesResponse, Error> =
            await apiClient.fetch(endpoint: episodesEndpoint)

        switch episodesResult {
        case .success(let response):
            return save(episodes: response.results)
        case .failure(let error):
            return .failure(error)
        }
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
