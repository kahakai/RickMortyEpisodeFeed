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
            .map { episodesPublisher in
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

    func refreshEpisodes() async -> Result<Void, Error> {
        let endpoint = EpisodesEndpoint()
        let result: Result<EpisodesResponse, Error> = await apiClient.fetch(endpoint: endpoint)

        switch result {
        case .success(let response):
            return saveEpisodes(response.results)
        case .failure(let error):
            return .failure(error)
        }
    }

    private func saveEpisodes(_ episodes: [RemoteEpisode]) -> Result<Void, Error> {
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
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
