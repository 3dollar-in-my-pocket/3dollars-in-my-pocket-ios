import UIKit

public class Button {
    public class Normal: UIButton {
        public enum Size {
            case h52
            case h34
            
            var height: CGFloat {
                switch self {
                case .h34:
                    return 34
                    
                case .h52:
                    return 52
                }
            }
            
            var iconSize: CGSize {
                switch self {
                case .h34:
                    return CGSize(width: 16, height: 16)
                    
                case .h52:
                    return CGSize(width: 24, height: 24)
                }
            }
        }
        
        public override var isEnabled: Bool {
            didSet {
                UIView.transition(with: self, duration: 0.1) {
                    self.backgroundColor = self.isEnabled ? DesignSystemAsset.Colors.mainPink.color : DesignSystemAsset.Colors.gray30.color
                }
            }
        }
        
        private let size: Size
        private var text: String?
        private var leftIcon: UIImage?
        
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
            case .h34:
                titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
                
            case .h52:
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
