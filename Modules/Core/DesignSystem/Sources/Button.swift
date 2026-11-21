import UIKit

public class Button {
    public enum Size {
        case medium
        case small
        
        var height: CGFloat {
            switch self {
            case .medium:
                return 48
            
            case .small:
                return 34
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .medium:
                return 12
            
            case .small:
                return 10
            }
        }
        
        var horizontalInset: CGFloat {
            switch self {
            case .medium:
                return 12
            
            case .small:
                return 10
            }
        }
        
        var iconSize: CGSize {
            switch self {
            case .medium:
                return CGSize(width: 24, height: 24)
            
            case .small:
                return CGSize(width: 16, height: 16)
            }
        }
        
        var font: UIFont {
            switch self {
            case .medium:
                return DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
            
            case .small:
                return DesignSystemFontFamily.Pretendard.bold.font(size: 12)
            }
        }
    }
    
    public enum Style {
        case primary
        case secondary
        case destructive
        
        var backgroundColor: UIColor {
            switch self {
            case .primary:
                return DesignSystemAsset.Colors.mainPink.color
            
            case .secondary:
                return DesignSystemAsset.Colors.gray10.color
            
            case .destructive:
                return DesignSystemAsset.Colors.mainRed.color
            }
        }
        
        var foregroundColor: UIColor {
            switch self {
            case .primary, .destructive:
                return DesignSystemAsset.Colors.systemWhite.color
            
            case .secondary:
                return DesignSystemAsset.Colors.gray70.color
            }
        }
    }
    
    public enum IconPlacement {
        case leading
        case trailing
    }
    
    public class Normal: UIButton {
        public let size: Size
        
        public var style: Style {
            didSet { setNeedsUpdateConfiguration() }
        }
        
        public var text: String? {
            didSet { setNeedsUpdateConfiguration() }
        }
        
        public var icon: UIImage? {
            didSet { setNeedsUpdateConfiguration() }
        }
        
        public var iconPlacement: IconPlacement {
            didSet { setNeedsUpdateConfiguration() }
        }
        
        public init(
            size: Size,
            style: Style = .primary,
            text: String? = nil,
            icon: UIImage? = nil,
            iconPlacement: IconPlacement = .leading
        ) {
            self.size = size
            self.style = style
            self.text = text
            self.icon = icon
            self.iconPlacement = iconPlacement
            
            super.init(frame: .zero)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func updateConfiguration() {
            guard var config = configuration else { return }
            
            let foregroundColor = isEnabled ? style.foregroundColor : DesignSystemAsset.Colors.systemWhite.color
            let backgroundColor = isEnabled ? style.backgroundColor : DesignSystemAsset.Colors.gray30.color
            
            config.attributedTitle = text.map {
                AttributedString($0, attributes: AttributeContainer([
                    .font: size.font,
                    .foregroundColor: foregroundColor
                ]))
            }
            config.image = icon.map { resized($0, to: size.iconSize).withRenderingMode(.alwaysTemplate) }
            config.imagePlacement = iconPlacement == .leading ? .leading : .trailing
            config.baseForegroundColor = foregroundColor
            config.background.backgroundColor = backgroundColor
            configuration = config
        }
        
        private func setup() {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: size.horizontalInset,
                bottom: 0,
                trailing: size.horizontalInset
            )
            config.imagePadding = 4
            config.titleLineBreakMode = .byTruncatingTail
            config.cornerStyle = .fixed
            config.background.cornerRadius = size.cornerRadius
            configuration = config
            setNeedsUpdateConfiguration()
            
            translatesAutoresizingMaskIntoConstraints = false
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
        private func resized(_ image: UIImage, to targetSize: CGSize) -> UIImage {
            guard image.size != targetSize else { return image }
            
            return UIGraphicsImageRenderer(size: targetSize).image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
    }
}
