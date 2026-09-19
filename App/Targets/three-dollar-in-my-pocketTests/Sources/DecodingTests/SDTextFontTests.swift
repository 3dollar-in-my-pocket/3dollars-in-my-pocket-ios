import UIKit
import XCTest

import Common
import DesignSystem
import Model

final class SDTextFontTests: XCTestCase {
    private let html = "<span style=\"font-size:14px; font-weight:400; color:#5A5A5A\">일반</span>"
        + "<span style=\"font-size:16px; font-weight:700; color:#0F0F0F\">굵게</span>"

    func test_HTML_SDText를_라벨폰트패밀리로렌더한다() throws {
        // Given
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)

        // When
        label.setSDText(SDText(text: html, isHtml: true, fontColor: "#0F0F0F"))

        // Then
        let fonts = try XCTUnwrap(label.attributedText).fonts
        XCTAssertEqual(fonts.map(\.familyName), ["Pretendard", "Pretendard"])
        XCTAssertEqual(fonts.map(\.fontName), ["Pretendard-Regular", "Pretendard-Bold"])
        XCTAssertEqual(fonts.map(\.pointSize), [14, 16])
    }

    func test_HTML_SDButton_타이틀도_버튼폰트패밀리로렌더한다() throws {
        // Given
        let button = UIButton()
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)

        let json = """
        {
            "text": { "text": "\(html.replacingOccurrences(of: "\"", with: "\\\""))", "isHtml": true, "fontColor": "#0F0F0F" },
            "style": { "backgroundColor": "#FFFFFF" }
        }
        """
        let sdButton = try JSONDecoder().decode(SDButton.self, from: Data(json.utf8))

        // When
        button.setSDButton(sdButton)

        // Then
        let fonts = try XCTUnwrap(button.attributedTitle(for: .normal)).fonts
        XCTAssertEqual(fonts.map(\.fontName), ["Pretendard-Regular", "Pretendard-Bold"])
    }
}

private extension NSAttributedString {
    var fonts: [UIFont] {
        var result: [UIFont] = []
        enumerateAttribute(.font, in: NSRange(location: 0, length: length)) { value, _, _ in
            if let font = value as? UIFont { result.append(font) }
        }
        return result
    }
}
