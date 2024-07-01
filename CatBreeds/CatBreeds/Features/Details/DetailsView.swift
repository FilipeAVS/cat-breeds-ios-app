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
    private var catBreed: CatBreed
    @State private var isLoading = false

    init(catBreed: CatBreed, client: ClientType) {
        self._viewModel = StateObject(wrappedValue: DetailsViewModel(client: client))
        self.catBreed = catBreed
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: catBreed.image?.url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    if catBreed.image?.url == nil {
                        Color.gray
                    } else {
                        ProgressView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxWidth: .infinity)
                .overlay(alignment: .topTrailing) {
                    let favouriteId = viewModel.favouriteBreeds
                        .first(where: { $0.imageId == catBreed.referenceImageId })?.favouriteId

                    Button(
                        action: {
                            isLoading = true
                            Task {
                                if let favouriteId {
                                    await viewModel.removeFromFavourites(favouriteId: favouriteId)
                                } else {
                                    await viewModel.markAsFavourite(breed: catBreed)
                                }
                                isLoading = false
                            }
                        }
                    ) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: favouriteId == nil ? "heart" : "heart.fill")
                        }
                    }
                    .tint(.red)
                    .disabled(isLoading)
                }

                Text(catBreed.origin)
                    .font(.headline)
                    .padding(.top, 16)

                Text(catBreed.temperament)
                    .font(.subheadline)

                Text(catBreed.description)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(catBreed.name)
        .task {
            await viewModel.loadFavouriteBreeds()
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
