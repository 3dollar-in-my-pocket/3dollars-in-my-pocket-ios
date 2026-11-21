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
        case outline
        case dark
        
        var backgroundColor: UIColor {
            switch self {
            case .primary:
                return DesignSystemAsset.Colors.mainPink.color
            
            case .secondary:
                return DesignSystemAsset.Colors.gray10.color
            
            case .destructive:
                return DesignSystemAsset.Colors.mainRed.color
            
            case .outline:
                return DesignSystemAsset.Colors.systemWhite.color
            
            case .dark:
                return DesignSystemAsset.Colors.gray50.color
            }
        }
        
        var foregroundColor: UIColor {
            switch self {
            case .primary, .destructive, .dark:
                return DesignSystemAsset.Colors.systemWhite.color
            
            case .secondary:
                return DesignSystemAsset.Colors.gray70.color
            
            case .outline:
                return DesignSystemAsset.Colors.gray50.color
            }
        }
        
        var borderColor: UIColor? {
            switch self {
            case .outline:
                return DesignSystemAsset.Colors.gray40.color
            
            case .primary, .secondary, .destructive, .dark:
                return nil
            }
        }
    }
    
    public enum IconPlacement {
        case leading
        case trailing
    }
    
    public class Normal: UIButton {
        public let size: Size
        private var renderedIcon: UIImage?
        
        public var style: Style {
            didSet { setNeedsUpdateConfiguration() }
        }
        
        public var text: String? {
            didSet { setNeedsUpdateConfiguration() }
        }
        
        public var icon: UIImage? {
            didSet {
                renderedIcon = makeRenderedIcon()
                setNeedsUpdateConfiguration()
            }
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
            renderedIcon = makeRenderedIcon()
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func updateConfiguration() {
            guard var config = configuration else { return }
            
            let baseForegroundColor = isEnabled ? style.foregroundColor : DesignSystemAsset.Colors.systemWhite.color
            let foregroundColor = isHighlighted ? baseForegroundColor.withAlphaComponent(0.6) : baseForegroundColor
            let backgroundColor = isEnabled ? style.backgroundColor : DesignSystemAsset.Colors.gray30.color
            let borderColor = isEnabled ? style.borderColor : nil
            
            config.attributedTitle = text.map {
                AttributedString($0, attributes: AttributeContainer([
                    .font: size.font,
                    .foregroundColor: foregroundColor
                ]))
            }
            config.image = renderedIcon
            config.imagePlacement = iconPlacement == .leading ? .leading : .trailing
            config.baseForegroundColor = foregroundColor
            config.background.backgroundColor = backgroundColor
            config.background.strokeColor = borderColor
            config.background.strokeWidth = borderColor == nil ? 0 : 1
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
        
        private func makeRenderedIcon() -> UIImage? {
            guard let icon else { return nil }
            
            let targetSize = size.iconSize
            let resizedIcon = icon.size == targetSize ? icon : UIGraphicsImageRenderer(size: targetSize).image { _ in
                icon.draw(in: CGRect(origin: .zero, size: targetSize))
            }
            return resizedIcon.withRenderingMode(.alwaysTemplate)
        }
    }
}
