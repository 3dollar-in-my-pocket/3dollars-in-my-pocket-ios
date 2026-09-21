import Combine
import XCTest

import Model
@testable import Store

/// 가게 신고 바텀시트(신고 사유 선택 → 신고하기) 화면 로직.
///
/// TH-1337: 신고에 성공해도 시트를 닫으라는 이벤트를 아무도 구독하지 않아 모달이 그대로 떠 있었다.
/// 또 서버가 내려주는 `isDeleted`(신고 누적 자동 삭제 여부)를 버리고 있어
/// 상세 화면이 사라진 가게를 계속 보여줬다.
final class ReportBottomSheetViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TC1

    func test_TC1_신고에성공하면_dismissRoute가발행된다() async throws {
        // Given
        let repository = MockStoreRepository(reportStoreResult: .success(try makeDeleteResponse(isDeleted: false)))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "route")
        var receivedRoute: ReportBottomSheetViewModel.Route?
        viewModel.output.route.sink {
            receivedRoute = $0
            expectation.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.didTapReason.send(0)
        viewModel.input.didTapReport.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        guard case .dismiss = receivedRoute else { return XCTFail("dismiss route가 아님") }
        // 선택한 사유가 그대로 서버로 나갔는지 확인한다.
        XCTAssertEqual(repository.lastReportStoreArguments?.storeId, 1)
        XCTAssertEqual(repository.lastReportStoreArguments?.reportReason, "NOSTORE")
    }

    // MARK: TC2

    func test_TC2_신고누적으로삭제되면_onSuccessReport로_isDeleted_true가전달된다() async throws {
        // Given
        let repository = MockStoreRepository(reportStoreResult: .success(try makeDeleteResponse(isDeleted: true)))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "onSuccessReport")
        var isDeleted: Bool?
        viewModel.output.onSuccessReport.sink {
            isDeleted = $0
            expectation.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.didTapReason.send(0)
        viewModel.input.didTapReport.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(isDeleted, true)
    }

    func test_TC2_삭제되지않으면_onSuccessReport로_isDeleted_false가전달된다() async throws {
        // Given
        let repository = MockStoreRepository(reportStoreResult: .success(try makeDeleteResponse(isDeleted: false)))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "onSuccessReport")
        var isDeleted: Bool?
        viewModel.output.onSuccessReport.sink {
            isDeleted = $0
            expectation.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.didTapReason.send(0)
        viewModel.input.didTapReport.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(isDeleted, false)
    }

    // MARK: TC3

    func test_TC3_신고에실패하면_에러가발행되고_시트는닫히지않는다() async {
        // Given
        let expectedError = NSError(domain: "ReportStore", code: -1)
        let repository = MockStoreRepository(reportStoreResult: .failure(expectedError))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "error")
        var receivedError: Error?
        viewModel.output.showErrorAlert.sink {
            receivedError = $0
            expectation.fulfill()
        }.store(in: &cancellables)

        var didRoute = false
        viewModel.output.route.sink { _ in didRoute = true }.store(in: &cancellables)

        // When
        viewModel.input.didTapReason.send(0)
        viewModel.input.didTapReport.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual((receivedError as NSError?)?.code, -1)
        XCTAssertFalse(didRoute, "신고에 실패하면 시트를 닫지 않는다")
    }

    /// 사유를 고르지 않으면 신고 요청 자체가 나가지 않는다.
    func test_TC3_사유를고르지않고_신고하면_요청이나가지않는다() async throws {
        // Given
        let repository = MockStoreRepository(reportStoreResult: .success(try makeDeleteResponse(isDeleted: false)))
        let viewModel = makeViewModel(repository: repository)

        // When
        viewModel.input.didTapReport.send(())
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(repository.reportStoreCallCount, 0)
        XCTAssertFalse(viewModel.output.isEnableReport.value)
    }

    // MARK: Helpers

    private func makeViewModel(repository: MockStoreRepository) -> ReportBottomSheetViewModel {
        ReportBottomSheetViewModel(
            config: .init(storeId: 1, reportReasons: makeReportReasons()),
            storeRespository: repository,
            logManager: MockLogManager()
        )
    }

    private func makeReportReasons() -> [ReportReason] {
        let json = """
        [
          { "type": "NOSTORE", "description": "없어진 가게에요", "hasReasonDetail": false },
          { "type": "WRONG_POSITION", "description": "위치가 잘못됐어요", "hasReasonDetail": false }
        ]
        """
        let responses = (try? JSONDecoder().decode([ReportReasonResponse].self, from: Data(json.utf8))) ?? []
        return responses.map(ReportReason.init)
    }

    private func makeDeleteResponse(isDeleted: Bool) throws -> StoreDeleteResponse {
        let json = #"{ "isDeleted": \#(isDeleted) }"#
        return try JSONDecoder().decode(StoreDeleteResponse.self, from: Data(json.utf8))
    }
}
