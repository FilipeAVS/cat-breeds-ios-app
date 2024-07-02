//
//  LocalCatBreed.swift
//
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation
import SwiftData

@Model
public final class LocalCatBreed {
    @Attribute(.unique) public let id: String
    public let name: String
    public let origin: String
    public let temperament: String
    public let description_: String
    public let referenceImageId: String?
    public let lifeSpan: String
    public let page: Int
    @Relationship() public var image: LocalBreedImage?

    public init(
        id: String,
        name: String,
        origin: String,
        temperament: String,
        description: String,
        referenceImageId: String?,
        lifeSpan: String,
        page: Int,
        image: LocalBreedImage? = nil
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.description_ = description
        self.referenceImageId = referenceImageId
        self.lifeSpan = lifeSpan
        self.page = page
        self.image = image
    }
}

@Model
public final class LocalFavouriteBreed {
    @Attribute(.unique) public let id: Int
    public let imageId: String
    @Relationship() public var image: LocalBreedImage?

    public init(id: Int, imageId: String, image: LocalBreedImage?) {
        self.id = id
        self.imageId = imageId
        self.image = image
    }
}

@Model
public final class LocalBreedImage {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }
}
