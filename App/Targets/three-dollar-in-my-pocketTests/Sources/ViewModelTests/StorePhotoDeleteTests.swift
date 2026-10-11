import Combine
import XCTest

import Log
import Model
import Networking
@testable import Store

final class StorePhotoDeleteTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1440 TC1

    func test_TH1440_TC1_사진상세에서사진을삭제하면_가게상세를다시불러온다() throws {
        // Given
        let repository = MockStoreRepository()
        repository.fetchStorePhotosResult = .success(try makePhotosResponse(imageIds: [10, 11]))
        repository.deletePhotoResult = .success(nil)
        let viewModel = StoreSectionsViewModel(
            config: .init(storeId: 1, latitude: 37.5, longitude: 127.0),
            dependency: .init(storeRepository: repository, logManager: MockLogManager(), globalEventBus: MockGlobalEventBus())
        )
        let routeExpectation = expectation(description: "presentPhotoDetail")
        var photoDetailViewModel: PhotoDetailViewModel?
        viewModel.output.route
            .sink {
                if case .presentPhotoDetail(let detailViewModel) = $0 {
                    photoDetailViewModel = detailViewModel
                    routeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.input.didSelectAction.send(.custom(
            .init(actionType: .storeImageEnlarge, extraParams: [
                "IMAGE_ID": .string("10"),
                "IMAGE_URL": .string("https://example.com/10.png")
            ]),
            clickLog: nil
        ))
        wait(for: [routeExpectation], timeout: 1)
        let reloadExpectation = expectation(description: "reload")
        viewModel.output.error.first().sink { _ in reloadExpectation.fulfill() }.store(in: &cancellables)
        let callCountBeforeDelete = repository.fetchStoreScreenV2CallCount

        // When
        try XCTUnwrap(photoDetailViewModel).input.deletePhoto.send(())

        // Then
        wait(for: [reloadExpectation], timeout: 1)
        XCTAssertEqual(repository.fetchStoreScreenV2CallCount, callCountBeforeDelete + 1)
    }

    // MARK: TH-1440 TC2

    func test_TH1440_TC2_마지막사진을삭제하면_사진상세가닫힌다() throws {
        // Given
        let repository = MockStoreRepository()
        repository.deletePhotoResult = .success(nil)
        let photos = try makePhotosResponse(imageIds: [10]).contents.map { StoreDetailPhoto(response: $0.image) }
        let viewModel = PhotoDetailViewModel(
            config: .init(storeId: 1, photos: photos, nextCursor: nil, hasMore: false, currentIndex: 0),
            storeRepository: repository
        )
        let dismissExpectation = expectation(description: "dismiss")
        var scrolledIndexes: [Int] = []
        viewModel.output.dismiss.sink { dismissExpectation.fulfill() }.store(in: &cancellables)
        viewModel.output.scrollToIndex.sink { scrolledIndexes.append($0.index) }.store(in: &cancellables)

        // When
        viewModel.input.deletePhoto.send(())

        // Then
        wait(for: [dismissExpectation], timeout: 1)
        XCTAssertTrue(viewModel.output.photos.value.isEmpty)
        XCTAssertTrue(scrolledIndexes.isEmpty)
    }

    // MARK: - Helpers

    private func makePhotosResponse(imageIds: [Int]) throws -> ContentsWithCursorResponse<StoreImageWithApiResponse> {
        let contents = imageIds.map {
            """
            { "image": { "createdAt": "", "updatedAt": "", "imageId": \($0), "url": "https://example.com/\($0).png", "isOwner": false } }
            """
        }
        let json = """
        { "contents": [\(contents.joined(separator: ","))], "cursor": { "nextCursor": null, "hasMore": false } }
        """
        return try JSONDecoder().decode(ContentsWithCursorResponse<StoreImageWithApiResponse>.self, from: Data(json.utf8))
    }
}
