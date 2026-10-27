import Combine
import XCTest

import Log
import Model
@testable import MyPage

final class VisitStoreListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1538 TC1

    func test_TH1538_TC1_편집버튼을누르면_모든항목이편집상태가된다() throws {
        // Given
        let viewModel = try makeLoadedViewModel()
        var isEditing: Bool?
        viewModel.output.isEditing.sink { isEditing = $0 }.store(in: &cancellables)

        // When
        viewModel.input.didTapEdit.send(())

        // Then
        XCTAssertEqual(isEditing, true)
        XCTAssertTrue(editingStates(viewModel).allSatisfy { $0 })
        XCTAssertEqual(editingStates(viewModel).count, 3)
    }

    // MARK: TH-1538 TC2

    func test_TH1538_TC2_편집중에완료를누르면_일반모드로돌아온다() throws {
        // Given
        let viewModel = try makeLoadedViewModel()
        viewModel.input.didTapEdit.send(())

        // When
        viewModel.input.didTapEdit.send(())

        // Then
        XCTAssertEqual(viewModel.output.isEditing.value, false)
        XCTAssertTrue(editingStates(viewModel).allSatisfy { $0 == false })
    }

    // MARK: TH-1538 TC3

    func test_TH1538_TC3_삭제버튼을누르면_확인팝업Route가발행된다() throws {
        // Given
        let viewModel = try makeLoadedViewModel()
        viewModel.input.didTapEdit.send(())
        var alertVisitId: String?
        viewModel.output.route
            .sink { if case .presentDeleteAlert(let item) = $0 { alertVisitId = item.visitId } }
            .store(in: &cancellables)

        // When
        viewModel.input.didTapDelete.send(try XCTUnwrap(firstItem(viewModel)))

        // Then
        XCTAssertEqual(alertVisitId, "visit-1")
    }

    // MARK: TH-1538 TC4

    func test_TH1538_TC4_확인팝업만띄우고취소하면_삭제API와삭제로그가없다() throws {
        // Given
        let visitRepository = MockVisitRepository()
        let logManager = MockLogManager()
        let viewModel = try makeLoadedViewModel(visitRepository: visitRepository, logManager: logManager)

        // When
        viewModel.input.didTapDelete.send(try XCTUnwrap(firstItem(viewModel)))

        // Then
        XCTAssertTrue(visitRepository.deletedVisitIds.isEmpty)
        XCTAssertFalse(logManager.sentEvents.contains { ($0.parameters["object_id"] as? String) == "delete_visit" })
        XCTAssertEqual(editingStates(viewModel).count, 3)
    }

    // MARK: TH-1538 TC5

    func test_TH1538_TC5_삭제를확정하면_visitId로삭제하고항목을지우고서버메시지를토스트로띄운다() throws {
        // Given
        let visitRepository = MockVisitRepository()
        visitRepository.deleteStoreVisitResult = .success("방문 인증을 삭제했어요")
        let viewModel = try makeLoadedViewModel(visitRepository: visitRepository)
        let toasted = expectation(description: "toast")
        var toast: String?
        viewModel.output.showToast.sink { toast = $0; toasted.fulfill() }.store(in: &cancellables)

        // When
        viewModel.input.didConfirmDelete.send(try XCTUnwrap(firstItem(viewModel)))

        // Then
        wait(for: [toasted], timeout: 2)
        XCTAssertEqual(visitRepository.deletedVisitIds, ["visit-1"])
        XCTAssertEqual(toast, "방문 인증을 삭제했어요")
        XCTAssertFalse(visitIds(viewModel).contains("visit-1"))
        XCTAssertEqual(visitIds(viewModel).count, 2)
    }

    // MARK: TH-1538 TC6

    func test_TH1538_TC6_서버가삭제를거부하면_서버에러메시지를토스트로띄우고항목을유지한다() throws {
        // Given
        let visitRepository = MockVisitRepository()
        visitRepository.deleteStoreVisitResult = .failure(NetworkError.errorContainer(
            .init(message: "하루가 지난 방문 인증은 삭제할 수 없어요", resultCode: "BR000")
        ))
        let viewModel = try makeLoadedViewModel(visitRepository: visitRepository)
        let toasted = expectation(description: "toast")
        var toast: String?
        viewModel.output.showToast.sink { toast = $0; toasted.fulfill() }.store(in: &cancellables)

        // When
        viewModel.input.didConfirmDelete.send(try XCTUnwrap(firstItem(viewModel)))

        // Then
        wait(for: [toasted], timeout: 2)
        XCTAssertEqual(toast, "하루가 지난 방문 인증은 삭제할 수 없어요")
        XCTAssertEqual(visitIds(viewModel).count, 3)
    }

    // MARK: TH-1538 TC7

    func test_TH1538_TC7_같은날짜의유일한항목을삭제하면_날짜섹션도사라진다() throws {
        // Given
        let visitRepository = MockVisitRepository()
        visitRepository.deleteStoreVisitResult = .success("OK")
        let viewModel = try makeLoadedViewModel(visitRepository: visitRepository)
        XCTAssertEqual(viewModel.output.sections.value.map(\.visitDate), ["2026-10-27", "2026-10-20"])
        let target = try XCTUnwrap(viewModel.output.sections.value.last?.items.first.flatMap(item))
        let deleted = sectionsExpectation(viewModel) { $0.count == 1 }

        // When
        viewModel.input.didConfirmDelete.send(target)

        // Then
        wait(for: [deleted], timeout: 2)
        XCTAssertEqual(viewModel.output.sections.value.map(\.visitDate), ["2026-10-27"])
    }

    // MARK: TH-1538 TC8

    func test_TH1538_TC8_마지막한건을삭제하면_빈목록이되고편집모드가끝난다() throws {
        // Given
        let visitRepository = MockVisitRepository()
        visitRepository.deleteStoreVisitResult = .success("OK")
        let viewModel = try makeLoadedViewModel(visitRepository: visitRepository, visits: [Self.visitJSON(id: "visit-1", date: "2026-10-27")])
        viewModel.input.didTapEdit.send(())
        let emptied = sectionsExpectation(viewModel) { $0.isEmpty }

        // When
        viewModel.input.didConfirmDelete.send(try XCTUnwrap(firstItem(viewModel)))

        // Then
        wait(for: [emptied], timeout: 2)
        XCTAssertEqual(viewModel.output.isEditing.value, false)
    }

    // MARK: TH-1538 TC9

    func test_TH1538_TC9_네트워크오류면_공통에러를띄우고항목을유지한다() throws {
        // Given
        let visitRepository = MockVisitRepository()
        visitRepository.deleteStoreVisitResult = .failure(NetworkError.timeoutError)
        let viewModel = try makeLoadedViewModel(visitRepository: visitRepository)
        let failed = expectation(description: "error")
        viewModel.output.showErrorAlert.sink { _ in failed.fulfill() }.store(in: &cancellables)

        // When
        viewModel.input.didConfirmDelete.send(try XCTUnwrap(firstItem(viewModel)))

        // Then
        wait(for: [failed], timeout: 2)
        XCTAssertEqual(visitIds(viewModel).count, 3)
    }

    // MARK: TH-1538 TC11

    func test_TH1538_TC11_일반모드에서항목을누르면_가게상세로이동하고편집중에는이동하지않는다() throws {
        // Given
        let viewModel = try makeLoadedViewModel()
        var routes: [String] = []
        viewModel.output.route
            .sink { if case .storeDetail(let storeId) = $0 { routes.append(String(storeId)) } }
            .store(in: &cancellables)

        // When
        viewModel.input.didSelectItem.send(IndexPath(item: 0, section: 0))
        viewModel.input.didTapEdit.send(())
        viewModel.input.didSelectItem.send(IndexPath(item: 0, section: 0))

        // Then
        XCTAssertEqual(routes, ["101"])
    }

    // MARK: TH-1538 TC13

    func test_TH1538_TC13_편집버튼을누르면_편집클릭로그가한건전송된다() throws {
        // Given
        let logManager = MockLogManager()
        let viewModel = try makeLoadedViewModel(logManager: logManager)

        // When
        viewModel.input.didTapEdit.send(())

        // Then
        let events = logManager.sentEvents.filter { ($0.parameters["object_id"] as? String) == "edit" }
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name.rawValue, EventName.click.rawValue)
        XCTAssertEqual(events.first?.screen.rawValue, "visited_list")
        XCTAssertEqual(events.first?.parameters["object_type"] as? String, "button")
    }

    // MARK: TH-1538 TC14

    func test_TH1538_TC14_삭제를확정하면_가게와방문id가담긴삭제클릭로그가한건전송된다() throws {
        // Given
        let logManager = MockLogManager()
        let visitRepository = MockVisitRepository()
        visitRepository.deleteStoreVisitResult = .success("OK")
        let viewModel = try makeLoadedViewModel(visitRepository: visitRepository, logManager: logManager)

        // When
        viewModel.input.didConfirmDelete.send(try XCTUnwrap(firstItem(viewModel)))

        // Then
        let events = logManager.sentEvents.filter { ($0.parameters["object_id"] as? String) == "delete_visit" }
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.parameters["object_type"] as? String, "button")
        XCTAssertEqual(events.first?.parameters["store_id"] as? String, "101")
        XCTAssertEqual(events.first?.parameters["store_type"] as? String, "USER_STORE")
        XCTAssertEqual(events.first?.parameters["visit_id"] as? String, "visit-1")
    }
}

