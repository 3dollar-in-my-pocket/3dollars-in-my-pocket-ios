import XCTest

import Common
import Model

final class PreviewImageLayoutTests: XCTestCase {
    private let availableWidth: CGFloat = 350
    private let spacing: CGFloat = 4

    // MARK: fillWidth

    func test_이미지1개면_가용폭전체를차지한다() {
        let width = PreviewImageLayout.fillWidth(count: 1, availableWidth: availableWidth, spacing: spacing)

        XCTAssertEqual(width, 350)
    }

    func test_이미지2개면_간격을뺀폭을반씩나눈다() {
        let width = PreviewImageLayout.fillWidth(count: 2, availableWidth: availableWidth, spacing: spacing)

        XCTAssertEqual(width, 173)
    }

    func test_이미지3개면_간격2개를뺀폭을3등분하고_나머지는버린다() {
        let width = PreviewImageLayout.fillWidth(count: 3, availableWidth: availableWidth, spacing: spacing)

        XCTAssertEqual(width, 114)
    }

    func test_이미지4개이상이면_fill하지않는다() {
        XCTAssertNil(PreviewImageLayout.fillWidth(count: 4, availableWidth: availableWidth, spacing: spacing))
        XCTAssertNil(PreviewImageLayout.fillWidth(count: 10, availableWidth: availableWidth, spacing: spacing))
    }

    func test_이미지가없거나_가용폭이0이면_fill하지않는다() {
        XCTAssertNil(PreviewImageLayout.fillWidth(count: 0, availableWidth: availableWidth, spacing: spacing))
        XCTAssertNil(PreviewImageLayout.fillWidth(count: 2, availableWidth: 0, spacing: spacing))
    }

    // MARK: itemSize

    func test_3개이하면_서버폭을무시하고_가용폭을채운다() {
        let size = PreviewImageLayout.itemSize(
            style: SDImageStyle(width: 110, height: 120),
            count: 2,
            availableWidth: availableWidth,
            spacing: spacing,
            defaultSize: CGSize(width: 120, height: 120)
        )

        XCTAssertEqual(size, CGSize(width: 173, height: 120))
    }

    func test_4개이상이면_서버가내려준크기를그대로쓴다() {
        let size = PreviewImageLayout.itemSize(
            style: SDImageStyle(width: 110, height: 120),
            count: 4,
            availableWidth: availableWidth,
            spacing: spacing,
            defaultSize: CGSize(width: 158, height: 158)
        )

        XCTAssertEqual(size, CGSize(width: 110, height: 120))
    }

    func test_서버값이없으면_기본크기로폴백한다() {
        let size = PreviewImageLayout.itemSize(
            style: nil,
            count: 4,
            availableWidth: availableWidth,
            spacing: spacing,
            defaultSize: CGSize(width: 158, height: 158)
        )

        XCTAssertEqual(size, CGSize(width: 158, height: 158))
    }

    func test_서버값이0이면_기본크기로폴백한다() {
        let size = PreviewImageLayout.itemSize(
            style: SDImageStyle(width: 0, height: 0),
            count: 5,
            availableWidth: availableWidth,
            spacing: spacing,
            defaultSize: CGSize(width: 120, height: 120)
        )

        XCTAssertEqual(size, CGSize(width: 120, height: 120))
    }

    // MARK: rowHeight

    func test_행높이는_가장높은이미지에맞춘다() {
        let images = [
            makeImage(width: 110, height: 120),
            makeImage(width: 110, height: 160)
        ]

        XCTAssertEqual(PreviewImageLayout.rowHeight(images: images, defaultHeight: 120), 160)
    }

    func test_서버높이가없으면_행높이는기본값이다() {
        let images = [makeImage(width: 110, height: 0)]

        XCTAssertEqual(PreviewImageLayout.rowHeight(images: images, defaultHeight: 158), 158)
    }

    func test_이미지가없으면_행높이는0이다() {
        XCTAssertEqual(PreviewImageLayout.rowHeight(images: [], defaultHeight: 120), 0)
    }

    private func makeImage(width: Double, height: Double) -> SDImage {
        return SDImage(
            url: "https://storage.threedollars.co.kr/image.png",
            style: SDImageStyle(width: width, height: height)
        )
    }
}
