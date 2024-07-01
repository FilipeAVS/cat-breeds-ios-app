//
//  CatBreedGridItemView.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import SwiftUI

struct CatBreedGridItemView: View {
    var catBreed: CatBreed
    var favouriteBreed: FavouriteBreed?
    var markAsFavourite: (CatBreed) async -> Void
    var removeFromFavourites: (FavouriteBreed) async -> Void

    @State private var isLoading = false

    var body: some View {
        VStack {
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
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .topTrailing) {
                Button(
                    action: {
                        isLoading = true
                        Task {
                            if let favouriteBreed {
                                await removeFromFavourites(favouriteBreed)
                            } else {
                                await markAsFavourite(catBreed)
                            }
                            isLoading = false
                        }
                    }
                ) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: favouriteBreed == nil ? "heart" : "heart.fill")
                    }
                }
                .tint(.red)
                .padding([.top, .trailing], 4)
                .disabled(isLoading)
            }

            Text(catBreed.name)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.black)

            Spacer()
        }
    }
}
