import UIKit

final class DeleteModalView: BaseView {
    let tapBackground = UITapGestureRecognizer()
    
    private let backgroundView = UIView()
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "store_delete_title".localized
        $0.font = .light(size: 24)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    let closeButton = UIButton().then {
        $0.setImage(R.image.ic_close_24(), for: .normal)
    }
    
    private let descLabel = UILabel().then {
        $0.text = "store_delete_description".localized
        $0.font = .semiBold(size: 14)
        $0.textColor = UIColor(r: 137, g: 137, b: 137)
    }
    
    let deleteMenuStackView = DeleteMenuStackView()
    
    let deleteButton = UIButton().then {
        $0.setTitle("store_delete_request_button".localized, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
        $0.setBackgroundColor(UIColor.init(r: 255, g: 92, b: 67), for: .normal)
        $0.setBackgroundColor(UIColor.init(r: 208, g: 208, b: 208), for: .disabled)
        $0.isEnabled = false
        $0.layer.cornerRadius = 14
        $0.layer.masksToBounds = true
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.backgroundView.addGestureRecognizer(self.tapBackground)
        self.addSubViews([
            self.backgroundView,
            self.containerView,
            self.deleteButton,
            self.titleLabel,
            self.closeButton,
            self.descLabel,
            self.deleteMenuStackView,
            self.deleteButton
        ])
    }
    
    override func bindConstraints() {
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        self.containerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            make.top.equalTo(self.titleLabel).offset(-32)
        }
        
        self.deleteButton.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(24)
            make.right.equalTo(containerView).offset(-24)
            make.bottom.equalTo(containerView).offset(-26)
            make.height.equalTo(48)
        }
        
        self.deleteMenuStackView.snp.makeConstraints { make in
            make.left.right.equalTo(self.deleteButton)
            make.bottom.equalTo(self.deleteButton.snp.top).offset(-29)
        }
        
        self.descLabel.snp.makeConstraints { make in
            make.left.equalTo(self.deleteButton)
            make.bottom.equalTo(self.deleteMenuStackView.snp.top).offset(-24)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.deleteButton)
            make.bottom.equalTo(self.descLabel.snp.top).offset(-9)
        }
        
        self.closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel)
            make.right.equalTo(self.deleteButton)
            make.width.height.equalTo(24)
        }
    }
}
