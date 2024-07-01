//
//  BreedsView.swift
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
    private let client: Client
    private var currentPage: Int = 0

    @Published private var catBreeds: [CatBreed] = []

    @Published var search: String = ""
    @Published private var searchedCatBreeds: [CatBreed] = []

    private var tasks = Set<AnyCancellable>()

    var breeds: [CatBreed] {
        if search.isEmpty {
            catBreeds
        } else {
            searchedCatBreeds
        }
    }

    init(client: Client) {
        self.client = client

        Task {
            for await searchQuery in $search.values.debounce(for: .milliseconds(300), clock: .continuous) {
                await searchBreeds(with: searchQuery)
            }
        }.store(in: &tasks)
    }

    func loadBreeds() async {
        currentPage = 1

        do {
            catBreeds = try await client.get(endpoint: Cats.breeds(page: currentPage))
        } catch {}
    }

    func loadMoreBreeds() async {
        currentPage += 1

        do {
            catBreeds += try await client.get(endpoint: Cats.breeds(page: currentPage))
        } catch {}
    }

    func searchBreeds(with term: String) async {
        do {
            searchedCatBreeds = try await client.get(endpoint: Cats.searchBreeds(searchTerm: term))
        } catch {}
    }
}

struct BreedsView: View {
    @StateObject private var viewModel: BreedsViewModel

    init(client: Client) {
        self._viewModel = StateObject(wrappedValue: BreedsViewModel(client: client))
    }

    var body: some View {
        NavigationStack {
            List(viewModel.breeds) { breed in
                Text(breed.name)
                    .task {
                        if breed == viewModel.breeds.last {
                            await viewModel.loadMoreBreeds()
                        }
                    }
            }
            .task {
                await viewModel.loadBreeds()
            }
            .navigationTitle("Breeds")
            .searchable(text: $viewModel.search)
        }
    }
}

extension Task {
    func store(in cancellables: inout Set<AnyCancellable>) {
        cancellables.insert(AnyCancellable(cancel))
    }
}
