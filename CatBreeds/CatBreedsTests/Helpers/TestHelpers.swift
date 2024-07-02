//
//  TestHelpers.swift
//  CatBreedsTests
//
//  Created by Filipe Santos on 01/07/2024.
//

@testable import CatBreeds
import Foundation

func makeCatBreed(
    referenceImageId: String? = "referenceImageId",
    lifeSpan: String = "0 - 1"
) -> CatBreed {
    CatBreed(
        id: "id",
        name: "name",
        origin: "origin",
        temperament: "temperament",
        description: "description",
        referenceImageId: referenceImageId,
        lifeSpan: lifeSpan,
        image: nil
    )
}

func makeFavouriteBreed(
    imageId: String
) -> FavouriteBreed {
    FavouriteBreed(
        id: 1,
        imageId: imageId,
        image: nil
    )
}

public func anyError() -> Error {
    return NSError(domain: "", code: 0)
}
