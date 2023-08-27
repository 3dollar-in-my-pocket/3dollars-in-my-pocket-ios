import UIKit

import Common
import DesignSystem

final class SigninButton: UIButton {
    enum SocialType {
        case kakao
        case apple
        
        var title: String {
            switch self {
            case .kakao:
                return Strings.signinWithKakao
                
            case .apple:
                return Strings.signinWithApple
            }
        }
        
        var icon: UIImage {
            switch self {
            case .kakao:
                return Icons.kakao.image
                
            case .apple:
                return Icons.apple.image.withTintColor(Colors.systemWhite.color)
            }
        }
        
        var backgroundColor: UIColor? {
            switch self {
            case .kakao:
                return UIColor(hex: "#F7E317")
                
            case .apple:
                return Colors.systemBlack.color
            }
        }
        
        var textColor: UIColor? {
            switch self {
            case .kakao:
                return UIColor(hex: "#381E1F")
                
            case .apple:
                return Colors.systemWhite.color
            }
        }
    }
    
    private let socialType: SocialType
    
    init(type: SocialType) {
        self.socialType = type
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        layer.cornerRadius = 12
        imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        setTitleColor(socialType.textColor, for: .normal)
        setTitle(socialType.title, for: .normal)
        setImage(socialType.icon, for: .normal)
        backgroundColor = socialType.backgroundColor
        titleLabel?.font = Fonts.semiBold.font(size: 14)
    }
}
