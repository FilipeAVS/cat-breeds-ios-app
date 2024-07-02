//
//  FavouritesViewModel.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Network
import Storage
import SwiftUI

@MainActor
final class FavouritesViewModel: ObservableObject {
    let client: ClientType
    private let storage: StorageType
    private var currentPage: Int = 0

    @Published private var catBreeds: [CatBreed] = []
    @Published private(set) var isLoading = true
    @Published private(set) var favouriteBreeds: [FavouriteBreed] = []

    @Published var showAlert: Bool = false
    @Published private(set) var errorMessage: String?

    var breeds: [CatBreed] {
        catBreeds.filter { breed in
            favouriteBreeds.contains(where: { favouriteBreed in
                favouriteBreed.imageId == breed.referenceImageId
            })
        }
    }

    var averageLifeSpanString: String {
        if breeds.isEmpty {
            return ""
        }

        let averageLifeSpan = breeds.map(\.averageLifeSpan).reduce(0, +) / Double(breeds.count)

        return String(format: "%.2f", averageLifeSpan)
    }

    init(client: ClientType, storage: StorageType) {
        self.client = client
        self.storage = storage
    }

    func loadBreeds() async {
        guard isLoading else {
            do {
                favouriteBreeds = try await client.get(endpoint: Cats.favouriteBreeds)
                storage.insertFavouriteBreeds(favouriteBreeds.map(\.local))
            } catch {}
            return
        }

        currentPage = 0

        do {
            async let catBreedsRequest: [CatBreed] = client.get(endpoint: Cats.breeds(page: currentPage))
            async let favouriteBreedsRequest: [FavouriteBreed] = client.get(endpoint: Cats.favouriteBreeds)

            let (catBreeds, favouriteBreeds) = try await (catBreedsRequest, favouriteBreedsRequest)

            self.catBreeds = catBreeds
            self.favouriteBreeds = favouriteBreeds
        } catch {
            catBreeds = storage.retrieveCatBreeds(from: currentPage).map(CatBreed.init)
            favouriteBreeds = storage.retrieveFavouriteBreeds().map(FavouriteBreed.init)
        }

        isLoading = false
    }

    func loadMoreBreeds() async {
        currentPage += 1

        do {
            let catBreeds: [CatBreed] = try await client.get(endpoint: Cats.breeds(page: currentPage))
            storage.insertCatBreeds(catBreeds.map { $0.mapToLocal(with: currentPage) })
            self.catBreeds += catBreeds
        } catch {
            catBreeds += storage.retrieveCatBreeds(from: currentPage).map(CatBreed.init)
        }

        if breeds.count < favouriteBreeds.count {
            await loadMoreBreeds()
        }
    }

    func removeFromFavourites(favouriteBreed: FavouriteBreed) async {
        do {
            try await client.delete(endpoint: Cats.removeBreedFromFavourites(favouriteId: favouriteBreed.id))

            favouriteBreeds = try await client.get(endpoint: Cats.favouriteBreeds)
            storage.insertFavouriteBreeds(favouriteBreeds.map(\.local))
        } catch {
            errorMessage = "Failed to remove breed from favourites. Please try again"
            showAlert = true
        }
    }
}
