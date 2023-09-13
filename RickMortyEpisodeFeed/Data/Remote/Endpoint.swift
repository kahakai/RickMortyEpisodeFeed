//
//  Endpoint.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol Endpoint {
    var path: String { get }
    var httpMethod: HTTPMethod { get }

    func makeURL(with baseURL: URL) -> URL?
}
