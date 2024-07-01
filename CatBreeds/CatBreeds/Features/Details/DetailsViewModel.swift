//
//  DetailsViewModel.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Network
import SwiftUI

@MainActor
final class DetailsViewModel: ObservableObject {
    private let client: Client
    let catBreed: CatBreed

    @Published private(set) var favouriteBreeds: [(imageId: String, favouriteId: Int)] = []

    init(catBreed: CatBreed, client: Client) {
        self.catBreed = catBreed
        self.client = client
    }

    func loadFavouriteBreeds() async {
        do {
            let favouriteBreeds: [FavouriteBreed] = try await client.get(endpoint: Cats.favouriteBreeds)
            self.favouriteBreeds = favouriteBreeds.map { ($0.imageId, $0.id) }
        } catch {}
    }

    func markAsFavourite(breed: CatBreed) async {
        guard let imageId = breed.referenceImageId else { return }
        do {
            let body = MarkBreedAsFavouriteBody(imageId: imageId)
            let result: MarkBreedAsFavouriteResult = try await client.post(endpoint: Cats.markBreedAsFavourite(json: body))

            favouriteBreeds.append((imageId, result.id))
        } catch {}
    }

    func removeFromFavourites(favouriteId: Int) async {
        do {
            try await client.delete(endpoint: Cats.removeBreedFromFavourites(favouriteId: favouriteId))

            favouriteBreeds.removeAll(where: { $0.favouriteId == favouriteId })
        } catch {}
    }
}
