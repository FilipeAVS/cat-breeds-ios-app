//
//  FavouriteBreed.swift
//  CatBreeds
//
//  Created by Filipe Santos on 02/07/2024.
//

import Foundation
import Storage

struct FavouriteBreed: Decodable {
    let id: Int
    let imageId: String
    let image: BreedImage?

    init(id: Int, imageId: String, image: BreedImage?) {
        self.id = id
        self.imageId = imageId
        self.image = image
    }

    init(from local: LocalFavouriteBreed) {
        id = local.id
        imageId = local.imageId
        image = local.image.map(BreedImage.init)
    }

    var local: LocalFavouriteBreed {
        LocalFavouriteBreed(id: id, imageId: imageId, image: image?.local)
    }
}
