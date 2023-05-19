import UIKit

import RxSwift
import RxCocoa

final class NicknameView: BaseView {
    fileprivate let tapGestureView = UITapGestureRecognizer()
    
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back_white"), for: .normal)
    }
    
    private let backgroundCloud = UIImageView().then {
        $0.image = UIImage(named: "bg_cloud")
        $0.contentMode = .scaleToFill
    }
    
    private let nicknameLabel1 = UILabel().then {
        $0.text = "nickname_label_1".localized
        $0.font = .bold(size: 32)
        $0.textColor = .white
    }
    
    private let nicknameFieldBackground = UIView().then {
        $0.layer.cornerRadius = 28
        $0.layer.borderWidth = 2
        $0.layer.borderColor = Color.pink?.cgColor
        $0.backgroundColor = .clear
    }
    
    let nicknameField = UITextField().then {
        $0.font = .bold(size: 32)
        $0.textColor = Color.pink
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "nickname_placeholder".localized,
            attributes: [
                .foregroundColor: Color.pink?.withAlphaComponent(0.3) as Any
            ]
        )
    }
    
    private let nicknameLabel2 = UILabel().then {
        $0.text = "nickname_label_2".localized
        $0.font = .bold(size: 32)
        $0.textColor = .white
    }
    
    let startButton1 = UIButton().then {
        $0.setTitle("nickname_label_3".localized, for: .normal)
        $0.titleLabel?.font = .bold(size: 32)
        $0.setTitleColor(.white, for: .disabled)
        $0.setTitleColor(Color.red, for: .normal)
        $0.isEnabled = false
    }
    
    let startButton2 = UIButton().then {
        $0.setImage(UIImage(named: "img_start_off_disable"), for: .disabled)
        $0.setImage(UIImage(named: "img_start_off_normal"), for: .normal)
        $0.backgroundColor = .clear
        $0.isEnabled = false
    }
    
    fileprivate let warningImage = UIImageView().then {
        $0.image = UIImage(named: "ic_warning")
        $0.isHidden = true
    }
    
    fileprivate let warningLabel = UILabel().then {
        $0.text = "nickname_alreay_existed".localized
        $0.textColor = Color.red
        $0.font = .medium(size: 13)
        $0.isHidden = true
    }
    
    
    override func setup() {
        self.backgroundColor = Color.gray100
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(self.tapGestureView)
        self.nicknameField.delegate = self
        self.addSubViews([
            backButton,
            backgroundCloud,
            nicknameLabel1,
            nicknameFieldBackground,
            nicknameField,
            nicknameLabel2,
            startButton1,
            startButton2,
            warningImage,
            warningLabel
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(48)
        }
        
        self.backgroundCloud.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(44)
        }
        
        self.nicknameLabel1.snp.makeConstraints { (make) in
            make.left.equalTo(backgroundCloud.snp.left).offset(24)
            make.top.equalTo(backgroundCloud.snp.top).offset(161)
        }
        
        self.nicknameFieldBackground.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameLabel1.snp.left)
            make.top.equalTo(nicknameLabel1.snp.bottom).offset(16)
            make.height.equalTo(56)
            make.width.equalTo(282)
        }
        
        self.nicknameField.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameFieldBackground.snp.left).offset(20)
            make.top.equalTo(nicknameFieldBackground.snp.top)
            make.bottom.equalTo(nicknameFieldBackground.snp.bottom)
            make.right.equalTo(nicknameFieldBackground.snp.right).offset(-20)
        }
        
        self.nicknameLabel2.snp.makeConstraints { (make) in
            make.centerY.equalTo(nicknameFieldBackground.snp.centerY)
            make.left.equalTo(nicknameFieldBackground.snp.right).offset(14)
        }
        
        self.startButton1.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameLabel1.snp.left)
            make.top.equalTo(nicknameFieldBackground.snp.bottom).offset(16)
            make.height.equalTo(38)
        }
        
        self.startButton2.snp.makeConstraints { (make) in
            make.centerY.equalTo(startButton1.snp.centerY)
            make.left.equalTo(startButton1.snp.right).offset(8)
        }
        
        self.warningImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(startButton1)
            make.left.equalTo(startButton2.snp.right).offset(8)
            make.width.height.equalTo(12)
        }
        
        self.warningLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(warningImage)
            make.left.equalTo(warningImage.snp.right).offset(5)
        }
    }
    
    func hideKeyboard() {
        self.nicknameField.resignFirstResponder()
    }
    
    private func showKeyboard() {
        self.nicknameField.becomeFirstResponder()
    }
}

extension NicknameView: UITextFieldDelegate {
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
        self.hideKeyboard()
        
        return true
    }
}

extension Reactive where Base: NicknameView {
    var tapBackground: ControlEvent<Void> {
        return ControlEvent(events: base.tapGestureView.rx.event.map { _ in () })
    }
    
    var isStartButtonEnable: Binder<Bool> {
        return Binder(self.base) { view, isEnable in
            view.startButton1.isEnabled = isEnable
            view.startButton2.isEnabled = isEnable
        }
    }
    
    var isErrorLabelHidden: Binder<Bool> {
        return Binder(self.base) { view, isHidden in
            view.warningImage.isHidden = isHidden
            view.warningLabel.isHidden = isHidden
        }
    }
}
