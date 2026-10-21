import UIKit
import XCTest

import Model
@testable import Home

final class HomeCurationEmptyCategoryTests: XCTestCase {
    // MARK: TH-1516 TC1

    func test_TH1516_TC1_카테고리가없으면_카테고리영역을숨기고_높이에서뺀다() throws {
        // Given
        let carousel = try makeCarouselViewData(withCategories: false)
        let cell = HomeCurationCarouselCell(frame: CGRect(x: 0, y: 0, width: 393, height: 400))

        // When
        cell.bind(carousel, rootViewController: UIViewController())
        cell.layoutIfNeeded()

        // Then
        let categoryCollectionView = try XCTUnwrap(collectionViews(in: cell).first)
        XCTAssertTrue(categoryCollectionView.isHidden)
        XCTAssertEqual(categoryCollectionView.frame.height, HomeCurationCarouselCell.Layout.chipVerticalInset)
        XCTAssertEqual(
            HomeCurationCarouselCell.Layout.height(carousel),
            HomeCurationCarouselCell.Layout.verticalInset * 2
                + HomeCurationCarouselCell.Layout.titleHeight
                + HomeCurationCarouselCell.Layout.chipVerticalInset
                + HomeCurationCarouselCell.Layout.cardRowHeight
                + HomeCurationCarouselCell.Layout.cardBottomInset
        )
    }

    // MARK: TH-1516 TC2

    func test_TH1516_TC2_카테고리가있으면_카테고리영역을기존높이로보여준다() throws {
        // Given
        let carousel = try makeCarouselViewData(withCategories: true)
        let cell = HomeCurationCarouselCell(frame: CGRect(x: 0, y: 0, width: 393, height: 400))

        // When
        cell.bind(carousel, rootViewController: UIViewController())
        cell.layoutIfNeeded()

        // Then
        let categoryCollectionView = try XCTUnwrap(collectionViews(in: cell).first)
        XCTAssertFalse(categoryCollectionView.isHidden)
        XCTAssertEqual(categoryCollectionView.frame.height, HomeCurationCarouselCell.Layout.chipRowHeight)
        XCTAssertEqual(
            HomeCurationCarouselCell.Layout.height(carousel),
            HomeCurationCarouselCell.Layout.verticalInset * 2
                + HomeCurationCarouselCell.Layout.titleHeight
                + HomeCurationCarouselCell.Layout.chipRowHeight
                + HomeCurationCarouselCell.Layout.cardRowHeight
                + HomeCurationCarouselCell.Layout.cardBottomInset
        )
    }

    func test_TH1516_TC2_카테고리없는캐러셀로재사용된셀이_다시카테고리를보여준다() throws {
        // Given
        let cell = HomeCurationCarouselCell(frame: CGRect(x: 0, y: 0, width: 393, height: 400))
        cell.bind(try makeCarouselViewData(withCategories: false), rootViewController: UIViewController())

        // When
        cell.bind(try makeCarouselViewData(withCategories: true), rootViewController: UIViewController())
        cell.layoutIfNeeded()

        // Then
        let categoryCollectionView = try XCTUnwrap(collectionViews(in: cell).first)
        XCTAssertFalse(categoryCollectionView.isHidden)
        XCTAssertEqual(categoryCollectionView.frame.height, HomeCurationCarouselCell.Layout.chipRowHeight)
    }
}

extension HomeCurationEmptyCategoryTests {
    private func makeCarouselViewData(withCategories: Bool) throws -> HomeCurationCarouselViewData {
        let response = try FixtureLoader.decode(HomeCurationSectionResponse.self, from: "HomeCurationSection")
        guard case .carousel(let carousel) = response.items.first else {
            throw XCTSkip("픽스처 첫 아이템이 캐러셀이 아님")
        }
        let categories = withCategories ? carousel.categoryFilters.map {
            HomeCurationCategoryViewData(filter: $0, isSelected: $0.categoryId == carousel.defaultCategoryId)
        } : []
        return HomeCurationCarouselViewData(
            carouselId: carousel.carouselId,
            header: carousel.header,
            categories: categories,
            selectedCategoryId: withCategories ? carousel.defaultCategoryId : "",
            cards: carousel.cards
        )
    }

    private func collectionViews(in cell: UICollectionViewCell) -> [UICollectionView] {
        return cell.contentView.subviews.compactMap { $0 as? UICollectionView }
    }
}
