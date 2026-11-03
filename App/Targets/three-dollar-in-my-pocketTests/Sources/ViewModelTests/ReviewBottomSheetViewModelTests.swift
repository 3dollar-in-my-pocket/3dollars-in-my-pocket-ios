import Combine
import XCTest

import Model
import Networking
@testable import Store

final class ReviewBottomSheetViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func test_TH1421_TC3_별점만입력하면_등록버튼이비활성이다() throws {
        // Given
        let viewModel = try makeViewModel()

        // When
        viewModel.input.didTapRating.send(4)

        // Then
        XCTAssertFalse(viewModel.output.isEnableWriteButton.value)
    }

    func test_TH1421_TC3_텍스트만입력하면_등록버튼이비활성이다() throws {
        // Given
        let viewModel = try makeViewModel()

        // When
        viewModel.input.inputReview.send("맛있어요")

        // Then
        XCTAssertFalse(viewModel.output.isEnableWriteButton.value)
    }

    func test_TH1421_TC4_별점과텍스트를입력하면_사진이없어도등록버튼이활성화된다() throws {
        // Given
        let viewModel = try makeViewModel()

        // When
        viewModel.input.didTapRating.send(4)
        viewModel.input.inputReview.send("맛있어요")

        // Then
        XCTAssertTrue(viewModel.output.images.value.isEmpty)
        XCTAssertTrue(viewModel.output.isEnableWriteButton.value)
    }

    func test_TH1421_TC5_사진9장이면_1장만고를수있는사진선택화면이열린다() throws {
        // Given
        let viewModel = try makeViewModel()
        try attachImages(count: 9, to: viewModel)
        var uploadLimit: Int?
        viewModel.output.route.sink {
            if case .uploadPhoto(let uploadViewModel) = $0 {
                uploadLimit = uploadViewModel.output.limitOfPhoto
            }
        }.store(in: &cancellables)

        // When
        viewModel.input.didTapUploadPhoto.send(())

        // Then
        XCTAssertEqual(uploadLimit, 1)
    }

    func test_TH1421_TC5_사진10장이면_추가할수없고토스트가뜬다() throws {
        // Given
        let viewModel = try makeViewModel()
        try attachImages(count: 10, to: viewModel)
        var toasts: [String] = []
        var routeCount = 0
        viewModel.output.showToast.sink { toasts.append($0) }.store(in: &cancellables)
        viewModel.output.route.sink { _ in routeCount += 1 }.store(in: &cancellables)

        // When
        viewModel.input.didTapUploadPhoto.send(())

        // Then
        XCTAssertEqual(viewModel.output.images.value.count, 10)
        XCTAssertEqual(toasts.count, 1)
        XCTAssertEqual(routeCount, 0)
    }

    func test_TH1421_TC6_사진삭제를누르면_그사진만빠진다() throws {
        // Given
        let viewModel = try makeViewModel()
        try attachImages(count: 3, to: viewModel)

        // When
        viewModel.input.removeImage.send(1)

        // Then
        XCTAssertEqual(viewModel.output.images.value.map(\.imageUrl), [imageUrl(0), imageUrl(2)])
    }

    func test_TH1421_TC7_등록하면_피드백빈배열과업로드한사진이전달된다() async throws {
        // Given
        let repository = MockStoreRepository()
        repository.writeReviewResult = .success(try FixtureLoader.decode(StoreReviewWithWriterResponse.self, from: "StoreReviewWithWriter"))
        let viewModel = try makeViewModel(repository: repository)
        try attachImages(count: 2, to: viewModel)
        viewModel.input.didTapRating.send(5)
        viewModel.input.inputReview.send("맛있어요")
        let dismissed = expectation(description: "dismiss")
        viewModel.output.route.sink {
            if case .dismiss = $0 { dismissed.fulfill() }
        }.store(in: &cancellables)

        // When
        viewModel.input.didTapWrite.send(())

        // Then
        await fulfillment(of: [dismissed], timeout: 2)
        let input = try XCTUnwrap(repository.writeReviewInputs.first)
        XCTAssertEqual(input.storeId, 153)
        XCTAssertEqual(input.rating, 5)
        XCTAssertEqual(input.contents, "맛있어요")
        XCTAssertTrue(input.feedbacks.isEmpty)
        XCTAssertEqual(input.images.map(\.url), [imageUrl(0), imageUrl(1)])
        let body = try JSONSerialization.jsonObject(with: JSONEncoder().encode(input)) as? [String: Any]
        XCTAssertEqual((body?["feedbacks"] as? [Any])?.count, 0)
    }

    func test_TH1421_TC9_사진있는내리뷰를수정하면_기존별점텍스트사진이채워진다() throws {
        // Given
        let review = try makeReviewWithImages()

        // When
        let viewModel = try makeViewModel(review: review)

        // Then
        XCTAssertEqual(viewModel.output.rating.value, review.rating)
        XCTAssertEqual(viewModel.output.contents.value, review.contents)
        XCTAssertEqual(viewModel.output.images.value, review.images)
        XCTAssertTrue(viewModel.output.isEnableWriteButton.value)
    }

    func test_TH1421_TC10_기존사진을지우고새사진을추가해저장하면_남은사진과새사진이전달된다() async throws {
        // Given
        let review = try makeReviewWithImages()
        let repository = MockStoreRepository()
        repository.editReviewResult = .success(
            try FixtureLoader.decode(StoreReviewWithWriterResponse.self, from: "StoreReviewWithWriterWithImages").review
        )
        let viewModel = try makeViewModel(repository: repository, review: review)
        viewModel.input.removeImage.send(0)
        try attachImages(count: 1, to: viewModel)
        let dismissed = expectation(description: "dismiss")
        viewModel.output.route.sink {
            if case .dismiss = $0 { dismissed.fulfill() }
        }.store(in: &cancellables)

        // When
        viewModel.input.didTapWrite.send(())

        // Then
        await fulfillment(of: [dismissed], timeout: 2)
        let arguments = try XCTUnwrap(repository.editReviewArguments.first)
        XCTAssertEqual(arguments.reviewId, review.reviewId)
        XCTAssertEqual(arguments.input.images.map(\.url), [review.images[1].imageUrl, imageUrl(0)])
        let body = try JSONSerialization.jsonObject(with: JSONEncoder().encode(arguments.input)) as? [String: Any]
        XCTAssertEqual((body?["images"] as? [Any])?.count, 2)
        XCTAssertNil(body?["nonceToken"])
    }

    func test_TH1421_TC11_텍스트가300자를넘으면_입력되지않는다() {
        // Given
        let sheet = ReviewBottomSheet()
        sheet.textView.text = String(repeating: "가", count: 300)

        // When
        let shouldChange = sheet.textView(
            sheet.textView,
            shouldChangeTextIn: NSRange(location: 300, length: 0),
            replacementText: "나"
        )

        // Then
        XCTAssertFalse(shouldChange)
    }

    func test_TH1421_TC15_등록이실패하면_에러가뜨고시트가유지된다() async throws {
        // Given
        let repository = MockStoreRepository()
        repository.writeReviewResult = .failure(NSError(domain: "ReviewBottomSheet", code: -1))
        let viewModel = try makeViewModel(repository: repository)
        try attachImages(count: 1, to: viewModel)
        viewModel.input.didTapRating.send(3)
        viewModel.input.inputReview.send("보통이에요")
        let errorReceived = expectation(description: "error")
        var dismissCount = 0
        viewModel.output.errorAlert.sink { _ in errorReceived.fulfill() }.store(in: &cancellables)
        viewModel.output.route.sink {
            if case .dismiss = $0 { dismissCount += 1 }
        }.store(in: &cancellables)

        // When
        viewModel.input.didTapWrite.send(())

        // Then
        await fulfillment(of: [errorReceived], timeout: 2)
        XCTAssertEqual(dismissCount, 0)
        XCTAssertEqual(viewModel.output.images.value.count, 1)
        XCTAssertTrue(viewModel.output.isEnableWriteButton.value)
    }

    func test_TH1421_TC16_가게명이전달되면_시트에가게명이보인다() throws {
        // Given
        let viewModel = try makeViewModel(storeName: "강남역 주변 가게")
        let viewController = ReviewBottomSheetViewController.instance(viewModel: viewModel)

        // When
        viewController.loadViewIfNeeded()

        // Then
        let sheet = try XCTUnwrap(viewController.view as? ReviewBottomSheet)
        XCTAssertEqual(sheet.storeNameLabel.text, "강남역 주변 가게")
        XCTAssertFalse(sheet.storeNameLabel.isHidden)
    }

    func test_TH1421_TC16_가게명이없으면_가게명줄이숨겨진다() throws {
        // Given
        let viewModel = try makeViewModel()
        let sheet = ReviewBottomSheet()

        // When
        sheet.setStoreName(viewModel.output.storeName)

        // Then
        XCTAssertNil(viewModel.output.storeName)
        XCTAssertTrue(sheet.storeNameLabel.isHidden)
    }

    private func makeViewModel(
        repository: MockStoreRepository = MockStoreRepository(),
        storeName: String? = nil,
        review: StoreDetailReview? = nil
    ) throws -> ReviewBottomSheetViewModel {
        let commonRepository = MockCommonRepository()
        commonRepository.createNonceTokenResult = .success(try JSONDecoder().decode(
            NonceResponse.self,
            from: Data(#"{"nonce":"test-nonce"}"#.utf8)
        ))
        return ReviewBottomSheetViewModel(
            config: .init(storeId: 153, storeName: storeName, review: review),
            storeService: repository,
            logManager: MockLogManager(),
            commonRepository: commonRepository
        )
    }

    private func attachImages(count: Int, to viewModel: ReviewBottomSheetViewModel) throws {
        var uploadViewModel: UploadPhotoViewModel?
        let subscription = viewModel.output.route.sink {
            if case .uploadPhoto(let viewModel) = $0 { uploadViewModel = viewModel }
        }
        viewModel.input.didTapUploadPhoto.send(())
        subscription.cancel()

        let uploaded = try (0..<count).map {
            try JSONDecoder().decode(
                ImageUploadResponse.self,
                from: Data(#"{"imageUrl":"\#(imageUrl($0))","width":300,"height":300}"#.utf8)
            )
        }
        uploadViewModel?.output.onSuccessUploadImages.send(uploaded)
    }

    private func imageUrl(_ index: Int) -> String {
        "https://storage.threedollars.co.kr/review/new-\(index).png"
    }

    private func makeReviewWithImages() throws -> StoreDetailReview {
        let response = try FixtureLoader.decode(StoreReviewWithWriterResponse.self, from: "StoreReviewWithWriterWithImages")
        return StoreDetailReview(response: response)
    }
}
