import UIKit
import XCTest

import Model
@testable import Feed

@MainActor
final class FeedCellLayoutTests: XCTestCase {
    private let cellWidth: CGFloat = 362

    // MARK: TH-1615 TC1

    func test_TH1615_TC1_줄바꿈이많은HTML긴글은_본문마지막줄까지카드높이안에들어온다() throws {
        // Given
        let feed = try FixtureLoader.decode(FeedResponse.self, from: "FeedContentWithImagesLongHtml")

        // When
        let cell = layoutCell(feed: feed)

        // Then
        let contentLabel = try XCTUnwrap(label(in: cell, hasPrefix: "붕어빵은 늘"))
        let bodyView = try XCTUnwrap(contentLabel.superview)
        XCTAssertGreaterThan(contentLabel.frame.height, 400)
        XCTAssertEqual(bodyView.bounds.height - contentLabel.frame.maxY, 36, accuracy: 1)
    }

    // MARK: TH-1615 TC2

    func test_TH1615_TC2_리뷰카드는_HTML줄바꿈수와상관없이_본문아래여백이같다() throws {
        // Given
        let oneLineFeed = try makeFeed(body: titleAndImagesBody(content: "첫째 줄"))
        let threeLineFeed = try makeFeed(body: titleAndImagesBody(content: "첫째 줄<br>둘째 줄<br>셋째 줄"))

        // When
        let oneLineGap = try contentBottomGap(in: layoutCell(feed: oneLineFeed))
        let threeLineGap = try contentBottomGap(in: layoutCell(feed: threeLineFeed))

        // Then
        XCTAssertEqual(threeLineGap, oneLineGap, accuracy: 1)
    }

    // MARK: TH-1615 TC3

    func test_TH1615_TC3_제목리뷰카드는_글자수와상관없이_실제라벨폭으로재서_본문이줄어들지않는다() throws {
        // Given
        let sentence = String(repeating: "붕어빵이 바삭하고 팥이 가득해서 맛있었어요 ", count: 5)
        let contents = stride(from: 10, through: 110, by: 4).map { "붕어빵" + String(sentence.prefix($0)) }

        for content in contents {
            let feed = try makeFeed(body: [
                "type": "CONTENT_WITH_TITLE",
                "title": ["text": "리뷰어", "isHtml": false, "fontColor": "#0F0F0F"],
                "content": ["text": content, "isHtml": false, "fontColor": "#1A1A1A"],
                "style": ["backgroundColor": "#FAFAFA"]
            ])

            // When
            let cell = layoutCell(feed: feed)

            // Then
            let contentLabel = try XCTUnwrap(label(in: cell, hasPrefix: "붕어빵"))
            let fittingHeight = contentLabel.sizeThatFits(
                CGSize(width: contentLabel.bounds.width, height: .greatestFiniteMagnitude)
            ).height
            XCTAssertEqual(contentLabel.frame.height, fittingHeight, accuracy: 1, "\(content.count)자")
        }
    }

    // MARK: - Helpers

    private func layoutCell(feed: FeedResponse) -> FeedCell {
        let height = FeedCell.Layout.calculateHeight(feed: feed, cellWidth: cellWidth)
        let cell = FeedCell(frame: CGRect(x: 0, y: 0, width: cellWidth, height: height))
        cell.bind(feed: feed, cellWidth: cellWidth)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }

    private func contentBottomGap(in cell: FeedCell) throws -> CGFloat {
        let contentLabel = try XCTUnwrap(label(in: cell, hasPrefix: "첫째 줄"))
        let bodyView = try XCTUnwrap(contentLabel.superview)
        return bodyView.bounds.height - contentLabel.frame.maxY
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

    private func titleAndImagesBody(content: String) -> [String: Any] {
        [
            "type": "CONTENT_WITH_TITLE_AND_IMAGES",
            "title": ["text": "리뷰어", "isHtml": false, "fontColor": "#0F0F0F"],
            "content": [
                "text": "<span style=\"font-size:14px; font-weight:400; color:#1A1A1A\">\(content)</span>",
                "isHtml": true,
                "fontColor": "#1A1A1A"
            ],
            "images": [],
            "style": ["backgroundColor": "#FAFAFA"]
        ]
    }

    private func makeFeed(body: [String: Any]) throws -> FeedResponse {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "FeedContentWithImagesLongHtml", withExtension: "json"))
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        json["body"] = body
        return try JSONDecoder().decode(FeedResponse.self, from: JSONSerialization.data(withJSONObject: json))
    }
}
