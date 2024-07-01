//
//  Cats.swift
//
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation

public enum Cats: Endpoint {
    case breeds(page: Int)
    case favouriteBreeds
    case searchBreeds(searchTerm: String)
    case markBreedAsFavourite(json: MarkBreedAsFavouriteBody)
    case removeBreedFromFavourites(favouriteId: Int)

    public var path: String {
        switch self {
        case .breeds:
            "breeds"
        case .favouriteBreeds:
            "favourites"
        case .searchBreeds:
            "breeds/search"
        case .markBreedAsFavourite:
            "favourites"
        case let .removeBreedFromFavourites(favouriteId):
            "favourites/\(favouriteId)"
        }
    }

    public var queryItems: [URLQueryItem]? {
        switch self {
        case let .breeds(page):
            [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "12")
            ]
        case let .searchBreeds(searchTerm):
            [URLQueryItem(name: "q", value: searchTerm)]
        default:
            nil
        }
    }

    public var bodyValue: (any Encodable)? {
        switch self {
        case let .markBreedAsFavourite(body):
            body
        default:
            nil
        }
    }
}

public struct MarkBreedAsFavouriteBody: Encodable {
    public let imageId: String

    public init(imageId: String) {
        self.imageId = imageId
    }
}

public struct MarkBreedAsFavouriteResult: Decodable {
    public let id: Int
}
