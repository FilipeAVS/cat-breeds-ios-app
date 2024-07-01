//
//  Client.swift
//
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation

@Observable public final class Client {
    public enum ClientError: Error {
        case unexpectedRequest
        case unexpectedResponse
    }

    private let apiHost: String
    private let apiKey: String
    private let urlSession: URLSession

    private let decoder = JSONDecoder()

    public init(apiHost: String, apiKey: String, urlSession: URLSession) {
        self.apiHost = apiHost
        self.apiKey = apiKey
        self.urlSession = urlSession
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func get<T: Decodable>(endpoint: Endpoint) async throws -> T {
        return try await makeRequest(endpoint: endpoint, method: "GET")
    }

    public func post<T: Decodable>(endpoint: Endpoint) async throws -> T {
        return try await makeRequest(endpoint: endpoint, method: "POST")
    }

    public func delete(endpoint: Endpoint) async throws {
        let url = try makeUrl(for: endpoint)
        let request = makeUrlRequest(url: url, endpoint: endpoint, httpMethod: "DELETE")
        _ = try await urlSession.data(for: request)
    }

    private func makeRequest<T: Decodable>(endpoint: Endpoint, method: String) async throws -> T {
        let url = try makeUrl(for: endpoint)
        let request = makeUrlRequest(url: url, endpoint: endpoint, httpMethod: method)
        let (data, _) = try await urlSession.data(for: request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ClientError.unexpectedResponse
        }
    }

    private func makeUrl(for endpoint: Endpoint) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = apiHost
        components.path = "/v1/\(endpoint.path)"
        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw ClientError.unexpectedRequest
        }

        return url
    }

    private func makeUrlRequest(url: URL, endpoint: Endpoint, httpMethod: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        if let body = endpoint.bodyValue {
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(body)
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {}
        }

        return request
    }
}
