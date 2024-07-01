//
//  DetailsView.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Network
import SwiftUI

struct DetailsView: View {
    @StateObject private var viewModel: DetailsViewModel

    init(catBreed: CatBreed, client: Client) {
        self._viewModel = StateObject(wrappedValue: DetailsViewModel(catBreed: catBreed, client: client))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: viewModel.catBreed.image?.url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    if viewModel.catBreed.image?.url == nil {
                        Color.gray
                    } else {
                        ProgressView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxWidth: .infinity)
                .overlay(alignment: .topTrailing) {
                    let favouriteId = viewModel.favouriteBreeds.first(where: { $0.imageId == viewModel.catBreed.referenceImageId })?.favouriteId

                    Button(
                        action: {
                            Task {
                                if let favouriteId {
                                    await viewModel.removeFromFavourites(favouriteId: favouriteId)
                                } else {
                                    await viewModel.markAsFavourite(breed: viewModel.catBreed)
                                }
                            }
                        }
                    ) {
                        Image(systemName: favouriteId == nil ? "heart" : "heart.fill")
                    }
                    .tint(.red)
                }

                Text(viewModel.catBreed.origin)
                    .font(.headline)
                    .padding(.top, 16)

                Text(viewModel.catBreed.temperament)
                    .font(.subheadline)

                Text(viewModel.catBreed.description)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(viewModel.catBreed.name)
        .task {
            await viewModel.loadFavouriteBreeds()
        }
    }
}
