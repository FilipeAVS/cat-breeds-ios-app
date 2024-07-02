//
//  BreedImage.swift
//  CatBreeds
//
//  Created by Filipe Santos on 02/07/2024.
//

import Foundation
import Storage

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
