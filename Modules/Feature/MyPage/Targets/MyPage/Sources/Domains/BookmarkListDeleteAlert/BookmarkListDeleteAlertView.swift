import UIKit

import Common

final class BookmarkListDeleteAlertView: BaseView {
    private let containerView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 16
        view.backgroundColor = Colors.gray90.color
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "나의 즐겨찾기 리스트를\n모두 삭제할까요?"
        label.numberOfLines = 0
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.bold.font(size: 16)
        label.setLineHeight(lineHeight: 24)
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("취소", for: .normal)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.backgroundColor = Colors.gray80.color
        button.layer.cornerRadius = 12
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("모두 삭제", for: .normal)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.backgroundColor = Colors.mainRed.color
        button.layer.cornerRadius = 12
        return button
    }()
    
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
            $0.height.equalTo(176)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(containerView).offset(28)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(28)
            $0.trailing.equalTo(snp.centerX).offset(-6)
            $0.bottom.equalTo(containerView).offset(-28)
            $0.height.equalTo(48)
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-28)
            $0.leading.equalTo(snp.centerX).offset(6)
            $0.top.equalTo(cancelButton)
            $0.bottom.equalTo(cancelButton)
            $0.height.equalTo(cancelButton)
        }
    }
}
