import UIKit
import XCTest

import Model
@testable import Store

final class StoreInfoV1CellLayoutTests: XCTestCase {
    private let cellWidth: CGFloat = 393

    // MARK: TH-1445 TC1

    func test_TH1445_TC1_메뉴명이비어있어도_가격이자기행안에있고_다른행과겹치지않는다() throws {
        // Given
        let section = try FixtureLoader.decode(StoreInfoV1Section.self, from: "StoreInfoV1SectionWithEmptyMenuName")

        // When
        let cell = layoutCell(section)

        // Then
        let priceLabels = ["5개 4000원", "3개 2500원", "1000"].flatMap { labels(in: cell, text: $0) }
        XCTAssertEqual(priceLabels.count, 4)
        for label in priceLabels {
            let row = try XCTUnwrap(label.superview)
            XCTAssertGreaterThanOrEqual(row.bounds.height, label.frame.height, "\(label.text ?? "") 가 행 높이를 벗어남")
            XCTAssertGreaterThanOrEqual(label.frame.minY, 0)
            XCTAssertLessThanOrEqual(label.frame.maxY, row.bounds.height)
        }
        let frames = priceLabels.map { $0.convert($0.bounds, to: cell) }.sorted { $0.minY < $1.minY }
        for (upper, lower) in zip(frames, frames.dropFirst()) {
            XCTAssertLessThanOrEqual(upper.maxY, lower.minY, "가격 라벨이 서로 겹침")
        }
    }

    // MARK: TH-1445 TC2

    func test_TH1445_TC2_메뉴명이길면_메뉴명이말줄임되고_가격은한줄로카드안에모두보인다() throws {
        // Given
        let longName = String(repeating: "아주 긴 메뉴 이름 ", count: 6)
        let section = try makeSection(primaryText: longName, secondaryText: "3개 2500원")

        // When
        let cell = layoutCell(section)

        // Then
        let price = try XCTUnwrap(labels(in: cell, text: "3개 2500원").first)
        let name = try XCTUnwrap(labels(in: cell, text: longName).first)
        let card = try XCTUnwrap(price.superview?.superview?.superview?.superview)
        let priceFrame = price.convert(price.bounds, to: card)
        let nameFrame = name.convert(name.bounds, to: card)
        XCTAssertLessThanOrEqual(priceFrame.maxX, card.bounds.width)
        XCTAssertEqual(price.frame.width, price.intrinsicContentSize.width, accuracy: 1)
        XCTAssertEqual(price.frame.height, name.frame.height, accuracy: 1)
        XCTAssertLessThanOrEqual(nameFrame.maxX, priceFrame.minX - 16 + 0.5)
        XCTAssertEqual(name.lineBreakMode, .byTruncatingTail)
    }
}

extension StoreInfoV1CellLayoutTests {
    private func layoutCell(_ section: StoreInfoV1Section) -> StoreInfoV1Cell {
        let cell = StoreInfoV1Cell(frame: CGRect(x: 0, y: 0, width: cellWidth, height: 1000))
        cell.bind(section)
        let size = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: cellWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        cell.frame = CGRect(origin: .zero, size: CGSize(width: cellWidth, height: size.height))
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
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

    private func makeSection(primaryText: String, secondaryText: String) throws -> StoreInfoV1Section {
        var json = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: fixtureData("StoreInfoV1SectionWithEmptyMenuName")) as? [String: Any]
        )
        var menuCard = try XCTUnwrap(json["menuCard"] as? [String: Any])
        var groups = try XCTUnwrap(menuCard["groups"] as? [[String: Any]])
        groups[0]["items"] = [[
            "primaryText": ["text": primaryText, "isHtml": false, "fontColor": "#0F0F0F"],
            "secondaryText": ["text": secondaryText, "isHtml": false, "fontColor": "#0F0F0F"]
        ]]
        menuCard["groups"] = groups
        json["menuCard"] = menuCard
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(StoreInfoV1Section.self, from: data)
    }

    private func fixtureData(_ name: String) throws -> Data {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: name, withExtension: "json"))
        return try Data(contentsOf: url)
    }
}
