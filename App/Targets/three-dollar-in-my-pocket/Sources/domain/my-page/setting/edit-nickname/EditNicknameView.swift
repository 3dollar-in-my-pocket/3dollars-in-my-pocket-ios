import UIKit

import RxSwift
import RxCocoa

final class EditNicknameView: BaseView {
    let tapGestureView = UITapGestureRecognizer()
    
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back_white"), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "edit_nickname_title".localized
        $0.textColor = .white
        $0.font = .semiBold(size: 16)
    }
    
    private let backgroundCloud = UIImageView().then {
        $0.image = UIImage(named: "bg_cloud")
        $0.contentMode = .scaleToFill
    }
    
    private let oldNicknameLabel = UILabel().then {
        $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
        $0.font = .bold(size: 32)
    }
    
    private let nicknameLabel1 = UILabel().then {
        $0.text = "edit_nickname_label1".localized
        $0.textColor = .white
        $0.font = .bold(size: 32)
    }
    
    private let nicknameFieldBackgground = UIView().then {
        $0.layer.cornerRadius = 28
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
        $0.backgroundColor = .clear
    }
    
    let nicknameField = UITextField().then {
        $0.font = .bold(size: 32)
        $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "edit_nickname_placeholder".localized,
            attributes: [.foregroundColor: UIColor.init(r: 243, g: 162, b: 169, a: 0.4)]
        )
    }
    
    private let nicknameLabel2 = UILabel().then {
        $0.text = "edit_nickname_label2".localized
        $0.font = .bold(size: 32)
        $0.textColor = .white
    }
    
    let editLabelButton = UIButton().then {
        $0.setTitle("edit_nickname_edit_label".localized, for: .normal)
        $0.titleLabel?.font = .bold(size: 32)
        $0.setTitleColor(.white, for: .disabled)
        $0.setTitleColor(UIColor.init(r: 238, g: 98, b: 76), for: .normal)
        $0.isEnabled = false
    }
    
    let editImageButton = UIButton().then {
        $0.setImage(UIImage(named: "img_start_off_disable"), for: .disabled)
        $0.setImage(UIImage(named: "img_start_off_normal"), for: .normal)
        $0.backgroundColor = .clear
        $0.isEnabled = false
    }
    
    private let warningImage = UIImageView().then {
        $0.image = UIImage(named: "ic_warning")
        $0.isHidden = true
    }
    
    private let warningLabel = UILabel().then {
        $0.text = "nickname_alreay_existed".localized
        $0.textColor = UIColor.init(r: 238, g: 98, b: 76)
        $0.font = .medium(size: 13)
        $0.isHidden = true
    }
    
    override func setup() {
        self.backgroundColor = Color.gray100
        self.addGestureRecognizer(self.tapGestureView)
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.backgroundCloud,
            self.oldNicknameLabel,
            self.nicknameLabel1,
            self.nicknameFieldBackgground,
            self.nicknameField,
            self.nicknameLabel2,
            self.editLabelButton,
            self.editImageButton,
            self.warningImage,
            self.warningLabel
        ])
        self.nicknameField.delegate = self
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(15)
            make.width.height.equalTo(48)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.backButton.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        self.backgroundCloud.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.backButton.snp.bottom).offset(44)
        }
        
        self.oldNicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.backgroundCloud.snp.left).offset(24)
            make.top.equalTo(self.backgroundCloud.snp.top).offset(130)
        }
        
        self.nicknameLabel1.snp.makeConstraints { (make) in
            make.left.equalTo(self.oldNicknameLabel.snp.right).offset(5)
            make.centerY.equalTo(self.oldNicknameLabel.snp.centerY)
        }
        
        self.nicknameFieldBackgground.snp.makeConstraints { (make) in
            make.left.equalTo(self.oldNicknameLabel.snp.left)
            make.top.equalTo(self.oldNicknameLabel.snp.bottom).offset(16 * RatioUtils.heightRatio)
            make.height.equalTo(56)
            make.width.equalTo(282)
        }
        
        self.nicknameField.snp.makeConstraints { (make) in
            make.left.equalTo(self.nicknameFieldBackgground.snp.left).offset(20)
            make.top.equalTo(self.nicknameFieldBackgground.snp.top)
            make.bottom.equalTo(self.nicknameFieldBackgground.snp.bottom)
            make.right.equalTo(self.nicknameFieldBackgground.snp.right).offset(-20)
        }
        
        self.nicknameLabel2.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.nicknameFieldBackgground.snp.centerY)
            make.left.equalTo(self.nicknameFieldBackgground.snp.right).offset(14)
        }
        
        self.editLabelButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.oldNicknameLabel.snp.left)
            make.top.equalTo(self.nicknameFieldBackgground.snp.bottom)
                .offset(16 * RatioUtils.heightRatio)
            make.height.equalTo(38)
        }
        
        self.editImageButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.editLabelButton.snp.centerY)
            make.left.equalTo(self.editLabelButton.snp.right).offset(8)
        }
        
        self.warningImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.editLabelButton)
            make.left.equalTo(self.editImageButton.snp.right).offset(8)
            make.width.height.equalTo(12)
        }
        
        self.warningLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.warningImage)
            make.left.equalTo(self.warningImage.snp.right).offset(5)
        }
    }
    
    func bind(nickname: String) {
        self.oldNicknameLabel.text = nickname
    }
    
    fileprivate func setButtonEnable(isEnable: Bool) {
        self.editLabelButton.isEnabled = isEnable
        self.editImageButton.isEnabled = isEnable
    }
    
    fileprivate func setHiddenWarning(isHidden: Bool) {
        self.warningLabel.isHidden = isHidden
        self.warningImage.isHidden = isHidden
    }
}

extension Reactive where Base: EditNicknameView {
    var isEnableEditButton: Binder<Bool> {
        return Binder(self.base) { view, isEnable in
            view.setButtonEnable(isEnable: isEnable)
        }
    }
    
    var isHiddenWarning: Binder<Bool> {
        return Binder(self.base) { view, isHidden in
            view.setHiddenWarning(isHidden: isHidden)
        }
    }
}

extension EditNicknameView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        return count <= 8
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
