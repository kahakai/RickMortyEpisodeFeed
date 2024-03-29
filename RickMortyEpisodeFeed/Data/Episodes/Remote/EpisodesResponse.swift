//
//  EpisodesResponse.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Foundation

// MARK: - EpisodesResponse
struct EpisodesResponse: Codable {
    let info: Info
    let results: [RemoteEpisode]
}

// MARK: - Info
struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String
    let prev: String?
}

// MARK: - Episode
struct RemoteEpisode: Codable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case airDate = "air_date"
        case episode
        case characters
        case url
        case created
    }
}
