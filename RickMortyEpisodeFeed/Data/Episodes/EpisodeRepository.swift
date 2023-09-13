//
//  EpisodeRepository.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Foundation
import CoreData

final class EpisodeRepository {
    private let apiClient: APIClient
    private let persistentContainer: NSPersistentContainer

    init(
        apiClient: APIClient,
        persistentContainer: NSPersistentContainer
    ) {
        self.apiClient = apiClient
        self.persistentContainer = persistentContainer
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
        let managedContext = persistentContainer.viewContext

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
