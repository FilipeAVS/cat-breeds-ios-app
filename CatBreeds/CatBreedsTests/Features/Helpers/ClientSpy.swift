//
//  ClientSpy.swift
//  CatBreedsTests
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation
import Network

final class ClientSpy: ClientType {
    enum Message: Hashable {
        case get(path: String)
        case post(path: String)
        case delete(path: String)
    }

    private(set) var messages = Set<Message>()

    var getResult: Result<Decodable, Error> = .failure(anyError())
    func get<T: Decodable>(endpoint: Endpoint) async throws -> T {
        messages.insert(.get(path: endpoint.path))
        return try getResult.get() as! T
    }

    var postDecodableResult: Result<Decodable, Error> = .failure(anyError())
    func post<T: Decodable>(endpoint: Endpoint) async throws -> T {
        return try postDecodableResult.get() as! T
    }

    var postVoidResult: Result<Void, Error> = .failure(anyError())
    func post(endpoint: Endpoint) async throws {
        try postVoidResult.get()
    }

    var deleteResult: Result<Void, Error> = .failure(anyError())
    func delete(endpoint: Endpoint) async throws {
        try deleteResult.get()
    }
}
