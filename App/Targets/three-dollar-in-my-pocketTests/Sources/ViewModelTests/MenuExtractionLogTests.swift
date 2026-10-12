import Combine
import XCTest

import Log
import Model
@testable import Write

final class MenuExtractionLogTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1453 TC30

    func test_TH1453_TC30_사진선택다이얼로그가열리면_photo_popup화면으로page_view가전송된다() {
        // Given
        let viewModel = MenuPhotoSelectViewModel(dependency: .init(logManager: MockLogManager()))

        // When
        let viewController = MenuPhotoSelectViewController(viewModel: viewModel, onTapAlbum: { }, onTapCamera: { })

        // Then
        XCTAssertEqual(viewController.screenName.rawValue, "write_detail_menu_photo_popup")
    }

    // MARK: TH-1453 TC31

    func test_TH1453_TC31_사진에서선택을누르면_select_photo클릭로그가전송되고_앨범으로이동한다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = MenuPhotoSelectViewModel(dependency: .init(logManager: logManager))
        var routes: [MenuPhotoSelectViewModel.Route] = []
        viewModel.output.route.sink { routes.append($0) }.store(in: &cancellables)

        // When
        viewModel.input.didTapAlbum.send(())

        // Then
        let event = try XCTUnwrap(logManager.sentEvents.last)
        XCTAssertEqual(logManager.sentEvents.count, 1)
        XCTAssertEqual(event.parameters["screen"] as? String, "write_detail_menu_photo_popup")
        XCTAssertEqual(event.parameters["object_type"] as? String, "button")
        XCTAssertEqual(event.parameters["object_id"] as? String, "select_photo")
        guard case .album = routes.last else {
            return XCTFail("album route 가 발행되지 않았습니다")
        }
    }

    func test_TH1453_TC31_사진찍기를누르면_take_photo클릭로그가전송되고_카메라로이동한다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = MenuPhotoSelectViewModel(dependency: .init(logManager: logManager))
        var routes: [MenuPhotoSelectViewModel.Route] = []
        viewModel.output.route.sink { routes.append($0) }.store(in: &cancellables)

        // When
        viewModel.input.didTapCamera.send(())

        // Then
        let event = try XCTUnwrap(logManager.sentEvents.last)
        XCTAssertEqual(logManager.sentEvents.count, 1)
        XCTAssertEqual(event.parameters["screen"] as? String, "write_detail_menu_photo_popup")
        XCTAssertEqual(event.parameters["object_id"] as? String, "take_photo")
        guard case .camera = routes.last else {
            return XCTFail("camera route 가 발행되지 않았습니다")
        }
    }

    // MARK: TH-1453 TC32

    func test_TH1453_TC32_인식결과화면에진입하면_extraction_result화면으로page_view가전송된다() {
        // Given
        let result = MenuExtractionResult(categories: [], menus: [], recognizedMenuCount: 0)
        let viewModel = MenuExtractionResultViewModel(config: .init(result: result, afterCreatedStore: false))

        // When
        let viewController = MenuExtractionResultViewController(viewModel: viewModel)

        // Then
        XCTAssertEqual(viewController.screenName.rawValue, "write_detail_menu_extraction_result")
    }

    // MARK: TH-1453 TC33

    func test_TH1453_TC33_메뉴상세정보추가화면은_기존write_detail_menu로page_view가전송된다() {
        // Given
        let viewModel = WriteDetailMenuViewModel(
            config: .init(
                selectedCategories: [],
                menus: [],
                afterCreatedStore: true,
                menuExtractionUsage: MenuExtractionUsage()
            ),
            dependencies: .init(categoryRepository: MockCategoryRepository(), logManager: MockLogManager())
        )

        // When
        let viewController = WriteDetailMenuViewController(viewModel: viewModel)

        // Then
        XCTAssertEqual(viewController.screenName.rawValue, "write_detail_menu")
    }
}
