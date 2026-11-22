import UIKit

import Common
import DesignSystem

final class BossStoreCouponAlertView: BaseView {
    private let containerView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 16
        view.backgroundColor = Colors.systemWhite.color
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "이 쿠폰은 단 한 번 사용 가능해요!\n정말 사용하시겠어요?"
        label.numberOfLines = 0
        label.textColor = Colors.gray100.color
        label.font = Fonts.semiBold.font(size: 20)
        label.setLineHeight(lineHeight: 28)
        return label
    }()
    
    let cancelButton = Button.Normal(size: .medium, style: .dark, text: "취소")
    
    let deleteButton = Button.Normal(size: .medium, style: .destructive, text: "사용하기")
    
    override func setup() {
        addSubViews([
            containerView,
            titleLabel,
            cancelButton,
            deleteButton
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(172)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(containerView).offset(28)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(28)
            $0.trailing.equalTo(snp.centerX).offset(-6)
            $0.bottom.equalTo(containerView).offset(-28)
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-28)
            $0.leading.equalTo(snp.centerX).offset(6)
            $0.top.equalTo(cancelButton)
            $0.bottom.equalTo(cancelButton)
        }
    }
}
