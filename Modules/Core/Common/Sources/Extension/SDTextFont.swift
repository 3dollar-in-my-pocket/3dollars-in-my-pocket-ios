import UIKit

import ZMarkupParser

extension NSAttributedString {
    func applyingFontFamily(of baseFont: UIFont) -> NSAttributedString {
        let faces = UIFont.sdFaces(familyName: baseFont.familyName)
        guard faces.isEmpty.isNot else { return self }

        var replacements: [(range: NSRange, font: UIFont)] = []
        enumerateAttribute(.font, in: NSRange(location: 0, length: length)) { value, range, _ in
            let font = (value as? UIFont) ?? baseFont
            guard let name = UIFont.sdFaceName(faces: faces, weight: font.sdFontWeight),
                  font.fontName != name,
                  let matched = UIFont(name: name, size: font.pointSize) else { return }
            replacements.append((range, matched))
        }
        guard replacements.isEmpty.isNot else { return self }

        let mutable = NSMutableAttributedString(attributedString: self)
        replacements.forEach { mutable.addAttribute(.font, value: $0.font, range: $0.range) }
        return mutable
    }
}

extension MarkupStyleFont {
    init(sdBaseFont font: UIFont) {
        self.init(size: font.pointSize, weight: .style(font.sdFontWeight.sdMarkupWeightStyle))
    }
}

extension UIFont {
    static func sdFaces(familyName: String) -> [(weight: UIFont.Weight, name: String)] {
        UIFont.fontNames(forFamilyName: familyName).compactMap { name in
            guard let face = UIFont(name: name, size: 12) else { return nil }
            return (face.sdFontWeight, name)
        }
    }

    static func sdFaceName(faces: [(weight: UIFont.Weight, name: String)], weight: UIFont.Weight) -> String? {
        faces.min { abs($0.weight.rawValue - weight.rawValue) < abs($1.weight.rawValue - weight.rawValue) }?.name
    }

    var sdFontWeight: UIFont.Weight {
        if let weight = UIFont.Weight.sdWeight(fromFontName: fontName) {
            return weight
        }
        if let traits = fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any],
           let rawValue = traits[.weight] as? CGFloat {
            return UIFont.Weight(rawValue)
        }
        return fontDescriptor.symbolicTraits.contains(.traitBold) ? .bold : .regular
    }
}

extension UIFont.Weight {
    private static let sdNamedWeights: [(keyword: String, weight: UIFont.Weight)] = [
        ("black", .black),
        ("extrabold", .heavy),
        ("ultrabold", .heavy),
        ("heavy", .heavy),
        ("semibold", .semibold),
        ("demibold", .semibold),
        ("bold", .bold),
        ("medium", .medium),
        ("extralight", .ultraLight),
        ("ultralight", .ultraLight),
        ("light", .light),
        ("thin", .thin),
        ("regular", .regular),
        ("book", .regular)
    ]

    static func sdWeight(fromFontName fontName: String) -> UIFont.Weight? {
        let styleName = fontName.split(separator: "-").last.map(String.init) ?? fontName
        let lowercased = styleName.lowercased()
        return sdNamedWeights.first { lowercased.contains($0.keyword) }?.weight
    }

    var sdMarkupWeightStyle: MarkupStyleFont.FontWeightStyle {
        switch self {
        case .black: return .black
        case .heavy: return .heavy
        case .bold: return .bold
        case .semibold: return .semibold
        case .medium: return .medium
        case .light: return .light
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        default: return .regular
        }
    }
}
