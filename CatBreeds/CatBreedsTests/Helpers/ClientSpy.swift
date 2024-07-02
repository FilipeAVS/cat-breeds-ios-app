//
//  ClientSpy.swift
//  CatBreedsTests
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation
import Network

final class ClientSpy: ClientType {
    var getResults = ThreadSafeResult<Decodable>()
    func get<T: Decodable>(endpoint: Endpoint) async throws -> T {
        return try getResults.removeLast()?.get() as! T
    }

    var postDecodableResults = ThreadSafeResult<Decodable>()
    func post<T: Decodable>(endpoint: Endpoint) async throws -> T {
        return try postDecodableResults.removeLast()?.get() as! T
    }

    var postVoidResults = ThreadSafeResult<Void>()
    func post(endpoint: Endpoint) async throws {
        try postVoidResults.removeLast()?.get()
    }

    var deleteResults = ThreadSafeResult<Void>()
    func delete(endpoint: Endpoint) async throws {
        try deleteResults.removeLast()?.get()
    }
}
