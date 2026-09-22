import Combine
import XCTest

import AppInterface
import Log
import Model
import Networking
@testable import Store

final class StoreSectionsViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func test_load하면_sections이전달된다() async throws {
        // Given
        let repository = MockStoreRepository(fetchStoreScreenV2Result: .success(try makeResponse()))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "sections")
        var receivedSections: [any StoreSectionComponent] = []
        viewModel.output.sections.sink {
            receivedSections = $0
            expectation.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(receivedSections.count, 1)
    }

    func test_네트워크실패하면_error가전달된다() async {
        // Given
        let expectedError = NSError(domain: "StoreSections", code: -1)
        let repository = MockStoreRepository(fetchStoreScreenV2Result: .failure(expectedError))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "error")
        var receivedError: Error?
        viewModel.output.error.sink {
            receivedError = $0
            expectation.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual((receivedError as NSError?)?.code, -1)
    }

    func test_리뷰작성액션이면_리뷰작성Route가발행된다() {
        // Given
        let repository = MockStoreRepository(fetchStoreScreenV2Result: .failure(NSError(domain: "unused", code: 0)))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "route")
        viewModel.output.route.sink { route in
            if case .presentWriteReview = route {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        // When
        viewModel.input.didSelectAction.send(.custom(
            .init(actionType: .storeReviewWrite),
            clickLog: nil
        ))

        // Then
        wait(for: [expectation], timeout: 1)
    }

    // MARK: TH-1337 — 삭제된 가게 처리

    func test_TC1_삭제된가게면_서버메시지와함께_상세를닫는Route가발행된다() async {
        // Given
        let error = NetworkError.errorContainer(.init(message: "삭제된 가게입니다", resultCode: "NF002"))
        let repository = MockStoreRepository(fetchStoreScreenV2Result: .failure(error))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "route")
        var receivedRoute: StoreSectionsViewModel.Route?
        viewModel.output.route.sink {
            receivedRoute = $0
            expectation.fulfill()
        }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        guard case .closeWithDeletedStore(let message) = receivedRoute else {
            return XCTFail("closeWithDeletedStore route가 아님")
        }
        XCTAssertEqual(message, "삭제된 가게입니다")
    }

    func test_TC2_삭제가아닌에러면_상세를닫지않고_에러만발행된다() async {
        // Given
        let error = NetworkError.errorContainer(.init(message: "일시적인 문제가 발생하였습니다", resultCode: "IS000"))
        let repository = MockStoreRepository(fetchStoreScreenV2Result: .failure(error))
        let viewModel = makeViewModel(repository: repository)
        let expectation = expectation(description: "error")
        viewModel.output.error.sink { _ in expectation.fulfill() }.store(in: &cancellables)

        var didRoute = false
        viewModel.output.route.sink { _ in didRoute = true }.store(in: &cancellables)

        // When
        viewModel.input.load.send(())

        // Then
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertFalse(didRoute, "삭제가 아닌 에러로는 상세를 닫지 않는다")
    }

    func test_TC2_네트워크에러면_상세를닫지않는다() {
        // Given / When
        let error = NetworkError.errorContainer(.init(message: "세션이 만료되었습니다", resultCode: "UA000"))

        // Then
        XCTAssertNil(StoreSectionsViewModel.deletedStoreMessage(from: error))
        XCTAssertNil(StoreSectionsViewModel.deletedStoreMessage(from: NSError(domain: "offline", code: -1009)))
    }

    private func makeViewModel(
        repository: MockStoreRepository,
        reportRepository: MockReportRepository = MockReportRepository(),
        globalEventBus: MockGlobalEventBus = MockGlobalEventBus()
    ) -> StoreSectionsViewModel {
        StoreSectionsViewModel(
            config: .init(storeId: 1, latitude: 37.5, longitude: 127.0),
            dependency: .init(
                storeRepository: repository,
                reportRepository: reportRepository,
                logManager: MockLogManager(),
                globalEventBus: globalEventBus
            )
        )
    }

    private func makeReportReasonResponse() throws -> ReportReasonApiResponse {
        let json = """
        { "reasons": [{ "type": "NOSTORE", "description": "없어진 가게에요", "hasReasonDetail": false }] }
        """
        return try JSONDecoder().decode(ReportReasonApiResponse.self, from: Data(json.utf8))
    }

    // MARK: TC3

    func test_TC3_신고에성공하면_토스트와함께_상세를닫는Route가발행된다() async throws {
        // Given
        let globalEventBus = MockGlobalEventBus()
        let viewModel = try makeReportedViewModel(globalEventBus: globalEventBus)
        let routeExpectation = expectation(description: "closeAfterReport")
        var receivedRoute: StoreSectionsViewModel.Route?
        viewModel.output.route.sink { route in
            if case .closeAfterReport = route {
                receivedRoute = route
                routeExpectation.fulfill()
            }
        }.store(in: &cancellables)

        // When
        let reportViewModel = try await presentReportViewModel(from: viewModel)
        reportViewModel.output.onSuccessReport.send(false)

        // Then
        await fulfillment(of: [routeExpectation], timeout: 1)
        guard case .closeAfterReport(let message) = receivedRoute else {
            return XCTFail("closeAfterReport route가 아님")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func test_TC3_신고에성공하면_홈이재조회하도록_전역이벤트를발행한다() async throws {
        // Given
        let globalEventBus = MockGlobalEventBus()
        let viewModel = try makeReportedViewModel(globalEventBus: globalEventBus)
        let eventExpectation = expectation(description: "onReportStore")
        var reportedStoreId: Int?
        globalEventBus.onReportStore.sink {
            reportedStoreId = $0
            eventExpectation.fulfill()
        }.store(in: &cancellables)

        // When
        let reportViewModel = try await presentReportViewModel(from: viewModel)
        reportViewModel.output.onSuccessReport.send(false)

        // Then
        await fulfillment(of: [eventExpectation], timeout: 1)
        XCTAssertEqual(reportedStoreId, 1)
    }

    private func makeReportedViewModel(globalEventBus: MockGlobalEventBus) throws -> StoreSectionsViewModel {
        makeViewModel(
            repository: MockStoreRepository(fetchStoreScreenV2Result: .failure(MockError.notStubbed())),
            reportRepository: MockReportRepository(fetchReportReasonsResult: .success(try makeReportReasonResponse())),
            globalEventBus: globalEventBus
        )
    }

    private func presentReportViewModel(
        from viewModel: StoreSectionsViewModel
    ) async throws -> ReportBottomSheetViewModel {
        let expectation = expectation(description: "presentStoreReport")
        var reportViewModel: ReportBottomSheetViewModel?
        let cancellable = viewModel.output.route.sink { route in
            if case .presentStoreReport(let presented) = route {
                reportViewModel = presented
                expectation.fulfill()
            }
        }
        viewModel.input.didSelectAction.send(.custom(
            .init(actionType: .storeEditReport, extraParams: ["STORE_ID": .string("1")]),
            clickLog: nil
        ))
        await fulfillment(of: [expectation], timeout: 1)
        cancellable.cancel()
        return try XCTUnwrap(reportViewModel)
    }

    /// INFO_V1 의 informationCard.rows 는 서버가 `type` 으로 구분하는 3종 행이다.
    /// 픽스처는 dev `/api/v2/screen/store/{storeId}` 실응답 구조를 그대로 따른다.
    func test_INFO_V1섹션이_디코딩된다() throws {
        // Given
        let json = """
        {
          "viewLog": { "screenName": "store_detail", "extraParameters": {} },
          "sections": [
            {
              "type": "INFO_V1",
              "header": { "title": { "text": "가게 정보 & 메뉴", "isHtml": false, "fontColor": "#000000" } },
              "informationCard": {
                "rows": [
                  {
                    "type": "TRAILING_TEXT",
                    "label": { "text": "가게형태", "isHtml": false, "fontColor": "#666666" },
                    "value": { "text": "길거리", "isHtml": false, "fontColor": "#000000" }
                  },
                  {
                    "type": "CHIP_GROUP",
                    "label": { "text": "출몰 시기", "isHtml": false, "fontColor": "#666666" },
                    "chips": [{
                      "text": { "text": "월", "isHtml": false, "fontColor": "#000000" },
                      "style": { "backgroundColor": "#F4F4F4" }
                    }]
                  },
                  {
                    "type": "INLINE_OPTION",
                    "label": { "text": "결제 방식", "isHtml": false, "fontColor": "#666666" },
                    "items": [
                      { "isSelected": true, "text": { "text": "현금", "isHtml": false, "fontColor": "#000000" } },
                      { "isSelected": false, "text": { "text": "카드", "isHtml": false, "fontColor": "#B7B7B7" } }
                    ]
                  }
                ],
                "style": { "backgroundColor": "#F8F8F8" }
              },
              "menuCard": {
                "groups": [{
                  "header": { "text": { "text": "붕어빵", "isHtml": false, "fontColor": "#000000" } },
                  "items": [{
                    "primaryText": { "text": "팥붕어빵", "isHtml": false, "fontColor": "#000000" },
                    "secondaryText": { "text": "3개 2000원", "isHtml": false, "fontColor": "#666666" }
                  }]
                }],
                "style": { "backgroundColor": "#F8F8F8" }
              }
            }
          ]
        }
        """

        // When
        let response = try JSONDecoder().decode(StoreScreenV2Response.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(response.sections.count, 1)
        let infoV1 = try XCTUnwrap(response.sections[0] as? StoreInfoV1Section)
        XCTAssertEqual(infoV1.informationCard?.rows.count, 3)
        guard case .trailingText(let trailingTextRow) = infoV1.informationCard?.rows[0] else {
            return XCTFail("TRAILING_TEXT 행이 아님")
        }
        XCTAssertEqual(trailingTextRow.value.text, "길거리")
        guard case .chipGroup(let chipGroupRow) = infoV1.informationCard?.rows[1] else {
            return XCTFail("CHIP_GROUP 행이 아님")
        }
        XCTAssertEqual(chipGroupRow.chips.first?.text?.text, "월")
        guard case .inlineOption(let inlineOptionRow) = infoV1.informationCard?.rows[2] else {
            return XCTFail("INLINE_OPTION 행이 아님")
        }
        XCTAssertEqual(inlineOptionRow.items.first?.isSelected, true)
        XCTAssertEqual(infoV1.menuCard?.groups.first?.items.first?.primaryText.text, "팥붕어빵")
    }

    func test_INFO_V2섹션이_디코딩된다() throws {
        // Given
        let json = """
        {
          "viewLog": { "screenName": "store_detail", "extraParameters": {} },
          "sections": [
            {
              "type": "INFO_V2",
              "header": { "title": { "text": "가게 정보 & 메뉴", "isHtml": false, "fontColor": "#000000" } },
              "imageGallery": {
                "images": [{ "url": "https://example.com/1.jpg", "style": { "width": 96, "height": 96 } }]
              },
              "detailCard": {
                "rows": [
                  {
                    "type": "LINK",
                    "label": { "text": "SNS", "isHtml": false, "fontColor": "#666666" },
                    "value": { "text": "instagram.com/store", "isHtml": false, "fontColor": "#000000" },
                    "link": { "type": "WEB", "link": "https://instagram.com/store" }
                  },
                  {
                    "type": "TEXT",
                    "title": { "text": "사장님 한마디", "isHtml": false, "fontColor": "#666666" },
                    "body": { "text": "매일 신선한 재료로!", "isHtml": false, "fontColor": "#000000" }
                  }
                ],
                "style": { "backgroundColor": "#F8F8F8" }
              },
              "accountCards": [{
                "title": { "text": "계좌번호", "isHtml": false, "fontColor": "#666666" },
                "account": {
                  "text": { "text": "국민은행", "isHtml": false, "fontColor": "#000000" },
                  "additionalText": { "text": "123-456-789", "isHtml": false, "fontColor": "#000000" }
                },
                "copyButton": {
                  "text": { "text": "복사하기", "isHtml": false, "fontColor": "#000000" },
                  "style": { "backgroundColor": "#FFFFFF" }
                },
                "style": { "backgroundColor": "#F8F8F8" }
              }],
              "menuListCard": {
                "items": [{
                  "primaryText": { "text": "슈크림 붕어빵", "isHtml": false, "fontColor": "#000000" },
                  "secondaryText": { "text": "2000원", "isHtml": false, "fontColor": "#666666" }
                }],
                "style": { "backgroundColor": "#F8F8F8" }
              }
            }
          ]
        }
        """

        // When
        let response = try JSONDecoder().decode(StoreScreenV2Response.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(response.sections.count, 1)
        let infoV2 = try XCTUnwrap(response.sections[0] as? StoreInfoV2Section)
        XCTAssertEqual(infoV2.accountCards.first?.account.additionalText?.text, "123-456-789")
        XCTAssertEqual(infoV2.detailCard?.rows.count, 2)
        guard case .link = infoV2.detailCard?.rows[0] else { return XCTFail("LINK 행이 아님") }
        guard case .text = infoV2.detailCard?.rows[1] else { return XCTFail("TEXT 행이 아님") }
    }

    private func makeResponse() throws -> StoreScreenV2Response {
        let json = """
        {
          "viewLog": { "screenName": "store_detail", "extraParameters": {} },
          "sections": [{
            "type": "CALLOUT",
            "content": {
              "title": { "text": "test", "isHtml": false, "fontColor": "#000000" }
            }
          }]
        }
        """
        return try JSONDecoder().decode(StoreScreenV2Response.self, from: Data(json.utf8))
    }
}
