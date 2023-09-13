//
//  EpisodesEndpoint.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Foundation

struct EpisodesEndpoint: Endpoint {
    let path: String = "/episode"
    let httpMethod: HTTPMethod = .get

    func makeURL(with baseURL: URL) -> URL? {
        guard var components = URLComponents(string: baseURL.absoluteString) else {
            return nil
        }

        components.path += path

        return components.url
    }
}
