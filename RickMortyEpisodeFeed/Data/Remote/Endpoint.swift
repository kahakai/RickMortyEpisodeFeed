//
//  Endpoint.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Foundation

enum HTTPMethod {
    case get
    case post
}

protocol Endpoint {
    var path: String { get }
    var httpMethod: HTTPMethod { get }

    func request(with baseURL: URL) -> URLRequest
}
