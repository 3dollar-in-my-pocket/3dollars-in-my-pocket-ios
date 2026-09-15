import UIKit

extension NSAttributedString {
    func applyingFontFamily(of baseFont: UIFont) -> NSAttributedString {
        let familyName = baseFont.familyName
        let faces: [(weight: UIFont.Weight, name: String)] = UIFont.fontNames(forFamilyName: familyName)
            .compactMap { name in
                guard let font = UIFont(name: name, size: baseFont.pointSize) else { return nil }
                return (font.sdFontWeight, name)
            }
        guard faces.isEmpty.isNot else { return self }

        var replacements: [(range: NSRange, font: UIFont)] = []
        let fullRange = NSRange(location: 0, length: length)
        enumerateAttribute(.font, in: fullRange) { value, range, _ in
            let font = (value as? UIFont) ?? baseFont
            guard font.familyName != familyName else { return }

            let targetWeight = font.sdFontWeight.rawValue
            let name = faces.min {
                abs($0.weight.rawValue - targetWeight) < abs($1.weight.rawValue - targetWeight)
            }?.name
            guard let name, let matched = UIFont(name: name, size: font.pointSize) else { return }
            replacements.append((range, matched))
        }
        guard replacements.isEmpty.isNot else { return self }

        let mutable = NSMutableAttributedString(attributedString: self)
        replacements.forEach { mutable.addAttribute(.font, value: $0.font, range: $0.range) }
        return mutable
    }
}

extension UIFont {
    var sdFontWeight: UIFont.Weight {
        guard let traits = fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any],
              let rawValue = traits[.weight] as? CGFloat else { return .regular }
        return UIFont.Weight(rawValue)
    }
}
