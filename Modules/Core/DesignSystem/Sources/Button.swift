import UIKit

public class Button {
    public class Normal: UIButton {
        public enum Size {
            case medium
            case small
            
            var height: CGFloat {
                switch self {
                case .small:
                    return 34
                    
                case .medium:
                    return 48
                }
            }
            
            var iconSize: CGSize {
                switch self {
                case .small:
                    return CGSize(width: 16, height: 16)
                    
                case .medium:
                    return CGSize(width: 24, height: 24)
                }
            }
        }
        
        public override var isEnabled: Bool {
            didSet {
                UIView.transition(with: self, duration: 0.1) {
                    self.backgroundColor = self.isEnabled ? self.enabledBackgroundColor : self.disabledBackgroundColor
                }
            }
        }
        
        public var enabledBackgroundColor: UIColor = DesignSystemAsset.Colors.mainPink.color
        public var disabledBackgroundColor: UIColor = DesignSystemAsset.Colors.gray30.color
        
        private let size: Size
        private var text: String?
        public var leftIcon: UIImage? {
            didSet {
                setImage(leftIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
        
        public init(size: Size, text: String? = nil, leftIcon: UIImage? = nil) {
            self.size = size
            self.text = text
            self.leftIcon = leftIcon
            
            super.init(frame: .zero)
            setup()
            bindConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            setTitle(text, for: .normal)
            
            setupIcon()
            setupTitleLabel()
            backgroundColor = DesignSystemAsset.Colors.mainPink.color
            layer.cornerRadius = 12
            layer.masksToBounds = true
        }
        
        private func setupIcon() {
            guard let leftIcon = leftIcon else { return }
            setImage(leftIcon.withRenderingMode(.alwaysTemplate), for: .normal)
            imageView?.translatesAutoresizingMaskIntoConstraints = false
            imageView?.widthAnchor.constraint(equalToConstant: size.iconSize.width).isActive = true
            imageView?.heightAnchor.constraint(equalToConstant: size.iconSize.height).isActive = true
            
            if let titleLabel = titleLabel {
                imageView?.rightAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: -4).isActive = true
                imageView?.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
            }
            tintColor = DesignSystemAsset.Colors.systemWhite.color
        }
        
        private func setupTitleLabel() {
            switch size {
            case .small:
                titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
                
            case .medium:
                titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
            }
            
            setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        }
        
        private func bindConstraints() {
            translatesAutoresizingMaskIntoConstraints = false
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}
