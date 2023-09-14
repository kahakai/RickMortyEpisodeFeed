//
//  EpisodeRepository.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Foundation

final class EpisodeRepository {
    private let apiClient: APIClient
    private let persistenceController: PersistenceController

    init(
        apiClient: APIClient,
        persistenceController: PersistenceController
    ) {
        self.apiClient = apiClient
        self.persistenceController = persistenceController
    }

    func refreshEpisodes() async -> Result<Void, Error> {
        let endpoint = EpisodesEndpoint()
        let result: Result<EpisodesResponse, Error> = await apiClient.fetch(endpoint: endpoint)

        switch result {
        case .success(let response):
            saveEpisodes(response.results)
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    private func saveEpisodes(_ episodes: [RemoteEpisode]) {
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

        try? managedContext.save()
    }
}
