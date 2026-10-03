import Combine
import XCTest

import Common
import Log
import Model
@testable import Write
import WriteInterface

final class MenuExtractionViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1332 TC7

    func test_TH1332_TC7_인식에성공하면_인식된메뉴수와_카테고리별탭이노출된다() throws {
        // Given
        let response = try fixture()

        // When
        let viewModel = MenuExtractionResultViewModel(config: .init(result: MenuExtractionResult(response: response), afterCreatedStore: false))

        // Then
        XCTAssertEqual(viewModel.output.recognizedMenuCount, 23)
        XCTAssertEqual(Set(viewModel.output.categories.value.map(\.categoryId)), ["CAFE", "TOAST", "ETC"])
        XCTAssertEqual(viewModel.output.categories.value.first?.categoryId, response.menus.first?.category.categoryId)
    }

    // MARK: TH-1332 TC8

    func test_TH1332_TC8_다른카테고리탭을선택하면_해당카테고리메뉴가인식값으로채워진다() throws {
        // Given
        let response = try fixture()
        let viewModel = MenuExtractionResultViewModel(config: .init(result: MenuExtractionResult(response: response), afterCreatedStore: false))
        let toastIndex = try XCTUnwrap(viewModel.output.categories.value.firstIndex { $0.categoryId == "TOAST" })
        var menus: [MenuInputViewModel] = []
        viewModel.output.menus.sink { menus = $0 }.store(in: &cancellables)

        // When
        viewModel.input.selectCategory.send(toastIndex)

        // Then
        let expected = response.menus.filter { $0.category.categoryId == "TOAST" }
        XCTAssertEqual(menus.map { $0.output.name.value }, expected.map(\.name))
        XCTAssertEqual(menus.map { $0.output.price.value }, expected.map(\.price))
    }

    // MARK: TH-1332 TC9

    func test_TH1332_TC9_수량이인식되지않은메뉴는_수량이빈값으로노출된다() throws {
        // Given
        let viewModel = MenuExtractionResultViewModel(config: .init(result: MenuExtractionResult(response: try fixture()), afterCreatedStore: false))
        var menus: [MenuInputViewModel] = []
        viewModel.output.menus.sink { menus = $0 }.store(in: &cancellables)

        // When
        viewModel.input.viewDidLoad.send(())

        // Then
        let first = try XCTUnwrap(menus.first)
        XCTAssertNil(first.output.quantity.value)
        XCTAssertEqual(first.output.name.value, "아메리카노")
        XCTAssertEqual(first.output.price.value, 4000)
    }

    // MARK: TH-1332 TC10

    func test_TH1332_TC10_메뉴삭제와메뉴추가를누르면_메뉴가사라지고빈메뉴가추가된다() throws {
        // Given
        let viewModel = MenuExtractionResultViewModel(config: .init(result: MenuExtractionResult(response: try fixture()), afterCreatedStore: false))
        var menus: [MenuInputViewModel] = []
        var addedMenu: MenuInputViewModel?
        viewModel.output.menus.sink { menus = $0 }.store(in: &cancellables)
        viewModel.output.addMenus.sink { addedMenu = $0 }.store(in: &cancellables)
        viewModel.input.viewDidLoad.send(())
        let originalCount = menus.count
        let secondName = menus[safe: 1]?.output.name.value

        // When
        menus.first?.input.didTapDelete.send(())

        // Then
        XCTAssertEqual(menus.count, originalCount - 1)
        XCTAssertEqual(menus.first?.output.name.value, secondName)

        // When
        viewModel.input.didTapAddMenu.send(())

        // Then
        XCTAssertEqual(addedMenu?.output.name.value, "")
        XCTAssertEqual(addedMenu?.output.index, originalCount - 1)
    }

    // MARK: TH-1332 TC11

    func test_TH1332_TC11_가격을0으로입력하고등록하면_최소가격토스트가뜨고진행되지않는다() throws {
        // Given
        let viewModel = MenuExtractionResultViewModel(config: .init(result: MenuExtractionResult(response: try fixture()), afterCreatedStore: false))
        var menus: [MenuInputViewModel] = []
        var toasts: [String] = []
        var isFinished = false
        viewModel.output.menus.sink { menus = $0 }.store(in: &cancellables)
        viewModel.output.toast.sink { toasts.append($0) }.store(in: &cancellables)
        viewModel.output.finishRegister.sink { _ in isFinished = true }.store(in: &cancellables)
        viewModel.input.viewDidLoad.send(())

        // When
        menus.first?.input.inputPrice.send("0")
        viewModel.input.didTapRegister.send(())

        // Then
        XCTAssertEqual(toasts, [Strings.WriteDetailMenu.Toast.validatePrice])
        XCTAssertFalse(isFinished)
    }

    // MARK: TH-1332 TC12

    func test_TH1332_TC12_카테고리선택화면에서인식결과를등록하면_제보흐름으로결과가전달된다() throws {
        // Given
        let viewModel = WriteDetailCategoryViewModel(
            config: .init(menuExtractionUsage: MenuExtractionUsage()),
            dependency: .init(categoryRepository: MockCategoryRepository(), logManager: MockLogManager())
        )
        var loadingViewModel: MenuExtractionLoadingViewModel?
        var finishedResult: MenuExtractionResult?
        viewModel.output.route
            .sink {
                if case .pushMenuExtractionLoading(let loading) = $0 { loadingViewModel = loading }
            }
            .store(in: &cancellables)
        viewModel.output.finishMenuExtraction.sink { finishedResult = $0 }.store(in: &cancellables)
        viewModel.input.didSelectMenuImage.send(Data([0x01]))
        let result = MenuExtractionResult(response: try fixture())

        // When
        loadingViewModel?.output.finishExtraction.send(result)

        // Then
        XCTAssertNotNil(loadingViewModel)
        XCTAssertEqual(finishedResult?.menus.count, result.menus.count)
    }

    // MARK: TH-1332 TC19~TC23 (TH-1439)

    func test_TH1332_TC19_결과화면에서등록하면_기존메뉴는유지되고인식메뉴가추가된다() throws {
        // Given
        let response = try fixture()
        let existingCategory = try XCTUnwrap(response.menus.last?.category)
        let viewModel = makeWriteDetailMenuViewModel(
            categories: [existingCategory],
            menus: [UserStoreMenuRequestV3(name: "기존 메뉴", price: 1000, category: existingCategory.categoryId)]
        )
        var routes: [WriteDetailMenuViewModel.Route] = []
        var finishedMenus: [UserStoreMenuRequestV3] = []
        viewModel.output.route.sink { routes.append($0) }.store(in: &cancellables)
        viewModel.output.finishInputMenu.sink { finishedMenus = $0 }.store(in: &cancellables)
        let result = MenuExtractionResult(response: response)

        // When
        viewModel.input.finishMenuExtraction.send(result)
        viewModel.input.didTapNext.send(())

        // Then
        XCTAssertEqual(viewModel.output.categories.value.first?.categoryId, existingCategory.categoryId)
        XCTAssertEqual(Set(viewModel.output.categories.value.map(\.categoryId)), Set(result.categories.map(\.categoryId)))
        XCTAssertTrue(finishedMenus.contains { $0.name == "기존 메뉴" && $0.price == 1000 })
        XCTAssertEqual(finishedMenus.count, result.menus.count + 1)
        guard case .popToSelf = routes.first(where: { if case .popToSelf = $0 { return true } else { return false } }) else {
            return XCTFail("popToSelf route 가 발행되지 않았습니다")
        }
    }

    func test_TH1332_TC20_이름이같은메뉴가인식되면_수량과가격만갱신된다() throws {
        // Given
        let response = try fixture()
        let americano = try XCTUnwrap(response.menus.first)
        let viewModel = makeWriteDetailMenuViewModel(
            categories: [americano.category],
            menus: [UserStoreMenuRequestV3(name: "아메 리카노", count: 2, price: 3500, category: americano.category.categoryId)]
        )
        var finishedMenus: [UserStoreMenuRequestV3] = []
        viewModel.output.finishInputMenu.sink { finishedMenus = $0 }.store(in: &cancellables)

        // When
        viewModel.input.finishMenuExtraction.send(MenuExtractionResult(response: response))
        viewModel.input.didTapNext.send(())

        // Then
        let matched = finishedMenus.filter { $0.name.replacingOccurrences(of: " ", with: "") == "아메리카노" }
        XCTAssertEqual(matched.count, 1)
        XCTAssertEqual(matched.first?.price, americano.price)
        XCTAssertEqual(matched.first?.count, 2)
    }

    func test_TH1332_TC21_빈메뉴입력칸은_인식메뉴가들어오면정리된다() throws {
        // Given
        let response = try fixture()
        let category = try XCTUnwrap(response.menus.first?.category)
        let viewModel = makeWriteDetailMenuViewModel(
            categories: [category],
            menus: [UserStoreMenuRequestV3(category: category.categoryId)]
        )
        var finishedMenus: [UserStoreMenuRequestV3] = []
        viewModel.output.finishInputMenu.sink { finishedMenus = $0 }.store(in: &cancellables)

        // When
        viewModel.input.finishMenuExtraction.send(MenuExtractionResult(response: response))
        viewModel.input.didTapNext.send(())

        // Then
        XCTAssertFalse(finishedMenus.contains { $0.name.isEmpty })
    }

    func test_TH1332_TC22_기존카테고리와합쳐도_카테고리는최대10개다() throws {
        // Given
        let response = try fixture()
        let existingCategories = try (0..<9).map { try makeCategory(id: "EXISTING_\($0)") }
        let viewModel = makeWriteDetailMenuViewModel(categories: existingCategories, menus: [])

        // When
        viewModel.input.finishMenuExtraction.send(MenuExtractionResult(response: response))

        // Then
        XCTAssertEqual(viewModel.output.categories.value.count, 10)
        XCTAssertEqual(Array(viewModel.output.categories.value.prefix(9).map(\.categoryId)), existingCategories.map(\.categoryId))
    }

    func test_TH1332_TC23_카테고리선택화면에서인식결과를등록하면_선택한카테고리와합쳐져전달된다() throws {
        // Given
        let viewModel = WriteDetailCategoryViewModel(
            config: .init(menuExtractionUsage: MenuExtractionUsage()),
            dependency: .init(categoryRepository: MockCategoryRepository(), logManager: MockLogManager())
        )
        let selectedCategory = try makeCategory(id: "SELECTED")
        var loadingViewModel: MenuExtractionLoadingViewModel?
        var finishedResult: MenuExtractionResult?
        viewModel.output.route
            .sink {
                if case .pushMenuExtractionLoading(let loading) = $0 { loadingViewModel = loading }
            }
            .store(in: &cancellables)
        viewModel.output.finishMenuExtraction.sink { finishedResult = $0 }.store(in: &cancellables)
        viewModel.input.selectCategory.send(selectedCategory)
        viewModel.input.didSelectMenuImage.send(Data([0x01]))
        let result = MenuExtractionResult(response: try fixture())

        // When
        loadingViewModel?.output.finishExtraction.send(result)

        // Then
        XCTAssertEqual(finishedResult?.categories.first?.categoryId, "SELECTED")
        XCTAssertEqual(finishedResult?.categories.count, result.categories.count + 1)
        XCTAssertEqual(finishedResult?.menus.count, result.menus.count)
    }

    // MARK: TH-1332 TC13

    func test_TH1332_TC13_가게정보수정흐름에서인식결과를등록하고완료하면_인식된메뉴로수정정보가갱신된다() throws {
        // Given
        let viewModel = WriteDetailMenuViewModel(
            config: .init(selectedCategories: [], menus: [], afterCreatedStore: true, menuExtractionUsage: MenuExtractionUsage()),
            dependencies: .init(categoryRepository: MockCategoryRepository(), logManager: MockLogManager())
        )
        var finishedMenus: [UserStoreMenuRequestV3] = []
        var finishedCategories: [StoreFoodCategoryResponse] = []
        var routes: [WriteDetailMenuViewModel.Route] = []
        viewModel.output.finishInputMenu.sink { finishedMenus = $0 }.store(in: &cancellables)
        viewModel.output.finishInputCategory.sink { finishedCategories = $0 }.store(in: &cancellables)
        viewModel.output.route.sink { routes.append($0) }.store(in: &cancellables)
        let result = MenuExtractionResult(response: try fixture())
        viewModel.input.finishMenuExtraction.send(result)

        // When
        viewModel.input.didTapNext.send(())

        // Then
        XCTAssertEqual(finishedMenus.count, 23)
        XCTAssertEqual(finishedCategories.map(\.categoryId), result.categories.map(\.categoryId))
        guard case .pop = routes.last else {
            return XCTFail("pop route 가 발행되지 않았습니다")
        }
    }

    // MARK: TH-1332 TC15

    func test_TH1332_TC15_AI를쓰지않고메뉴를직접입력하면_기존처럼메뉴가전달되고다음클릭로그가전송된다() throws {
        // Given
        let category = try XCTUnwrap(try fixture().menus.first?.category)
        let logManager = MockLogManager()
        let viewModel = WriteDetailMenuViewModel(
            config: .init(
                selectedCategories: [category],
                menus: [UserStoreMenuRequestV3(category: category.categoryId)],
                afterCreatedStore: false,
                menuExtractionUsage: MenuExtractionUsage()
            ),
            dependencies: .init(categoryRepository: MockCategoryRepository(), logManager: logManager)
        )
        var menus: [MenuInputViewModel] = []
        var finishedMenus: [UserStoreMenuRequestV3] = []
        viewModel.output.menus.sink { menus = $0 }.store(in: &cancellables)
        viewModel.output.finishInputMenu.sink { finishedMenus = $0 }.store(in: &cancellables)
        viewModel.input.viewDidLoad.send(())

        // When
        menus.first?.input.inputName.send("슈크림 붕어빵")
        menus.first?.input.inputQuantity.send("2")
        menus.first?.input.inputPrice.send("1,000")
        viewModel.input.didTapNext.send(())

        // Then
        XCTAssertEqual(finishedMenus.count, 1)
        XCTAssertEqual(finishedMenus.first?.name, "슈크림 붕어빵")
        XCTAssertEqual(finishedMenus.first?.count, 2)
        XCTAssertEqual(finishedMenus.first?.price, 1000)
        XCTAssertEqual(logManager.sentEvents.last?.parameters["object_id"] as? String, "next")
    }

    // MARK: TH-1332 TC17, TC18

    func test_TH1332_TC17_TC18_인식요청이실패하면_에러알럿route가발행된다() {
        // Given
        let error = NetworkError.errorContainer(ErrorContainer(message: "메뉴를 찾지 못했어요", resultCode: "BR000"))
        let viewModel = MenuExtractionLoadingViewModel(
            config: .init(image: Data([0x01]), afterCreatedStore: false, menuExtractionUsage: MenuExtractionUsage()),
            dependency: .init(storeMenuExtractionRepository: MockStoreMenuExtractionRepository(extractStoreMenusResult: .failure(error)))
        )
        let expectation = expectation(description: "route")
        var receivedMessage: String?
        viewModel.output.route
            .sink {
                if case .showErrorAlert(let error) = $0,
                   case .errorContainer(let container) = error as? NetworkError {
                    receivedMessage = container.message
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.viewDidLoad.send(())

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(receivedMessage, "메뉴를 찾지 못했어요")
    }

    func test_TH1332_TC17_TC18_인식된메뉴가없으면_에러알럿route가발행된다() throws {
        // Given
        let emptyResponse = try decode(json: #"{"imageUrl": "https://example.com", "menus": []}"#)
        let viewModel = MenuExtractionLoadingViewModel(
            config: .init(image: Data([0x01]), afterCreatedStore: false, menuExtractionUsage: MenuExtractionUsage()),
            dependency: .init(storeMenuExtractionRepository: MockStoreMenuExtractionRepository(extractStoreMenusResult: .success(emptyResponse)))
        )
        let expectation = expectation(description: "route")
        viewModel.output.route
            .sink {
                if case .showErrorAlert = $0 { expectation.fulfill() }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.viewDidLoad.send(())

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func test_TH1332_TC7_인식에성공하면_결과화면으로교체route가발행된다() throws {
        // Given
        let viewModel = MenuExtractionLoadingViewModel(
            config: .init(image: Data([0x01]), afterCreatedStore: false, menuExtractionUsage: MenuExtractionUsage()),
            dependency: .init(storeMenuExtractionRepository: MockStoreMenuExtractionRepository(extractStoreMenusResult: .success(try fixture())))
        )
        let expectation = expectation(description: "route")
        var resultViewModel: MenuExtractionResultViewModel?
        viewModel.output.route
            .sink {
                if case .replaceWithResult(let result) = $0 {
                    resultViewModel = result
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.viewDidLoad.send(())

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultViewModel?.output.recognizedMenuCount, 23)
    }

    func test_TH1332_인식된카테고리가10개를넘으면_10개까지만반영된다() throws {
        // Given
        let data = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "StoreMenuExtractionList", withExtension: "json"))
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: data)) as? [String: Any])
        var menus = try XCTUnwrap(json["menus"] as? [[String: Any]])
        for index in menus.indices {
            var category = try XCTUnwrap(menus[index]["category"] as? [String: Any])
            category["categoryId"] = "CATEGORY_\(index)"
            menus[index]["category"] = category
        }
        json["menus"] = menus
        let response = try JSONDecoder().decode(
            StoreMenuExtractionListResponse.self,
            from: JSONSerialization.data(withJSONObject: json)
        )

        // When
        let result = MenuExtractionResult(response: response)

        // Then
        XCTAssertEqual(result.categories.count, 10)
        XCTAssertEqual(result.menus.count, 10)
        XCTAssertEqual(result.recognizedMenuCount, 23)
    }

    // MARK: TH-1332 TC26

    func test_TH1332_TC26_인식결과를받으면_같은흐름의카테고리와메뉴화면에서이미지로불러오기가숨겨진다() throws {
        // Given
        let usage = MenuExtractionUsage()
        let categoryViewModel = WriteDetailCategoryViewModel(
            config: .init(menuExtractionUsage: usage),
            dependency: .init(categoryRepository: MockCategoryRepository(), logManager: MockLogManager())
        )
        let menuViewModel = makeWriteDetailMenuViewModel(categories: [], menus: [], menuExtractionUsage: usage)
        let loadingViewModel = MenuExtractionLoadingViewModel(
            config: .init(image: Data([0x01]), afterCreatedStore: false, menuExtractionUsage: usage),
            dependency: .init(storeMenuExtractionRepository: MockStoreMenuExtractionRepository(extractStoreMenusResult: .success(try fixture())))
        )
        let expectation = expectation(description: "route")
        loadingViewModel.output.route
            .sink {
                if case .replaceWithResult = $0 { expectation.fulfill() }
            }
            .store(in: &cancellables)
        XCTAssertTrue(categoryViewModel.output.isMenuExtractionAvailable.value)
        XCTAssertTrue(menuViewModel.output.isMenuExtractionAvailable.value)

        // When
        loadingViewModel.input.viewDidLoad.send(())

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(categoryViewModel.output.isMenuExtractionAvailable.value)
        XCTAssertFalse(menuViewModel.output.isMenuExtractionAvailable.value)
    }

    // MARK: TH-1332 TC27

    func test_TH1332_TC27_인식요청이실패하면_이미지로불러오기를다시사용할수있다() {
        // Given
        let usage = MenuExtractionUsage()
        let error = NetworkError.errorContainer(ErrorContainer(message: "실패", resultCode: "BR000"))
        let viewModel = MenuExtractionLoadingViewModel(
            config: .init(image: Data([0x01]), afterCreatedStore: false, menuExtractionUsage: usage),
            dependency: .init(storeMenuExtractionRepository: MockStoreMenuExtractionRepository(extractStoreMenusResult: .failure(error)))
        )
        let expectation = expectation(description: "route")
        viewModel.output.route
            .sink {
                if case .showErrorAlert = $0 { expectation.fulfill() }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.viewDidLoad.send(())

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(usage.isAvailable.value)
    }

    func test_TH1332_TC27_인식된메뉴가없으면_이미지로불러오기를다시사용할수있다() throws {
        // Given
        let usage = MenuExtractionUsage()
        let emptyResponse = try decode(json: #"{"imageUrl": "https://example.com", "menus": []}"#)
        let viewModel = MenuExtractionLoadingViewModel(
            config: .init(image: Data([0x01]), afterCreatedStore: false, menuExtractionUsage: usage),
            dependency: .init(storeMenuExtractionRepository: MockStoreMenuExtractionRepository(extractStoreMenusResult: .success(emptyResponse)))
        )
        let expectation = expectation(description: "route")
        viewModel.output.route
            .sink {
                if case .showErrorAlert = $0 { expectation.fulfill() }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.viewDidLoad.send(())

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(usage.isAvailable.value)
    }

    // MARK: TH-1332 TC28

    func test_TH1332_TC28_수정화면에서사용한뒤_메뉴수정에다시들어가면숨겨지고_수정화면에새로진입하면다시보인다() throws {
        // Given
        let store = try makeUserStore()
        let firstEditViewModel = makeEditStoreViewModel(store: store)
        var menuViewModels: [WriteDetailMenuViewModel] = []
        firstEditViewModel.output.route
            .sink {
                if case .editMenu(let viewModel) = $0 { menuViewModels.append(viewModel) }
            }
            .store(in: &cancellables)
        firstEditViewModel.input.didTapMenu.send(())
        let firstMenuViewModel = try XCTUnwrap(menuViewModels.first)
        firstMenuViewModel.output.isMenuExtractionAvailable.send(false)

        // When
        firstEditViewModel.input.didTapMenu.send(())
        let secondEditViewModel = makeEditStoreViewModel(store: store)
        var newFlowMenuViewModel: WriteDetailMenuViewModel?
        secondEditViewModel.output.route
            .sink {
                if case .editMenu(let viewModel) = $0 { newFlowMenuViewModel = viewModel }
            }
            .store(in: &cancellables)
        secondEditViewModel.input.didTapMenu.send(())

        // Then
        XCTAssertEqual(menuViewModels.count, 2)
        XCTAssertFalse(menuViewModels[1].output.isMenuExtractionAvailable.value)
        XCTAssertTrue(try XCTUnwrap(newFlowMenuViewModel).output.isMenuExtractionAvailable.value)
    }

    // MARK: - Helpers

    private func makeWriteDetailMenuViewModel(
        categories: [StoreFoodCategoryResponse],
        menus: [UserStoreMenuRequestV3],
        menuExtractionUsage: MenuExtractionUsage = MenuExtractionUsage()
    ) -> WriteDetailMenuViewModel {
        WriteDetailMenuViewModel(
            config: .init(
                selectedCategories: categories,
                menus: menus,
                afterCreatedStore: false,
                menuExtractionUsage: menuExtractionUsage
            ),
            dependencies: .init(categoryRepository: MockCategoryRepository(), logManager: MockLogManager())
        )
    }

    private func makeEditStoreViewModel(store: UserStoreResponse) -> EditStoreViewModel {
        EditStoreViewModel(
            config: EditStoreViewModelConfig(store: store, fromScreen: nil),
            dependency: .init(storeRepository: MockStoreRepository(), logManager: MockLogManager())
        )
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

    private func makeCategory(id: String) throws -> StoreFoodCategoryResponse {
        let json = """
        {
            "categoryId": "\(id)",
            "name": "\(id)",
            "imageUrl": "",
            "description": "",
            "classification": { "type": "SNACK", "description": "", "priority": 1 },
            "isNew": false
        }
        """
        return try JSONDecoder().decode(StoreFoodCategoryResponse.self, from: Data(json.utf8))
    }

    private func fixture() throws -> StoreMenuExtractionListResponse {
        try FixtureLoader.decode(StoreMenuExtractionListResponse.self, from: "StoreMenuExtractionList")
    }

    private func decode(json: String) throws -> StoreMenuExtractionListResponse {
        try JSONDecoder().decode(StoreMenuExtractionListResponse.self, from: XCTUnwrap(json.data(using: .utf8)))
    }
}
