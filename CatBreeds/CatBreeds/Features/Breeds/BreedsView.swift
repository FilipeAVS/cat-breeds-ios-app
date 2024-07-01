//
//  BreedsView.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Network
import SwiftUI

struct BreedsView: View {
    @StateObject private var viewModel: BreedsViewModel

    init(client: ClientType) {
        self._viewModel = StateObject(wrappedValue: BreedsViewModel(client: client))
    }

    private var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.breeds) { breed in
                        NavigationLink {
                            DetailsView(catBreed: breed, client: viewModel.client)
                        } label: {
                            CatBreedGridItemView(
                                catBreed: breed,
                                favouriteBreed: viewModel.favouriteBreeds.first(where: { $0.imageId == breed.referenceImageId }),
                                markAsFavourite: viewModel.markAsFavourite,
                                removeFromFavourites: viewModel.removeFromFavourites
                            )
                        }
                        .task {
                            if breed == viewModel.breeds.last {
                                await viewModel.loadMoreBreeds()
                            }
                        }
                    }
                }
                .padding()
            }
            .task {
                await viewModel.loadBreeds()
            }
            .navigationTitle("Breeds")
            .searchable(text: $viewModel.search)
        }
    }
}