private extension VisitStoreListViewModelTests {
    static func visitJSON(id: String, date: String, storeId: String = "101") -> String {
        """
        {
          "visit": { "visitId": "\(id)", "type": "EXISTS", "visitDate": "\(date)", "isOwner": true, "createdAt": "\(date)T12:00:00", "updatedAt": "\(date)T12:00:00" },
          "store": { "storeType": "USER_STORE", "storeId": "\(storeId)", "isOwner": false, "storeName": "가게\(storeId)", "categories": [], "isDeleted": false, "activitiesStatus": "RECENT_ACTIVITY" }
        }
        """
    }

    func makeLoadedViewModel(
        visitRepository: MockVisitRepository = MockVisitRepository(),
        logManager: MockLogManager = MockLogManager(),
        visits: [String] = [
            visitJSON(id: "visit-1", date: "2026-10-27"),
            visitJSON(id: "visit-2", date: "2026-10-27", storeId: "102"),
            visitJSON(id: "visit-3", date: "2026-10-20", storeId: "103")
        ]
    ) throws -> VisitStoreListViewModel {
        let json = "{ \"contents\": [\(visits.joined(separator: ","))], \"cursor\": { \"nextCursor\": null, \"hasMore\": false } }"
        let response = try JSONDecoder().decode(
            ContentsWithCursorResponse<StoreVisitWithStoreApiResponse>.self,
            from: Data(json.utf8)
        )
        let myPageRepository = MockMyPageRepository()
        myPageRepository.fetchMyStoreVisitsResult = .success(response)
        let viewModel = VisitStoreListViewModel(
            myPageRepository: myPageRepository,
            visitRepository: visitRepository,
            logManager: logManager
        )
        let loaded = sectionsExpectation(viewModel) { $0.isNotEmpty }
        viewModel.input.loadTrigger.send(())
        wait(for: [loaded], timeout: 2)
        return viewModel
    }

    func sectionsExpectation(
        _ viewModel: VisitStoreListViewModel,
        where predicate: @escaping ([VisitStoreListSection]) -> Bool
    ) -> XCTestExpectation {
        let expectation = expectation(description: "sections")
        viewModel.output.sections
            .dropFirst()
            .filter(predicate)
            .first()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)
        return expectation
    }

    func item(_ sectionItem: VisitStoreListSectionItem) -> MyVisitStore {
        guard case .store(let item, _) = sectionItem else { fatalError("unexpected item") }
        return item
    }

    func firstItem(_ viewModel: VisitStoreListViewModel) -> MyVisitStore? {
        viewModel.output.sections.value.first?.items.first.map(item)
    }

    func visitIds(_ viewModel: VisitStoreListViewModel) -> [String] {
        viewModel.output.sections.value.flatMap(\.items).map { item($0).visitId }
    }

    func editingStates(_ viewModel: VisitStoreListViewModel) -> [Bool] {
        viewModel.output.sections.value.flatMap(\.items).map {
            guard case .store(_, let isEditing) = $0 else { return false }
            return isEditing
        }
    }
}
