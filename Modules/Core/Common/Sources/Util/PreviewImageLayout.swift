import UIKit

import Model

public enum PreviewImageLayout {
    public static let fillMaxCount = 3

    public static func fillWidth(count: Int, availableWidth: CGFloat, spacing: CGFloat) -> CGFloat? {
        guard count > 0, count <= fillMaxCount, availableWidth > 0 else { return nil }

        let totalSpacing = spacing * CGFloat(count - 1)
        let width = (availableWidth - totalSpacing) / CGFloat(count)

        guard width > 0 else { return nil }
        return floor(width)
    }

    public static func itemSize(
        style: SDImageStyle?,
        count: Int,
        availableWidth: CGFloat,
        spacing: CGFloat,
        defaultSize: CGSize
    ) -> CGSize {
        let height = resolve(style?.height, default: defaultSize.height)

        if let fillWidth = fillWidth(count: count, availableWidth: availableWidth, spacing: spacing) {
            return CGSize(width: fillWidth, height: height)
        }

        return CGSize(width: resolve(style?.width, default: defaultSize.width), height: height)
    }

    public static func rowHeight(images: [SDImage], defaultHeight: CGFloat) -> CGFloat {
        guard images.isEmpty.isNot else { return 0 }

        return images
            .map { resolve($0.style.height, default: defaultHeight) }
            .max() ?? defaultHeight
    }

    private static func resolve(_ value: Double?, default defaultValue: CGFloat) -> CGFloat {
        guard let value, value > 0 else { return defaultValue }
        return CGFloat(value)
    }
}
