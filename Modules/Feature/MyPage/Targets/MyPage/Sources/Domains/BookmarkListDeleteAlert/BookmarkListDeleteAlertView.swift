import UIKit

import Common
import DesignSystem

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
    
    let cancelButton = Button.Normal(size: .medium, style: .dark, text: "취소")
    
    let deleteButton = Button.Normal(size: .medium, style: .destructive, text: "모두 삭제")
    
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
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-28)
            $0.leading.equalTo(snp.centerX).offset(6)
            $0.top.equalTo(cancelButton)
            $0.bottom.equalTo(cancelButton)
        }
    }
}
