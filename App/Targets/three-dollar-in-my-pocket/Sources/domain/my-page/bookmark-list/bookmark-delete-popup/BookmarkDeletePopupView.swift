import UIKit

final class BookmarkDeletePopupView: BaseView {
    let backgroundButton = UIButton()
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 30
        $0.backgroundColor = Color.gray80
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 18)
        $0.text = "bookmark_list_delete_popup_title".localized
        $0.numberOfLines = 0
        $0.textColor = Color.gray0
    }
    
    let cancelButton = UIButton().then {
        $0.setTitle("bookmark_list_delete_popup_cancel".localized, for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitleColor(Color.gray5, for: .normal)
        $0.backgroundColor = Color.gray60
        $0.layer.cornerRadius = 24
        $0.contentEdgeInsets = .init(top: 0, left: 44, bottom: 0, right: 44)
    }
    
    let deleteButton = UIButton().then {
        $0.setTitle("bookmark_list_delete_popup_delete".localized, for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = Color.red
        $0.layer.cornerRadius = 24
        $0.contentEdgeInsets = .init(top: 0, left: 44, bottom: 0, right: 44)
    }
    
    override func setup() {
        self.addSubViews([
            self.backgroundButton,
            self.containerView,
            self.titleLabel,
            self.cancelButton,
            self.deleteButton
        ])
    }
    
    override func bindConstraints() {
        self.backgroundButton.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.right.equalToSuperview().offset(-28)
            make.centerY.equalToSuperview()
            make.height.equalTo(154)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(20)
            make.top.equalTo(self.containerView).offset(20)
        }
        
        self.cancelButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.snp.centerX).offset(-6)
            make.height.equalTo(48)
            make.bottom.equalTo(self.containerView).offset(-16)
        }
        
        self.deleteButton.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX).offset(6)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.cancelButton)
            make.bottom.equalTo(self.cancelButton)
        }
    }
}
