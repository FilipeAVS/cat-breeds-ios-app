//
//  Storage.swift
//
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation
import SwiftData

public protocol StorageType {
    var container: ModelContainer { get }

    func insert(_ favouriteBreeds: [LocalFavouriteBreed])
    func retrieveFavouriteBreeds() -> [LocalFavouriteBreed]
}

@Observable public class Storage: StorageType {
    public let container: ModelContainer
    private let context: ModelContext

    public init() {
        do {
            self.container = try ModelContainer(for: LocalFavouriteBreed.self)
            self.context = ModelContext(container)
        } catch {
            fatalError("Failed to create model container.")
        }
    }

    public func insert(_ favouriteBreeds: [LocalFavouriteBreed]) {
        favouriteBreeds
            .forEach(context.insert)
    }

    public func retrieveFavouriteBreeds() -> [LocalFavouriteBreed] {
        let descriptor = FetchDescriptor<LocalFavouriteBreed>()

        do {
            return try context.fetch(descriptor)
        } catch {
            return []
        }
    }
}
