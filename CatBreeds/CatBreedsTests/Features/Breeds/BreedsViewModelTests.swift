//
//  BreedsViewModelTests.swift
//  CatBreedsTests
//
//  Created by Filipe Santos on 02/07/2024.
//

@testable import CatBreeds
import Network
import XCTest

final class BreedsViewModelTests: XCTestCase {
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
    func test_loadBreeds_withSuccess_updatesCatBreeds_andUpdatesFavouriteBreeds_removeFromFavourites_withSuccess_doesNotUpdateBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([catBreed1, catBreed2]))
        sut.client.getResults.append(.success([favouriteBreed1]))

        XCTAssertTrue(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadBreeds()

        XCTAssertFalse(sut.viewModel.isLoading)
        XCTAssertEqual(sut.viewModel.breeds, [catBreed1, catBreed2])

        sut.client.getResults.append(.success([FavouriteBreed]()))
        sut.client.deleteResults.append(.success(()))

        await sut.viewModel.removeFromFavourites(favouriteBreed: favouriteBreed1)

        XCTAssertFalse(sut.viewModel.isLoading)
        XCTAssertEqual(sut.viewModel.breeds, [catBreed1, catBreed2])
    }

    @MainActor
    func test_loadBreeds_withSuccess_updatesCatBreeds_andUpdatesFavouriteBreeds_markAsFavourite_withSuccess_doesNotUpdateBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([catBreed1, catBreed2]))
        sut.client.getResults.append(.success([favouriteBreed1]))

        XCTAssertTrue(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadBreeds()

        XCTAssertFalse(sut.viewModel.isLoading)
        XCTAssertEqual(sut.viewModel.breeds, [catBreed1, catBreed2])

        sut.client.getResults.append(.success([FavouriteBreed]()))
        sut.client.postVoidResults.append(.success(()))

        await sut.viewModel.markAsFavourite(breed: catBreed1)

        XCTAssertFalse(sut.viewModel.isLoading)
        XCTAssertEqual(sut.viewModel.breeds, [catBreed1, catBreed2])
    }

    @MainActor
    func test_loadBreeds_afterLoading_getsFavouriteBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([catBreed1, catBreed2]))
        sut.client.getResults.append(.success([favouriteBreed1]))

        XCTAssertTrue(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [catBreed1, catBreed2])
        XCTAssertFalse(sut.viewModel.isLoading)

        sut.client.getResults.append(.success([FavouriteBreed]()))

        await sut.viewModel.loadBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [catBreed1, catBreed2])
    }


    @MainActor
    func test_loadMoreBreeds_withSuccess_updatesCatBreeds_andUpdatesFavouriteBreeds() async {
        let sut = makeSut()
        sut.client.getResults.append(.success([catBreed1, catBreed2]))

        XCTAssertTrue(sut.viewModel.breeds.isEmpty)

        await sut.viewModel.loadMoreBreeds()

        XCTAssertEqual(sut.viewModel.breeds, [catBreed1, catBreed2])
    }

    @MainActor
    func test_search_withSuccess_updatesSearchedCatBreeds() async {
        let sut = makeSut()

        sut.viewModel.search = "s"

        try? await Task.sleep(for: .milliseconds(400))

        XCTAssertEqual(sut.viewModel.breeds, [catBreed1, catBreed2])
    }

    // MARK: Helpers

    @MainActor
    private func makeSut() -> SystemUnderTest {
        let client = ClientSpy()
        client.getResults.append(.success([catBreed1, catBreed2]))
        return SystemUnderTest(
            viewModel: BreedsViewModel(client: client),
            client: client
        )
    }

    private struct SystemUnderTest {
        let viewModel: BreedsViewModel
        let client: ClientSpy
    }
}
