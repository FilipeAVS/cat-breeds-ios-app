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
    var container: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: LocalFavouriteBreed.self, configurations: config)
    }

    func insertCatBreeds(_ catBreeds: [LocalCatBreed]) {}

    func insertFavouriteBreeds(_ favouriteBreeds: [LocalFavouriteBreed]) {}

    var retrieveCatBreedsResult: [LocalCatBreed] = []
    func retrieveCatBreeds(from page: Int) -> [LocalCatBreed] {
        return retrieveCatBreedsResult
    }

    var retrieveFavouriteBreedsResult: [LocalFavouriteBreed] = []
    func retrieveFavouriteBreeds() -> [LocalFavouriteBreed] {
        return retrieveFavouriteBreedsResult
    }
}
