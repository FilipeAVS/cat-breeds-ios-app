//
//  FavouritesView.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Network
import Storage
import SwiftUI

struct FavouritesView: View {
    @StateObject private var viewModel: FavouritesViewModel

    init(client: ClientType, storage: StorageType) {
        self._viewModel = StateObject(wrappedValue: FavouritesViewModel(client: client, storage: storage))
    }

    private var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.favouriteBreeds.isEmpty {
                    Text("No favourite breeds found.")
                } else {
                    ScrollView {
                        if !viewModel.breeds.isEmpty {
                            Text("Average life span: \(viewModel.averageLifeSpanString)")
                        }
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.breeds) { breed in
                                CatBreedGridItemView(
                                    catBreed: breed,
                                    favouriteBreed: viewModel.favouriteBreeds.first(where: { $0.imageId == breed.referenceImageId }),
                                    markAsFavourite: { _ in },
                                    removeFromFavourites: viewModel.removeFromFavourites
                                )
                                .task {
                                    if breed == viewModel.breeds.last {
                                        await viewModel.loadMoreBreeds()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .task {
                await viewModel.loadBreeds()
            }
            .navigationTitle("Favourites")
        }
        .alert(
            "Something went wrong",
            isPresented: $viewModel.showAlert,
            actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(viewModel.errorMessage ?? "")
            }
        )
    }
}
