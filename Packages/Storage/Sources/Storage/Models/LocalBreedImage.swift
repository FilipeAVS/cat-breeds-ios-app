//
//  LocalBreedImage.swift
//
//
//  Created by Filipe Santos on 02/07/2024.
//

import Foundation
import SwiftData

@Model
public final class LocalBreedImage {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }
}
