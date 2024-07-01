//
//  CatBreed.swift
//  CatBreeds
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation

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

struct BreedImage: Decodable, Equatable {
    let url: URL
}

struct FavouriteBreed: Decodable {
    let id: Int
    let imageId: String
    let image: BreedImage?
}
