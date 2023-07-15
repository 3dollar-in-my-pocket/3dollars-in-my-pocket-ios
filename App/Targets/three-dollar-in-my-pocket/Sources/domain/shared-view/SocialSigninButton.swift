import UIKit

import DesignSystem
import RxSwift
import RxCocoa

final class SocialSigninButton: BaseView {
    fileprivate let containerButton = UIButton().then {
        $0.layer.cornerRadius = 12
    }
    
    private let stackView = UIStackView().then {
        $0.spacing = 8
        $0.axis = .horizontal
        $0.isUserInteractionEnabled = false
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.isAccessibilityElement = false
    }
    
    let socialImage = UIImageView()
    
    init(socialType: SocialType) {
        super.init(frame: .zero)
        
        self.bind(socialType: socialType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        self.stackView.addArrangedSubview(self.socialImage)
        self.stackView.addArrangedSubview(self.titleLabel)
        
        self.addSubViews([
            self.containerButton,
            self.stackView
        ])
    }
    
    override func bindConstraints() {
        self.containerButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.center.equalTo(self.containerButton)
        }
        
        self.socialImage.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
        }
    }
    
    private func bind(socialType: SocialType) {
        switch socialType {
        case .kakao:
            self.containerButton.accessibilityLabel = "sign_in_with_kakao".localized
            self.containerButton.backgroundColor = Color.kakaoYellow
            self.titleLabel.text = "sign_in_with_kakao".localized
            self.titleLabel.textColor = UIColor.init(r: 56, g: 30, b: 31)
            self.socialImage.image = UIImage(named: "ic_kakao")
            
        case .apple:
            self.containerButton.accessibilityLabel = "sign_in_with_apple".localized
            self.containerButton.backgroundColor = DesignSystemAsset.Colors.systemBlack.color
            self.titleLabel.text = "sign_in_with_apple".localized
            self.titleLabel.textColor = DesignSystemAsset.Colors.systemWhite.color
            self.socialImage.image = UIImage(named: "ic_apple")
            
        default:
            break
        }
    }
}

extension Reactive where Base: SocialSigninButton {
    var tap: ControlEvent<Void> {
        return base.containerButton.rx.tap
    }
}
