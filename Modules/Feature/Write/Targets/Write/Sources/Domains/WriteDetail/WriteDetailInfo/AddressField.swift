import UIKit
import Combine

import Common

final class AddressField: BaseView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        label.text = "가게 위치 확인"
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray80.color
        return label
    }()
    
    private let changeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let button = UIButton()
        button.setTitle("위치 변경", for: .normal)
        button.setTitleColor(Colors.mainPink.color, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        return button
    }()
    
    var tapChangePublisher: AnyPublisher<Void, Never> {
        changeButton.tapPublisher
    }
    
    override func setup() {
        addSubViews([
            titleLabel,
            containerView,
            addressLabel,
            changeButton
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        addressLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalTo(containerView).inset(12)
            $0.trailing.lessThanOrEqualTo(changeButton.snp.leading).offset(10)
        }
        
        changeButton.snp.makeConstraints {
            $0.centerY.equalTo(addressLabel)
            $0.trailing.equalTo(containerView).offset(-12)
        }
    }
    
    func setAddress(_ address: String) {
        addressLabel.text = address
    }
}
