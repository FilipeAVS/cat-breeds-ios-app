//
//  LocalCatBreed.swift
//
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation
import SwiftData

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
