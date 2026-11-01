import Combine
import CoreLocation
import XCTest

import Model
import WriteInterface
@testable import Write

final class MenuExtractionStoreImageTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let menuImage = Data([0x01, 0x02, 0x03])

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1542 TC1, TC2

    func test_TH1542_TC1_제보중AI메뉴판을등록하고제보가완료되면_메뉴판사진이생성된가게사진으로한번업로드된다() throws {
        // Given
        let store = try makeUserStore(storeId: 77)
        let storeRepository = MockStoreRepository()
        storeRepository.createStoreResult = .success(store)
        storeRepository.uploadPhotosResult = .success([])
        let commonRepository = MockCommonRepository()
        commonRepository.createNonceTokenResult = .success(try makeNonce())
        let viewModel = WriteNavigationViewModel(
            dependency: .init(storeRepository: storeRepository, commonRepository: commonRepository)
        )
        let completed = expectation(description: "write complete")
        var categoryViewModel: WriteDetailCategoryViewModel?
        viewModel.output.route.sink { route in
            switch route {
            case .pushWriteDetailCategory(let viewModel):
                categoryViewModel = viewModel
            case .pushWriteComplete:
                completed.fulfill()
            default:
                break
            }
        }.store(in: &cancellables)
        viewModel.input.finishWriteAddress.send(("서울", CLLocation(latitude: 37.5, longitude: 127.0)))
        viewModel.input.finishWriteDetailInfo.send(("가게", .road))
        try registerMenuExtraction(on: XCTUnwrap(categoryViewModel))

        // When
        viewModel.input.didTapSkip.send(())

        // Then
        wait(for: [completed], timeout: 2)
        XCTAssertEqual(storeRepository.uploadPhotosArguments.count, 1)
        XCTAssertEqual(storeRepository.uploadPhotosArguments.first?.storeId, 77)
        XCTAssertEqual(storeRepository.uploadPhotosArguments.first?.photos, [menuImage])
    }

    func test_TH1542_TC2_AI메뉴판없이제보가완료되면_가게사진을업로드하지않는다() throws {
        // Given
        let storeRepository = MockStoreRepository()
        storeRepository.createStoreResult = .success(try makeUserStore(storeId: 77))
        let commonRepository = MockCommonRepository()
        commonRepository.createNonceTokenResult = .success(try makeNonce())
        let viewModel = WriteNavigationViewModel(
            dependency: .init(storeRepository: storeRepository, commonRepository: commonRepository)
        )
        let completed = expectation(description: "write complete")
        viewModel.output.route.sink { route in
            if case .pushWriteComplete = route { completed.fulfill() }
        }.store(in: &cancellables)
        viewModel.input.finishWriteAddress.send(("서울", CLLocation(latitude: 37.5, longitude: 127.0)))
        viewModel.input.finishWriteDetailInfo.send(("가게", .road))

        // When
        viewModel.input.didTapSkip.send(())

        // Then
        wait(for: [completed], timeout: 2)
        XCTAssertTrue(storeRepository.uploadPhotosArguments.isEmpty)
    }

    // MARK: TH-1542 TC3, TC4, TC5

    func test_TH1542_TC3_수정화면에서AI메뉴판을등록하고수정이성공하면_메뉴판사진이가게사진으로한번업로드된다() throws {
        // Given
        let store = try makeUserStore(storeId: 1)
        let repository = MockStoreRepository()
        repository.patchStoreResult = .success(store)
        repository.uploadPhotosResult = .success([])
        let viewModel = EditStoreViewModel(
            config: EditStoreViewModelConfig(store: store, fromScreen: nil),
            dependency: .init(storeRepository: repository, logManager: MockLogManager())
        )
        let dismissed = expectation(description: "dismiss")
        var menuViewModel: WriteDetailMenuViewModel?
        viewModel.output.route.sink { route in
            switch route {
            case .editMenu(let viewModel):
                menuViewModel = viewModel
            case .dismiss:
                dismissed.fulfill()
            default:
                break
            }
        }.store(in: &cancellables)
        viewModel.input.didTapMenu.send(())
        let unwrappedMenuViewModel = try XCTUnwrap(menuViewModel)
        try registerMenuExtraction(on: unwrappedMenuViewModel)
        unwrappedMenuViewModel.output.finishInputMenu.send([UserStoreMenuRequestV3(name: "팥붕", category: "BUNGEOPPANG")])

        // When
        viewModel.input.didTapEdit.send(())

        // Then
        wait(for: [dismissed], timeout: 2)
        XCTAssertEqual(repository.uploadPhotosArguments.count, 1)
        XCTAssertEqual(repository.uploadPhotosArguments.first?.storeId, 1)
        XCTAssertEqual(repository.uploadPhotosArguments.first?.photos, [menuImage])
    }

    func test_TH1542_TC4_AI메뉴판없이메뉴만수정하면_가게사진을업로드하지않는다() throws {
        // Given
        let store = try makeUserStore(storeId: 1)
        let repository = MockStoreRepository()
        repository.patchStoreResult = .success(store)
        let viewModel = EditStoreViewModel(
            config: EditStoreViewModelConfig(store: store, fromScreen: nil),
            dependency: .init(storeRepository: repository, logManager: MockLogManager())
        )
        let dismissed = expectation(description: "dismiss")
        var menuViewModel: WriteDetailMenuViewModel?
        viewModel.output.route.sink { route in
            switch route {
            case .editMenu(let viewModel):
                menuViewModel = viewModel
            case .dismiss:
                dismissed.fulfill()
            default:
                break
            }
        }.store(in: &cancellables)
        viewModel.input.didTapMenu.send(())
        try XCTUnwrap(menuViewModel).output.finishInputMenu.send([UserStoreMenuRequestV3(name: "팥붕", category: "BUNGEOPPANG")])

        // When
        viewModel.input.didTapEdit.send(())

        // Then
        wait(for: [dismissed], timeout: 2)
        XCTAssertTrue(repository.uploadPhotosArguments.isEmpty)
    }

    func test_TH1542_TC5_수정API가실패하면_메뉴판사진을업로드하지않는다() throws {
        // Given
        let repository = MockStoreRepository()
        let viewModel = EditStoreViewModel(
            config: EditStoreViewModelConfig(store: try makeUserStore(storeId: 1), fromScreen: nil),
            dependency: .init(storeRepository: repository, logManager: MockLogManager())
        )
        let errorShown = expectation(description: "error alert")
        var menuViewModel: WriteDetailMenuViewModel?
        viewModel.output.route.sink { route in
            switch route {
            case .editMenu(let viewModel):
                menuViewModel = viewModel
            case .showErrorAlert:
                errorShown.fulfill()
            default:
                break
            }
        }.store(in: &cancellables)
        viewModel.input.didTapMenu.send(())
        let unwrappedMenuViewModel = try XCTUnwrap(menuViewModel)
        try registerMenuExtraction(on: unwrappedMenuViewModel)
        unwrappedMenuViewModel.output.finishInputMenu.send([UserStoreMenuRequestV3(name: "팥붕", category: "BUNGEOPPANG")])

        // When
        viewModel.input.didTapEdit.send(())

        // Then
        wait(for: [errorShown], timeout: 2)
        XCTAssertTrue(repository.uploadPhotosArguments.isEmpty)
    }

    // MARK: TH-1542 TC6, TC7

    func test_TH1542_TC6_제보완료후메뉴추가에서AI메뉴판을등록하고저장이성공하면_메뉴판사진이가게사진으로한번업로드된다() throws {
        // Given
        let store = try makeUserStore(storeId: 5)
        let repository = MockStoreRepository()
        repository.patchStoreResult = .success(store)
        repository.uploadPhotosResult = .success([])
        let viewModel = WriteCompleteViewModel(
            config: .init(userStoreResponse: store, menuExtractionUsage: MenuExtractionUsage()),
            dependency: .init(storeRepository: repository, logManager: MockLogManager())
        )
        let updated = expectation(description: "store updated")
        viewModel.output.userStoreResponse.dropFirst().sink { _ in updated.fulfill() }.store(in: &cancellables)
        var menuViewModel: WriteDetailMenuViewModel?
        viewModel.output.route.sink { route in
            if case .pushWriteDetailMenu(let viewModel) = route { menuViewModel = viewModel }
        }.store(in: &cancellables)
        viewModel.input.didTapAddMenu.send(())
        let unwrappedMenuViewModel = try XCTUnwrap(menuViewModel)
        try registerMenuExtraction(on: unwrappedMenuViewModel)

        // When
        unwrappedMenuViewModel.output.finishInputMenu.send([UserStoreMenuRequestV3(name: "팥붕", category: "BUNGEOPPANG")])

        // Then
        wait(for: [updated], timeout: 2)
        XCTAssertEqual(repository.uploadPhotosArguments.count, 1)
        XCTAssertEqual(repository.uploadPhotosArguments.first?.storeId, 5)
        XCTAssertEqual(repository.uploadPhotosArguments.first?.photos, [menuImage])
    }

    func test_TH1542_TC7_업로드한메뉴판사진은_같은흐름에서다시업로드되지않는다() {
        // Given
        let usage = MenuExtractionUsage()
        usage.registerMenuImage(menuImage)

        // When
        let first = usage.consumeMenuImage()
        let second = usage.consumeMenuImage()

        // Then
        XCTAssertEqual(first, menuImage)
        XCTAssertNil(second)
    }

    private func registerMenuExtraction(on viewModel: WriteDetailMenuViewModel) throws {
        var loadingViewModel: MenuExtractionLoadingViewModel?
        let subscription = viewModel.output.route.sink { route in
            if case .pushMenuExtractionLoading(let viewModel) = route { loadingViewModel = viewModel }
        }
        viewModel.input.didSelectMenuImage.send(menuImage)
        subscription.cancel()
        try XCTUnwrap(loadingViewModel).output.finishExtraction.send(try makeExtractionResult())
    }

    private func registerMenuExtraction(on viewModel: WriteDetailCategoryViewModel) throws {
        var loadingViewModel: MenuExtractionLoadingViewModel?
        let subscription = viewModel.output.route.sink { route in
            if case .pushMenuExtractionLoading(let viewModel) = route { loadingViewModel = viewModel }
        }
        viewModel.input.didSelectMenuImage.send(menuImage)
        subscription.cancel()
        try XCTUnwrap(loadingViewModel).output.finishExtraction.send(try makeExtractionResult())
    }

    private func makeExtractionResult() throws -> MenuExtractionResult {
        let response = try FixtureLoader.decode(StoreMenuExtractionListResponse.self, from: "StoreMenuExtractionList")
        return MenuExtractionResult(response: response)
    }

    private func makeNonce() throws -> NonceResponse {
        return try JSONDecoder().decode(NonceResponse.self, from: Data(#"{"nonce":"nonce"}"#.utf8))
    }

    private func makeUserStore(storeId: Int) throws -> UserStoreResponse {
        let json = """
        {
            "storeId": \(storeId),
            "isOwner": false,
            "name": "가게",
            "rating": 0,
            "location": { "latitude": 37.5, "longitude": 127.0 },
            "address": { "fullAddress": "서울" },
            "categories": [],
            "appearanceDays": [],
            "paymentMethods": [],
            "menus": [],
            "menusV3": [],
            "isDeleted": false,
            "activitiesStatus": "RECENT_ACTIVITY",
            "createdAt": "",
            "updatedAt": ""
        }
        """
        return try JSONDecoder().decode(UserStoreResponse.self, from: Data(json.utf8))
    }
}
