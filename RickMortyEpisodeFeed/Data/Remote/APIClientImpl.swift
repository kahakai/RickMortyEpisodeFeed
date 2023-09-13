//
//  APIClientImpl.swift
//  RickMortyEpisodeFeed
//
//  Created by Artyom Nesterenko on 13/09/2023.
//

import Foundation

class APIClientImpl: APIClient {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetch<T: Decodable>(endpoint: Endpoint) async -> Result<T, Error> {
        guard let url = endpoint.makeURL(with: baseURL) else {
            return .failure(APIError.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return .failure(APIError.invalidResponse)
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return .success(decodedData)
            } catch {
                return .failure(APIError.decodingError)
            }
        } catch(let error) {
            return .failure(error)
        }
    }
}
