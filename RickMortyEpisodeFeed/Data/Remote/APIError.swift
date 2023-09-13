//
//  APIError.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}
