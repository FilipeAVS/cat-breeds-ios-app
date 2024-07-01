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

    init(client: Client) {
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
                                .overlay(alignment: .topTrailing) {
                                    let favouriteBreed = viewModel.favouriteBreeds.first(where: { $0.imageId == breed.referenceImageId })

                                    Button(
                                        action: {
                                            Task {
                                                if let favouriteBreed {
                                                    await viewModel.removeFromFavourites(favouriteBreed: favouriteBreed)
                                                } else {
                                                    await viewModel.markAsFavourite(breed: breed)
                                                }
                                            }
                                        }
                                    ) {
                                        Image(systemName: favouriteBreed == nil ? "heart" : "heart.fill")
                                    }
                                    .tint(.red)
                                    .padding([.top, .trailing], 4)
                                }

                                Text(breed.name)
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.black)

                                Spacer()
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
            .task {
                await viewModel.loadBreeds()
            }
            .navigationTitle("Breeds")
            .searchable(text: $viewModel.search)
        }
    }
}
