import UIKit

import Common
import DesignSystem

final class BossStoreCouponBottomSheet: BaseView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.regular.font(size: 24)
        label.text = "사장님께 보여주면\n쿠폰 혜택을 받을 수 있어요!"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray50.color
        label.font = Fonts.regular.font(size: 14)
        label.text = "쿠폰 사용 시 사용하기 버튼을 눌러주세요."
        label.textAlignment = .center
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.deleteX.image.withTintColor(Colors.gray70.color), for: .normal)
        
        return button
    }()
    
    let couponView = BossStoreCouponView()
    
    let useButton = Button.Normal(size: .h48, text: "사용하기")
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        addSubViews([
            titleLabel,
            descriptionLabel,
            closeButton,
            couponView,
            useButton
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(60)
            $0.top.equalToSuperview().offset(50)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(60)
        }
        
        couponView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(30)
        }
       
        useButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(couponView.snp.bottom).offset(28)
        }
    }
}
