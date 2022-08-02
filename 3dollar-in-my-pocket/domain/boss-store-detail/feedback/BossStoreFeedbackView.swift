import UIKit

import Base

final class BossStoreFeedbackView: Base.BaseView {
    private let navigationContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_black(), for: .normal)
    }
    
    override func setup() {
        self.backgroundColor = .white
        self.addSubViews([
            self.navigationContainerView,
            self.backButton
        ])
    }
    
    override func bindConstraints() {
        self.navigationContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(59)
        }
        
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalTo(self.navigationContainerView).offset(-21)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
    }
}
