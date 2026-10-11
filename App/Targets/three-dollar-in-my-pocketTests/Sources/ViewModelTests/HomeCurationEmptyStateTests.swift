import Combine
import CoreLocation
import UIKit
import XCTest

import Model
@testable import Home

final class HomeCurationEmptyStateTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let location = CLLocation(latitude: 37.497941, longitude: 127.027616)

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1460 TC1

    func test_TH1460_TC1_큐레이션항목이없으면_빈상태를전달한다() async throws {
        // Given
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(
            try JSONDecoder().decode(HomeCurationSectionResponse.self, from: Data(#"{"items":[]}"#.utf8))
        )
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        let emptied = expectation(description: "isEmpty")
        viewModel.output.isEmpty
            .dropFirst()
            .sink { if $0 { emptied.fulfill() } }
            .store(in: &cancellables)

        // When
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(location)

        // Then
        await fulfillment(of: [emptied], timeout: 1)
        XCTAssertTrue(viewModel.output.items.value.isEmpty)
    }

    func test_TH1460_TC1_큐레이션항목이있으면_빈상태가아니다() async throws {
        // Given
        let repository = MockScreenRepository()
        repository.fetchHomeCurationSectionResult = .success(
            try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")
        )
        let viewModel = HomeCurationViewModel(dependency: .init(screenRepository: repository))
        let loaded = expectation(description: "items")
        viewModel.output.items
            .dropFirst()
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.input.setTabId.send("CURATION")
        viewModel.input.setLocation.send(location)

        // Then
        await fulfillment(of: [loaded], timeout: 1)
        XCTAssertFalse(viewModel.output.isEmpty.value)
    }

    // MARK: TH-1460 TC2

    func test_TH1460_TC2_캐러셀카드가없으면_주변가게없음문구를보여준다() throws {
        // Given
        let carousel = try makeCarouselViewData(cards: [])
        let cell = HomeCurationCarouselCell(frame: CGRect(x: 0, y: 0, width: 393, height: 400))

        // When
        cell.bind(carousel, rootViewController: UIViewController())

        // Then
        let emptyLabel = try XCTUnwrap(labels(in: cell, text: Strings.HomeCuration.Empty.title).first)
        XCTAssertFalse(emptyLabel.isHidden)
        XCTAssertEqual(
            HomeCurationCarouselCell.Layout.height(carousel),
            HomeCurationCarouselCell.Layout.verticalInset * 2
                + HomeCurationCarouselCell.Layout.titleHeight
                + HomeCurationCarouselCell.Layout.chipRowHeight
                + HomeCurationCarouselCell.Layout.emptyRowHeight
        )
    }

    func test_TH1460_TC2_캐러셀카드가있으면_주변가게없음문구를숨긴다() throws {
        // Given
        let response = try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")
        guard case .carousel(let first) = response.items.first else { return XCTFail("캐러셀이 아님") }
        let carousel = try makeCarouselViewData(cards: first.cards)
        let cell = HomeCurationCarouselCell(frame: CGRect(x: 0, y: 0, width: 393, height: 400))

        // When
        cell.bind(carousel, rootViewController: UIViewController())

        // Then
        let emptyLabel = try XCTUnwrap(labels(in: cell, text: Strings.HomeCuration.Empty.title).first)
        XCTAssertTrue(emptyLabel.isHidden)
    }
}

extension HomeCurationEmptyStateTests {
    private func makeCarouselViewData(cards: [HomeCurationCard]) throws -> HomeCurationCarouselViewData {
        let response = try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")
        guard case .carousel(let carousel) = response.items.first else {
            throw XCTSkip("픽스처 첫 아이템이 캐러셀이 아님")
        }
        return HomeCurationCarouselViewData(
            carouselId: carousel.carouselId,
            header: carousel.header,
            categories: carousel.categoryFilters.map {
                HomeCurationCategoryViewData(filter: $0, isSelected: $0.categoryId == carousel.defaultCategoryId)
            },
            selectedCategoryId: carousel.defaultCategoryId,
            cards: cards
        )
    }

    private func labels(in view: UIView, text: String) -> [UILabel] {
        var result: [UILabel] = []
        if let label = view as? UILabel, label.text == text {
            result.append(label)
        }
        for subview in view.subviews {
            result.append(contentsOf: labels(in: subview, text: text))
        }
        return result
    }
}
