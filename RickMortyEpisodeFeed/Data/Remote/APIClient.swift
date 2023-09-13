//
//  APIClient.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Foundation

protocol APIClient {
    var baseURL: URL { get }
    var session: URLSession { get }

    func fetch<T: Decodable>(endpoint: Endpoint) async -> Result<T, Error>
}
