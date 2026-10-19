import Combine
import XCTest

import Log
import Model
import WriteInterface
@testable import Write

final class MenuExtractionCompleteLogTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1485 TC1, TC2

    func test_TH1485_TC1_인식결과를받은흐름에서제보가완료되면_write_detail_complete페이지뷰에menu_extraction_used가true로실린다() throws {
        // Given
        let usage = MenuExtractionUsage()
        usage.markUsed()
        let viewModel = WriteCompleteViewModel(config: .init(userStoreResponse: try makeUserStore(), menuExtractionUsage: usage))

        // When
        let viewController = WriteCompleteViewController(viewModel: viewModel)

        // Then
        XCTAssertEqual(viewController.screenName.rawValue, "write_detail_complete")
        XCTAssertEqual(viewController.extraParameters?[.menuExtractionUsed] as? String, "true")
    }

    func test_TH1485_TC2_AI를쓰지않고제보가완료되면_write_detail_complete페이지뷰에menu_extraction_used가false로실린다() throws {
        // Given
        let viewModel = WriteCompleteViewModel(config: .init(userStoreResponse: try makeUserStore(), menuExtractionUsage: MenuExtractionUsage()))

        // When
        let viewController = WriteCompleteViewController(viewModel: viewModel)

        // Then
        XCTAssertEqual(viewController.extraParameters?[.menuExtractionUsed] as? String, "false")
    }

    // MARK: TH-1485 TC3, TC4

    func test_TH1485_TC3_수정화면에서AI로메뉴를등록하고완료해수정이성공하면_edit_store_complete가한건전송된다() throws {
        // Given
        let store = try makeUserStore()
        let logManager = MockLogManager()
        let repository = MockStoreRepository()
        repository.patchStoreResult = .success(store)
        let viewModel = EditStoreViewModel(
            config: EditStoreViewModelConfig(store: store, fromScreen: nil),
            dependency: .init(storeRepository: repository, logManager: logManager)
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
        unwrappedMenuViewModel.output.isMenuExtractionAvailable.send(false)
        unwrappedMenuViewModel.output.finishInputMenu.send([UserStoreMenuRequestV3(name: "팥붕", category: "BUNGEOPPANG")])

        // When
        viewModel.input.didTapEdit.send(())

        // Then
        wait(for: [dismissed], timeout: 2)
        let events = logManager.sentEvents.filter { $0.name == .editStoreComplete }
        XCTAssertEqual(events.count, 1)
        let event = try XCTUnwrap(events.first)
        XCTAssertEqual(event.parameters["screen"] as? String, "edit_store")
        XCTAssertEqual(event.parameters["menu_extraction_used"] as? String, "true")
        XCTAssertEqual(event.parameters["edited_menu"] as? String, "true")
        XCTAssertEqual(event.parameters["flow"] as? String, "edit")
    }

    func test_TH1485_TC4_수정API가실패하면_edit_store_complete가전송되지않는다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = EditStoreViewModel(
            config: EditStoreViewModelConfig(store: try makeUserStore(), fromScreen: nil),
            dependency: .init(storeRepository: MockStoreRepository(), logManager: logManager)
        )
        let errorShown = expectation(description: "error alert")
        viewModel.output.route.sink { route in
            if case .showErrorAlert = route { errorShown.fulfill() }
        }.store(in: &cancellables)

        // When
        viewModel.input.didTapEdit.send(())

        // Then
        wait(for: [errorShown], timeout: 2)
        XCTAssertTrue(logManager.sentEvents.filter { $0.name == .editStoreComplete }.isEmpty)
        XCTAssertEqual(logManager.sentEvents.filter { $0.name == .click }.count, 1)
    }

    // MARK: TH-1485 TC5

    func test_TH1485_TC5_결과화면에서등록하면_register클릭이한건전송되고_인식메뉴수와최종메뉴수와flow가실린다() throws {
        // Given
        let logManager = MockLogManager()
        let response = try FixtureLoader.decode(StoreMenuExtractionListResponse.self, from: "StoreMenuExtractionList")
        let result = MenuExtractionResult(response: response)
        let viewModel = MenuExtractionResultViewModel(
            config: .init(result: result, afterCreatedStore: true, flow: .edit),
            dependency: .init(logManager: logManager)
        )
        var registered: MenuExtractionResult?
        viewModel.output.finishRegister.sink { registered = $0 }.store(in: &cancellables)

        // When
        viewModel.input.didTapRegister.send(())

        // Then
        let finalMenuCount = try XCTUnwrap(registered).menus.count
        XCTAssertEqual(logManager.sentEvents.count, 1)
        let event = try XCTUnwrap(logManager.sentEvents.first)
        XCTAssertEqual(event.parameters["screen"] as? String, "write_detail_menu_extraction_result")
        XCTAssertEqual(event.parameters["object_type"] as? String, "button")
        XCTAssertEqual(event.parameters["object_id"] as? String, "register")
        XCTAssertEqual(event.parameters["recognized_menu_count"] as? Int, response.menus.count)
        XCTAssertEqual(event.parameters["final_menu_count"] as? Int, finalMenuCount)
        XCTAssertEqual(event.parameters["flow"] as? String, "edit")
    }

    // MARK: TH-1485 TC6

    func test_TH1485_TC6_제보완료후메뉴추가에서AI사용후저장이성공하면_flow가after_create인edit_store_complete가전송된다() throws {
        // Given
        let store = try makeUserStore()
        let logManager = MockLogManager()
        let repository = MockStoreRepository()
        repository.patchStoreResult = .success(store)
        let usage = MenuExtractionUsage()
        let viewModel = WriteCompleteViewModel(
            config: .init(userStoreResponse: store, menuExtractionUsage: usage),
            dependency: .init(storeRepository: repository, logManager: logManager)
        )
        let updated = expectation(description: "store updated")
        viewModel.output.userStoreResponse.dropFirst().sink { _ in updated.fulfill() }.store(in: &cancellables)
        var menuViewModel: WriteDetailMenuViewModel?
        viewModel.output.route.sink { route in
            if case .pushWriteDetailMenu(let viewModel) = route { menuViewModel = viewModel }
        }.store(in: &cancellables)
        viewModel.input.didTapAddMenu.send(())
        usage.markUsed()

        // When
        try XCTUnwrap(menuViewModel).output.finishInputMenu.send([UserStoreMenuRequestV3(name: "팥붕", category: "BUNGEOPPANG")])

        // Then
        wait(for: [updated], timeout: 2)
        let events = logManager.sentEvents.filter { $0.name == .editStoreComplete }
        XCTAssertEqual(events.count, 1)
        let event = try XCTUnwrap(events.first)
        XCTAssertEqual(event.parameters["screen"] as? String, "edit_store")
        XCTAssertEqual(event.parameters["menu_extraction_used"] as? String, "true")
        XCTAssertEqual(event.parameters["edited_menu"] as? String, "true")
        XCTAssertEqual(event.parameters["flow"] as? String, "after_create")
    }

    func test_TH1485_TC6_제보완료후추가정보만저장하면_edit_store_complete가전송되지않는다() throws {
        // Given
        let store = try makeUserStore()
        let logManager = MockLogManager()
        let repository = MockStoreRepository()
        repository.patchStoreResult = .success(store)
        let viewModel = WriteCompleteViewModel(
            config: .init(userStoreResponse: store, menuExtractionUsage: MenuExtractionUsage()),
            dependency: .init(storeRepository: repository, logManager: logManager)
        )
        let updated = expectation(description: "store updated")
        viewModel.output.userStoreResponse.dropFirst().sink { _ in updated.fulfill() }.store(in: &cancellables)
        var additionalInfoViewModel: WriteDetailAdditionalInfoViewModel?
        viewModel.output.route.sink { route in
            if case .pushWriteDetailAdditionalInfo(let viewModel) = route { additionalInfoViewModel = viewModel }
        }.store(in: &cancellables)
        viewModel.input.didTapAddAdditionalInfo.send(())

        // When
        try XCTUnwrap(additionalInfoViewModel).output.finishWriteAdditionalInfo.send(([], [], nil, nil))

        // Then
        wait(for: [updated], timeout: 2)
        XCTAssertTrue(logManager.sentEvents.filter { $0.name == .editStoreComplete }.isEmpty)
    }

    private func makeUserStore() throws -> UserStoreResponse {
        let json = """
        {
            "storeId": 1,
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
