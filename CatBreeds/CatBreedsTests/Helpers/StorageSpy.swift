//
//  StorageSpy.swift
//  CatBreedsTests
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation
import Storage
import SwiftData

final class StorageSpy: StorageType {
    enum Message: Hashable {
        case insert([LocalFavouriteBreed])
        case retrieveFavouriteBreeds
    }

    private(set) var messages = Set<Message>()

    var container: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: LocalFavouriteBreed.self, configurations: config)
    }

    func insert(_ favouriteBreeds: [LocalFavouriteBreed]) {
        messages.insert(.insert(favouriteBreeds))
    }

    var retrieveFavouriteBreedsResult: [LocalFavouriteBreed] = []
    func retrieveFavouriteBreeds() -> [LocalFavouriteBreed] {
        messages.insert(.retrieveFavouriteBreeds)
        return retrieveFavouriteBreedsResult
    }
}
