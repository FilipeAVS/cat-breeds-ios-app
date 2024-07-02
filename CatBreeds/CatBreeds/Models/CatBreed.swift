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

    init(
        id: String,
        name: String,
        origin: String,
        temperament: String,
        description: String,
        referenceImageId: String?,
        lifeSpan: String,
        image: BreedImage?
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.description = description
        self.referenceImageId = referenceImageId
        self.lifeSpan = lifeSpan
        self.image = image
    }

    init(from local: LocalCatBreed) {
        id = local.id
        name = local.name
        origin = local.origin
        temperament = local.temperament
        description = local.description_
        referenceImageId = local.referenceImageId
        lifeSpan = local.lifeSpan
        image = local.image.map(BreedImage.init)
    }

    func mapToLocal(with page: Int) -> LocalCatBreed {
        LocalCatBreed(
            id: id,
            name: name,
            origin: origin,
            temperament: temperament,
            description: description,
            referenceImageId: referenceImageId,
            lifeSpan: lifeSpan,
            page: page,
            image: image?.local
        )
    }
}

extension CatBreed {
    var averageLifeSpan: Double {
        lifeSpan.split(separator: " - ").compactMap(Double.init).reduce(0, +) / 2
    }
}
