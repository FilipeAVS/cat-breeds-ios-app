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

