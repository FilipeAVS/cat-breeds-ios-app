//
//  DetailsViewModelTests.swift
//  CatBreedsTests
//
//  Created by Filipe Santos on 01/07/2024.
//

@testable import CatBreeds
import Network
import XCTest

final class DetailsViewModelTests: XCTestCase {
    private var favouriteBreed: FavouriteBreed {
        FavouriteBreed(
            id: 1,
            imageId: "imageId",
            image: nil
        )
    }

    private var catBreed: CatBreed {
        CatBreed(
            id: "id",
            name: "name",
            origin: "origin",
            temperament: "temperament",
            description: "description",
            referenceImageId: "referenceImageId",
            lifeSpan: "lifeSpan",
            image: nil
        )
    }

    @MainActor
    func test_loadFavouriteBreeds_withSuccess_loadsFavouriteBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([favouriteBreed]))

        XCTAssertTrue(sut.viewModel.favouriteBreeds.isEmpty)

        await sut.viewModel.loadFavouriteBreeds()

        XCTAssertEqual(sut.viewModel.favouriteBreeds.first?.favouriteId, favouriteBreed.id)
        XCTAssertEqual(sut.viewModel.favouriteBreeds.first?.imageId, favouriteBreed.imageId)
    }

    @MainActor
    func test_loadFavouriteBreeds_withFailure_favouriteBreedsEmpty() async {
        let sut = makeSut()

        sut.client.getResults.append(.failure(anyError()))

        XCTAssertTrue(sut.viewModel.favouriteBreeds.isEmpty)

        await sut.viewModel.loadFavouriteBreeds()

        XCTAssertTrue(sut.viewModel.favouriteBreeds.isEmpty)
    }

    @MainActor
    func test_markAsFavourite_withSuccess_removeFromFavourites_withSuccess_updatesFavouriteBreeds() async {
        let sut = makeSut()
        let id = 1
        let markAsFavouriteResult = MarkBreedAsFavouriteResult(id: id)

        XCTAssertTrue(sut.viewModel.favouriteBreeds.isEmpty)

        sut.client.postDecodableResults.append(.success(markAsFavouriteResult))
        await sut.viewModel.markAsFavourite(breed: catBreed)

        XCTAssertEqual(sut.viewModel.favouriteBreeds.first?.favouriteId, id)
        XCTAssertEqual(sut.viewModel.favouriteBreeds.first?.imageId, catBreed.referenceImageId)

        sut.client.deleteResults.append(.success(()))
        await sut.viewModel.removeFromFavourites(favouriteId: id)

        XCTAssertTrue(sut.viewModel.favouriteBreeds.isEmpty)
    }

    @MainActor
    func test_markAsFavourite_withFailure_showsAlert() async {
        let sut = makeSut()

        sut.client.postDecodableResults.append(.failure(anyError()))
        await sut.viewModel.markAsFavourite(breed: catBreed)

        XCTAssertTrue(sut.viewModel.showAlert)
        XCTAssertEqual(sut.viewModel.errorMessage, "Failed to mark breed as favourite. Please try again")
    }

    @MainActor
    func test_removeFromFavourites_withFailure_showsAlert() async {
        let sut = makeSut()
        let favouriteId = 1

        sut.client.deleteResults.append(.failure(anyError()))
        await sut.viewModel.removeFromFavourites(favouriteId: favouriteId)

        XCTAssertTrue(sut.viewModel.showAlert)
        XCTAssertEqual(sut.viewModel.errorMessage, "Failed to remove breed from favourites. Please try again")
    }

    // MARK: Helpers

    @MainActor
    private func makeSut() -> SystemUnderTest {
        let client = ClientSpy()
        return SystemUnderTest(
            viewModel: DetailsViewModel(client: client),
            client: client
        )
    }

    private struct SystemUnderTest {
        let viewModel: DetailsViewModel
        let client: ClientSpy
    }
}
