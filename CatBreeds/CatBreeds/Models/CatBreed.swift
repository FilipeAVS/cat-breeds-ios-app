//
//  CatBreed.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation
import Storage

struct CatBreed: Decodable, Identifiable, Equatable {
    let id: String
    let name: String
    let origin: String
    let temperament: String
    let description: String
    let referenceImageId: String?
    let lifeSpan: String
    let image: BreedImage?
}

extension CatBreed {
    var averageLifeSpan: Double {
        lifeSpan.split(separator: " - ").compactMap(Double.init).reduce(0, +) / 2
    }
}

struct BreedImage: Decodable, Equatable {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    init(from local: LocalBreedImage) {
        url = local.url
    }

    var local: LocalBreedImage {
        LocalBreedImage(url: url)
    }
}

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
