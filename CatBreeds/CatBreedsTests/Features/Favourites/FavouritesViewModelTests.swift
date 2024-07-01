//
//  FavouritesViewModelTests.swift
//  CatBreedsTests
//
//  Created by Filipe Santos on 01/07/2024.
//

@testable import CatBreeds
import Network
import Storage
import XCTest

final class FavouritesViewModelTests: XCTestCase {
    private let imageId: String = "imageId"

    var catBreed1: CatBreed {
        makeCatBreed(referenceImageId: imageId)
    }

    var catBreed2: CatBreed {
        makeCatBreed(referenceImageId: "\(imageId)_2")
    }

    var favouriteBreed: FavouriteBreed {
        FavouriteBreed(
            id: 1,
            imageId: imageId,
            image: nil
        )
    }

    @MainActor
    func test_loadBreeds_withSuccess_updatesCatBreeds_andUpdatesFavouriteBreeds() async {
        let sut = makeSUT()
        sut.client.getResults.append(.success([catBreed1, catBreed2]))
        sut.client.getResults.append(.success([favouriteBreed]))

        XCTAssertTrue(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [catBreed1])
        XCTAssertFalse(sut.viewModel.isLoading)
    }

    // MARK: Helpers

    @MainActor
    private func makeSUT() -> SystemUnderTest {
        let client = ClientSpy()
        let storage = StorageSpy()
        return SystemUnderTest(
            viewModel: FavouritesViewModel(client: client, storage: storage),
            client: client,
            storage: storage
        )
    }

    private struct SystemUnderTest {
        let viewModel: FavouritesViewModel
        let client: ClientSpy
        let storage: StorageSpy
    }
}

extension XCTestCase {
    func makeCatBreed(
        referenceImageId: String? = "referenceImageId"
    ) -> CatBreed {
        CatBreed(
            id: "id",
            name: "name",
            origin: "origin",
            temperament: "temperament",
            description: "description",
            referenceImageId: referenceImageId,
            lifeSpan: "lifeSpan",
            image: nil
        )
    }
}
