//
//  BreedsViewModel.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import AsyncAlgorithms
import Combine
import Network
import Storage
import SwiftUI

@MainActor
final class BreedsViewModel: ObservableObject {
    let client: ClientType
    private let storage: StorageType
    private var currentPage: Int = 0

    @Published private var catBreeds: [CatBreed] = []
    @Published private(set) var isLoading = true
    @Published private(set) var favouriteBreeds: [FavouriteBreed] = []

    @Published var search: String = ""
    @Published private var searchCatBreeds: [CatBreed] = []

    @Published var showAlert: Bool = false
    @Published private(set) var errorMessage: String?

    private var tasks = Set<AnyCancellable>()

    var breeds: [CatBreed] {
        if search.isEmpty {
            catBreeds
        } else {
            searchCatBreeds
        }
    }

    init(client: ClientType, storage: StorageType) {
        self.client = client
        self.storage = storage

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
                storage.insertFavouriteBreeds(favouriteBreeds.map(\.local))
            } catch {}
            return
        }

        do {
            async let catBreedsRequest: [CatBreed] = client.get(endpoint: Cats.breeds(page: currentPage))
            async let favouriteBreedsRequest: [FavouriteBreed] = client.get(endpoint: Cats.favouriteBreeds)

            let (catBreeds, favouriteBreeds) = try await (catBreedsRequest, favouriteBreedsRequest)

            storage.insertCatBreeds(catBreeds.map { $0.mapToLocal(with: currentPage) })
            storage.insertFavouriteBreeds(favouriteBreeds.map(\.local))

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
    }

    private func searchBreeds(with searchTerm: String) async {
        do {
            searchCatBreeds = try await client.get(endpoint: Cats.searchBreeds(searchTerm: searchTerm))
            storage.insertCatBreeds(catBreeds.map { $0.mapToLocal(with: currentPage) })
        } catch {}
    }

    func markAsFavourite(breed: CatBreed) async {
        do {
            let body = MarkBreedAsFavouriteBody(imageId: breed.referenceImageId ?? "")
            try await client.post(endpoint: Cats.markBreedAsFavourite(json: body))

            favouriteBreeds = try await client.get(endpoint: Cats.favouriteBreeds)
            storage.insertFavouriteBreeds(favouriteBreeds.map(\.local))
        } catch {
            errorMessage = "Failed to mark breed as favourite. Please try again"
            showAlert = true
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

extension Task {
    func store(in cancellables: inout Set<AnyCancellable>) {
        cancellables.insert(AnyCancellable(cancel))
    }
}
