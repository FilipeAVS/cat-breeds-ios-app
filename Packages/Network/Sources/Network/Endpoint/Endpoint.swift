//
//  Endpoint.swift
//
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation

public protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var bodyValue: Encodable? { get }
}

public extension Endpoint {
    var bodyValue: Encodable? { nil }
}
