import UIKit
import XCTest

@testable import Feed

@MainActor
final class FeedListLayoutTests: XCTestCase {
    func test_TH1566_TC1_패널이_contentInset을_덮어써도_헤더와_카드의_좌우여백이_유지된다() async throws {
        // Given
        let viewModel = FeedListViewModel()
        let viewController = FeedListViewController(viewModel: viewModel)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        viewModel.output.datasource.send([.init(items: [.header, .skeleton(0)])])
        try await Task.sleep(nanoseconds: 100_000_000)
        let collectionView = try XCTUnwrap(viewController.scrollView as? UICollectionView)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)

        // When
        viewModel.output.datasource.send([.init(items: [.header, .empty])])
        try await Task.sleep(nanoseconds: 100_000_000)
        collectionView.layoutIfNeeded()

        // Then
        let headerFrame = try XCTUnwrap(collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))?.frame)
        let emptyFrame = try XCTUnwrap(collectionView.layoutAttributesForItem(at: IndexPath(item: 1, section: 0))?.frame)
        XCTAssertEqual(headerFrame.minX, 20)
        XCTAssertEqual(headerFrame.width, 362)
        XCTAssertEqual(emptyFrame.minX, 20)
        XCTAssertEqual(emptyFrame.width, 362)
    }
}
