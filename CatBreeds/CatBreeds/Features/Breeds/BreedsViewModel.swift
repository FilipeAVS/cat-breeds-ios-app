//
//  BreedsViewModel.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import AsyncAlgorithms
import Combine
import Network
import SwiftUI

@MainActor
final class BreedsViewModel: ObservableObject {
    let client: ClientType
    private var currentPage: Int = 0

    @Published private var catBreeds: [CatBreed] = []
    @Published private(set) var isLoading = true
    @Published private(set) var favouriteBreeds: [FavouriteBreed] = []

    @Published var search: String = ""
    @Published private var searchCatBreeds: [CatBreed] = []

    private var tasks = Set<AnyCancellable>()

    var breeds: [CatBreed] {
        if search.isEmpty {
            catBreeds
        } else {
            searchCatBreeds
        }
    }

    init(client: ClientType) {
        self.client = client

        Task {
            for await searchQuery in $search.values.debounce(for: .milliseconds(300), clock: .continuous) {
                await searchBreeds(with: searchQuery)
            }
        }.store(in: &tasks)
    }

    func loadBreeds() async {
        guard isLoading else {
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
            catBreeds += try await client.get(endpoint: Cats.breeds(page: currentPage))
        } catch {}
    }

    private func searchBreeds(with searchTerm: String) async {
        do {
            searchCatBreeds = try await client.get(endpoint: Cats.searchBreeds(searchTerm: searchTerm))
        } catch {}
    }

    func markAsFavourite(breed: CatBreed) async {
        do {
            let body = MarkBreedAsFavouriteBody(imageId: breed.referenceImageId ?? "")
            try await client.post(endpoint: Cats.markBreedAsFavourite(json: body))

            favouriteBreeds = try await client.get(endpoint: Cats.favouriteBreeds)
        } catch {}
    }

    func removeFromFavourites(favouriteBreed: FavouriteBreed) async {
        do {
            try await client.delete(endpoint: Cats.removeBreedFromFavourites(favouriteId: favouriteBreed.id))

            favouriteBreeds = try await client.get(endpoint: Cats.favouriteBreeds)
        } catch {}
    }
}

extension Task {
    func store(in cancellables: inout Set<AnyCancellable>) {
        cancellables.insert(AnyCancellable(cancel))
    }
}
