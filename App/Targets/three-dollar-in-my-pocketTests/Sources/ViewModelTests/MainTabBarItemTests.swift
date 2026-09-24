import XCTest

import DesignSystem
import Model
@testable import dollar_in_my_pocket

final class MainTabBarItemTests: XCTestCase {

    // MARK: TH-1340 TC1

    func test_TH1340_TC1_탭이_홈_제보_커뮤니티_마이페이지_순서로_4개다() {
        // Given / When
        let items = MainTabBarItem.all

        // Then
        XCTAssertEqual(items.count, 4)
        XCTAssertEqual(items.map(\.tag), [.home, .write, .community, .my])
    }

    func test_TH1340_TC1_모든탭이_비어있지않은_타이틀을_가진다() {
        // Given / When
        let titles = MainTabBarItem.all.map(\.title)

        // Then
        XCTAssertEqual(titles.count, 4)
        XCTAssertTrue(titles.allSatisfy { $0.isEmpty == false })
    }

    func test_TH1340_TC1_탭순서가_TabBarTag_rawValue와_일치한다() {
        // Given / When
        let items = MainTabBarItem.all

        // Then
        for (index, item) in items.enumerated() {
            XCTAssertEqual(item.tag.rawValue, index)
        }
    }

    // MARK: TH-1340 TC2

    func test_TH1340_TC2_제보탭아이콘이_플러스다() {
        // Given
        let writeItem = MainTabBarItem.all.first { $0.tag == .write }

        // When / Then
        XCTAssertEqual(writeItem?.icon.pngData(), DesignSystemAsset.Icons.plus.image.pngData())
    }

    func test_TH1340_TC2_아이콘크기가_24로_통일된다() {
        // Given / When
        let resized = MainTabBarItem.all.map { $0.icon.resizeImage(scaledTo: MainTabBarItem.iconSize).size }

        // Then
        XCTAssertEqual(MainTabBarItem.iconSize, 24)
        XCTAssertTrue(resized.allSatisfy { $0 == resized[0] })
    }
}
