//
//  FavouritesViewModel.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Network
import SwiftUI

@MainActor
final class FavouritesViewModel: ObservableObject {
    private let client: Client
    private var currentPage: Int = 0

    @Published private var catBreeds: [CatBreed] = []
    @Published private(set) var isLoading = true
    @Published private(set) var favouriteBreeds: [FavouriteBreed] = []

    var breeds: [CatBreed] {
        catBreeds.filter { breed in favouriteBreeds.contains(where: { $0.imageId == breed.referenceImageId }) }
    }

    init(client: Client) {
        self.client = client
    }

    func loadBreeds() async {
        guard currentPage == 0 else {
            do {
                favouriteBreeds = try await client.get(endpoint: Cats.favouriteBreeds)
            } catch {}
            return
        }

        do {
            async let catBreedsRequest: [CatBreed] = client.get(endpoint: Cats.breeds(page: currentPage))
            async let favouriteBreedsRequest: [FavouriteBreed] = client.get(endpoint: Cats.favouriteBreeds)

            let (catBreeds, favouriteBreeds) = try await (catBreedsRequest, favouriteBreedsRequest)

            self.catBreeds = catBreeds
            self.favouriteBreeds = favouriteBreeds
        } catch {}

        isLoading = false
    }

    func loadMoreBreeds() async {
        currentPage += 1

        do {
            async let catBreedsRequest: [CatBreed] = client.get(endpoint: Cats.breeds(page: currentPage))
            async let favouriteBreedsRequest: [FavouriteBreed] = client.get(endpoint: Cats.favouriteBreeds)

            let (catBreeds, favouriteBreeds) = try await (catBreedsRequest, favouriteBreedsRequest)

            self.catBreeds += catBreeds
            self.favouriteBreeds = favouriteBreeds
        } catch {}
    }

    func removeFromFavourites(favouriteBreed: FavouriteBreed) async {
        do {
            try await client.delete(endpoint: Cats.removeBreedFromFavourites(favouriteId: favouriteBreed.id))

            favouriteBreeds = try await client.get(endpoint: Cats.favouriteBreeds)
        } catch {}
    }
}
