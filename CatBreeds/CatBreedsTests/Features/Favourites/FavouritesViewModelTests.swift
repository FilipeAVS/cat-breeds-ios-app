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
    private let imageId1: String = "imageId_1"
    private let imageId2: String = "imageId_2"
    private let lifeSpan1: String = "12 - 13"
    private let lifeSpan2: String = "13 - 14"

    var catBreed1: CatBreed {
        makeCatBreed(
            referenceImageId: imageId1,
            lifeSpan: lifeSpan1
        )
    }

    var catBreed2: CatBreed {
        makeCatBreed(
            referenceImageId: imageId2,
            lifeSpan: lifeSpan2
        )
    }

    var favouriteBreed1: FavouriteBreed {
        makeFavouriteBreed(imageId: imageId1)
    }

    var favouriteBreed2: FavouriteBreed {
        makeFavouriteBreed(imageId: imageId2)
    }

    @MainActor
    func test_loadBreeds_withSuccess_updatesCatBreeds_andUpdatesFavouriteBreeds_removeFromFavourites_withSuccess_updatesBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([catBreed1, catBreed2]))
        sut.client.getResults.append(.success([favouriteBreed1]))

        XCTAssertTrue(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.breeds.isEmpty)
        XCTAssertEqual(sut.viewModel.averageLifeSpanString, "")

        await sut.viewModel.loadBreeds()

        XCTAssertFalse(sut.viewModel.isLoading)
        XCTAssertEqual(sut.viewModel.breeds, [catBreed1])
        XCTAssertEqual(sut.viewModel.averageLifeSpanString, "12.50")

        sut.client.getResults.append(.success([FavouriteBreed]()))
        sut.client.deleteResults.append(.success(()))

        await sut.viewModel.removeFromFavourites(favouriteBreed: favouriteBreed1)

        XCTAssertFalse(sut.viewModel.isLoading)
        XCTAssertEqual(sut.viewModel.breeds, [])
        XCTAssertEqual(sut.viewModel.averageLifeSpanString, "")
    }

    @MainActor
    func test_loadBreeds_withFailure_doesNotUpdateCatBreeds_andDoesNotUpdateFavouriteBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.failure(anyError()))
        sut.client.getResults.append(.failure(anyError()))

        XCTAssertTrue(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadBreeds()

        XCTAssertFalse(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.breeds.isEmpty)
    }

    @MainActor
    func test_loadMoreBreeds_withSuccess_updatesCatBreeds_andUpdatesFavouriteBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([catBreed1, catBreed2]))
        sut.client.getResults.append(.success([favouriteBreed2]))

        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadMoreBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [catBreed2])
    }

    @MainActor
    func test_loadMoreBreeds_withSuccess_withMoreFavouritesThanBreeds_loadsMoreAgain() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([catBreed2]))
        sut.client.getResults.append(.success([favouriteBreed1, favouriteBreed2]))
        sut.client.getResults.append(.success([catBreed1]))
        sut.client.getResults.append(.success([favouriteBreed1, favouriteBreed2]))

        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadMoreBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [catBreed1, catBreed2])
        XCTAssertEqual(sut.viewModel.averageLifeSpanString, "13.00")
    }

    @MainActor
    func test_removeFromFavourites_withFailure_showsAlert() async {
        let sut = makeSut()

        sut.client.deleteResults.append(.failure(anyError()))
        await sut.viewModel.removeFromFavourites(favouriteBreed: favouriteBreed1)

        XCTAssertTrue(sut.viewModel.showAlert)
        XCTAssertEqual(sut.viewModel.errorMessage, "Failed to remove breed from favourites. Please try again")
    }

    @MainActor
    func test_loadBreeds_afterLoading_getsFavouriteBreeds_withSuccess_updatesBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([catBreed1, catBreed2]))
        sut.client.getResults.append(.success([favouriteBreed1]))

        XCTAssertTrue(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [catBreed1])
        XCTAssertFalse(sut.viewModel.isLoading)

        sut.client.getResults.append(.success([FavouriteBreed]()))

        await sut.viewModel.loadBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [])
    }

    @MainActor
    func test_loadBreeds_afterLoading_getsFavouriteBreeds_withFailure_getsFavouriteBreedsFromStorage_andUpdatesBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([catBreed1, catBreed2]))
        sut.client.getResults.append(.success([favouriteBreed1]))

        XCTAssertTrue(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [catBreed1])
        XCTAssertFalse(sut.viewModel.isLoading)

        sut.client.getResults.append(.failure(anyError()))
        sut.storage.retrieveFavouriteBreedsResult = []

        await sut.viewModel.loadBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [])
    }

    // MARK: Helpers

    @MainActor
    private func makeSut() -> SystemUnderTest {
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
