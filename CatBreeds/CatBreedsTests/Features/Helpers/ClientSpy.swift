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
        return try getResults.popLast()?.get() as! T
    }

    var postDecodableResults = ThreadSafeResult<Decodable>()
    func post<T: Decodable>(endpoint: Endpoint) async throws -> T {
        return try postDecodableResults.popLast()?.get() as! T
    }

    var postVoidResults = ThreadSafeResult<Void>()
    func post(endpoint: Endpoint) async throws {
        try postVoidResults.popLast()?.get()
    }

    var deleteResults = ThreadSafeResult<Void>()
    func delete(endpoint: Endpoint) async throws {
        try deleteResults.popLast()?.get()
    }
}
