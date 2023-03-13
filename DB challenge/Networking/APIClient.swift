//
//  APIClient.swift
//  DB challenge
//
//  Created by Zofia Drabek on 12.03.23.
//

import Foundation

protocol APIClientProtocol {
    func fetch<T: APIRequest>(
        request: T,
        completion: @escaping (Result<T.Response, Error>) -> Void
    )
}

struct APIClient: APIClientProtocol {
    let baseURL: URL
    let decoder: JSONDecoder

    func fetch<T: APIRequest>(
        request: T,
        completion: @escaping (Result<T.Response, Error>) -> Void
    ) {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        components.path = request.endpoint
        components.queryItems = request.parameters.map(URLQueryItem.init)

        guard let url = components.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.allHTTPHeaderFields = request.headers

        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            if let response = response as? HTTPURLResponse,
               (response.statusCode >= 200 && response.statusCode < 300)
            {
                if let decodedResponse = try? decoder.decode(T.Response.self, from: data) {
                    completion(.success(decodedResponse))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            } else {
                completion(.failure(URLError(.badServerResponse)))
            }
        }
        task.resume()
    }
}
