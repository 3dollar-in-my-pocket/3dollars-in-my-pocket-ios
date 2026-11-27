import UIKit
import XCTest

import Model
@testable import Feed

@MainActor
final class FeedContentCardLayoutTests: XCTestCase {
    private let cellWidth: CGFloat = 362

    // MARK: TH-1558 TC2

    func test_TH1558_TC2_리뷰소식카드는_배지와가게요약과작성자본문을_계산한카드높이안에그린다() throws {
        // Given
        let card = try makeReviewCard()

        // When
        let cell = layoutCell(card: card)

        // Then
        XCTAssertNotNil(label(in: cell, hasPrefix: "❤️"))
        XCTAssertNotNil(label(in: cell, hasPrefix: "뽀미"))
        let textLabel = try XCTUnwrap(label(in: cell, hasPrefix: "ww"))
        let textFrame = textLabel.convert(textLabel.bounds, to: cell.contentView)
        XCTAssertLessThanOrEqual(textFrame.maxY, cell.bounds.height - 16 - 12 + 1)
    }

    func test_TH1558_TC2_줄바꿈이많은HTML긴본문도_5줄까지카드안에들어오고_블록아래여백이같다() throws {
        // Given
        let longText = (1...12).map { "붕어빵 리뷰 \($0)번째 줄" }.joined(separator: "<br>")
        let shortCard = try makeReviewCard(text: "첫째 줄")
        let longCard = try makeReviewCard(text: longText)

        // When
        let shortGap = try textBottomGap(in: layoutCell(card: shortCard), prefix: "첫째 줄")
        let longCell = layoutCell(card: longCard)
        let longGap = try textBottomGap(in: longCell, prefix: "붕어빵 리뷰")

        // Then
        let longLabel = try XCTUnwrap(label(in: longCell, hasPrefix: "붕어빵 리뷰"))
        let fittingHeight = longLabel.sizeThatFits(CGSize(width: longLabel.bounds.width, height: .greatestFiniteMagnitude)).height
        XCTAssertEqual(longLabel.frame.height, fittingHeight, accuracy: 1)
        XCTAssertGreaterThan(longLabel.frame.height, 80)
        XCTAssertEqual(longGap, shortGap, accuracy: 1)
    }

    // MARK: TH-1558 TC10

    func test_TH1558_TC10_본문사진은_서버이미지크기대로그린다() throws {
        // Given
        let largeCard = try makeReviewCard()
        let smallCard = try makeReviewCard(imageSize: 56)

        // When
        let largeSizes = try imageCellSizes(in: layoutCell(card: largeCard))
        let smallSizes = try imageCellSizes(in: layoutCell(card: smallCard))

        // Then
        XCTAssertEqual(largeSizes, [CGSize(width: 124, height: 124), CGSize(width: 124, height: 124)])
        XCTAssertEqual(smallSizes, [CGSize(width: 56, height: 56), CGSize(width: 56, height: 56)])
    }

    // MARK: - Helpers

    private func layoutCell(card: HomeNewsContentCard) -> FeedContentCardCell {
        let height = FeedContentCardCell.Layout.height(card: card, cellWidth: cellWidth)
        let cell = FeedContentCardCell(frame: CGRect(x: 0, y: 0, width: cellWidth, height: height))
        cell.bind(card: card, cellWidth: cellWidth)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }

    private func textBottomGap(in cell: FeedContentCardCell, prefix: String) throws -> CGFloat {
        let textLabel = try XCTUnwrap(label(in: cell, hasPrefix: prefix))
        let textFrame = textLabel.convert(textLabel.bounds, to: cell.contentView)
        return cell.bounds.height - textFrame.maxY
    }

    private func imageCellSizes(in cell: FeedContentCardCell) throws -> [CGSize] {
        let collectionView = try XCTUnwrap(collectionView(in: cell))
        collectionView.layoutIfNeeded()
        return (0..<collectionView.numberOfItems(inSection: 0)).compactMap {
            collectionView.layoutAttributesForItem(at: IndexPath(item: $0, section: 0))?.size
        }
    }

    private func collectionView(in view: UIView) -> UICollectionView? {
        for subview in view.subviews {
            if let collectionView = subview as? UICollectionView, collectionView.isHidden == false {
                return collectionView
            }
            if let found = collectionView(in: subview) {
                return found
            }
        }
        return nil
    }

    private func label(in view: UIView, hasPrefix prefix: String) -> UILabel? {
        for subview in view.subviews {
            if let label = subview as? UILabel,
               (label.attributedText?.string ?? label.text ?? "").hasPrefix(prefix) {
                return label
            }
            if let found = label(in: subview, hasPrefix: prefix) {
                return found
            }
        }
        return nil
    }

    private func makeReviewCard(text: String? = nil, imageSize: Double? = nil) throws -> HomeNewsContentCard {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "HomeNewsSection", withExtension: "json"))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        let items = try XCTUnwrap(json["items"] as? [[String: Any]])
        var card = try XCTUnwrap(items.first { $0["cardId"] as? String == "NEWS:6af4a1f27af92de3599ff76b" })
        var blocks = try XCTUnwrap(card["bodyBlocks"] as? [[String: Any]])
        if let text {
            blocks[0]["text"] = [
                "text": "<span style=\"font-size:14px; font-weight:400; color:#2E2E2E\">\(text)</span>",
                "isHtml": true,
                "fontColor": "#2E2E2E"
            ]
        }
        if let imageSize {
            var images = try XCTUnwrap(blocks[0]["images"] as? [[String: Any]])
            images = images.map { image in
                var image = image
                image["style"] = ["width": imageSize, "height": imageSize, "dimmed": false, "alpha": 1.0]
                return image
            }
            blocks[0]["images"] = images
        }
        card["bodyBlocks"] = blocks
        return try JSONDecoder().decode(HomeNewsContentCard.self, from: JSONSerialization.data(withJSONObject: card))
    }
}
