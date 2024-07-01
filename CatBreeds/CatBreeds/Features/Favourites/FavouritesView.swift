//
//  FavouritesView.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Network
import SwiftUI

struct FavouritesView: View {
    @StateObject private var viewModel: FavouritesViewModel

    init(client: Client) {
        self._viewModel = StateObject(wrappedValue: FavouritesViewModel(client: client))
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
                        LazyVGrid(columns: columns) {
                            ForEach(viewModel.breeds) { breed in
                                VStack {
                                    AsyncImage(url: breed.image?.url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        if breed.image?.url == nil {
                                            Color.gray
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))

                                    Text(breed.name)
                                        .frame(maxWidth: .infinity)

                                    Spacer()
                                }
                                .overlay(alignment: .topTrailing) {
                                    let favouriteBreed = viewModel.favouriteBreeds.first(where: { $0.imageId == breed.referenceImageId })

                                    Button(action: {
                                        Task {
                                            if let favouriteBreed {
                                                await viewModel.removeFromFavourites(favouriteBreed: favouriteBreed)
                                            }
                                        }
                                    }) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .font(.title)
                                    }
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
                }
            }
            .task {
                await viewModel.loadBreeds()
            }
            .navigationTitle("Favourites")
        }
    }
}
