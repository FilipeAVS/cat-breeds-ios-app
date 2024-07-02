@testable import Storage
import SwiftData
import XCTest

final class StorageTests: XCTestCase {
    var page1 = 1
    var page2 = 2

    var localCatBreed1: LocalCatBreed {
        makeLocalCatBreed(page: page1)
    }

    var localCatBreed2: LocalCatBreed {
        makeLocalCatBreed(page: page2)
    }

    var localFavouriteBreed1: LocalFavouriteBreed {
        makeLocalFavouriteBreed()
    }

    @MainActor
    func test_retrieveCatBreeds_retrievedExpectedCatBreeds_afterCorrectInsertion() throws {
        let sut = try makeSut()

        sut.insertCatBreeds([localCatBreed1, localCatBreed2])

        let result1 = sut.retrieveCatBreeds(from: page1)

        XCTAssertEqual(result1.first?.page, page1)

        let result2 = sut.retrieveCatBreeds(from: page2)

        XCTAssertEqual(result2.first?.page, page2)
    }

    @MainActor
    func test_retrieveFavouriteBreeds_retrievedExpectedFavouriteBreeds_afterCorrectInsertion() throws  {
        let sut = try makeSut()

        sut.insertFavouriteBreeds([localFavouriteBreed1])

        let result = sut.retrieveFavouriteBreeds()

        XCTAssertEqual(result.count, 1)
    }

    // MARK: Helpers

    @MainActor
    private func makeSut() throws -> StorageType {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: LocalFavouriteBreed.self, LocalCatBreed.self, LocalBreedImage.self,
            configurations: config
        )

        return Storage(context: container.mainContext)
    }
}

func makeLocalCatBreed(
    page: Int = 1
) -> LocalCatBreed {
    LocalCatBreed(
        id: "id",
        name: "name",
        origin: "origin",
        temperament: "temperament",
        description: "description",
        referenceImageId: "referenceImageId",
        lifeSpan: "lifeSpan",
        page: page
    )
}

func makeLocalFavouriteBreed() -> LocalFavouriteBreed {
    LocalFavouriteBreed(
        id: 1,
        imageId: "imageId",
        image: nil
    )
}
