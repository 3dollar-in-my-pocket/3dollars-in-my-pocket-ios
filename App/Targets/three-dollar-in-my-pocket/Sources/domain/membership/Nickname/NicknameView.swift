import UIKit

import Common
import DesignSystem

import RxSwift
import RxCocoa

final class NicknameView: Common.BaseView {
    private let tapGestureView = UITapGestureRecognizer()
    
    let backButton = UIButton().then {
        $0.setImage(
            DesignSystemAsset.Icons.arrowLeft.image.withTintColor(DesignSystemAsset.Colors.systemWhite.color),
            for: .normal
        )
    }
    
    private let imageView = UIImageView(image: ThreeDollarInMyPocketAsset.Assets.imageBungeoppang.image).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let nicknameLabel1 = UILabel().then {
        $0.text = ThreeDollarInMyPocketStrings.nicknameLabel1
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 30)
        $0.textColor = DesignSystemAsset.Colors.systemWhite.color
    }
    
    let nicknameField = UITextField().then {
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 30)
        $0.textColor = DesignSystemAsset.Colors.mainPink.color
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: ThreeDollarInMyPocketStrings.nicknamePlaceholder,
            attributes: [
                .foregroundColor: DesignSystemAsset.Colors.gray80.color as Any
            ]
        )
    }
    
    private let nicknameLabel2 = UILabel().then {
        $0.text = ThreeDollarInMyPocketStrings.nicknameLabel2
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 30)
        $0.textColor = DesignSystemAsset.Colors.systemWhite.color
    }
    
    private let warningImage = UIImageView().then {
        $0.image = DesignSystemAsset.Icons.infomation.image.withTintColor(DesignSystemAsset.Colors.mainRed.color)
        $0.isHidden = true
    }
    
    private let warningLabel = PaddingLabel(topInset: 8, bottomInset: 8, leftInset: 12, rightInset: 12).then {
        $0.text = ThreeDollarInMyPocketStrings.nicknameAlreayExisted
        $0.textColor = DesignSystemAsset.Colors.mainRed.color
        $0.backgroundColor = DesignSystemAsset.Colors.mainRed.color.withAlphaComponent(0.1)
        $0.layer.cornerRadius = 16
        $0.isHidden = true
    }
    
    let signinButton = UIButton().then {
        $0.setTitle(ThreeDollarInMyPocketStrings.nicknameAlreayExisted, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        $0.setTitleColor(DesignSystemAsset.Colors.gray60.color, for: .disabled)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        $0.setBackgroundColor(DesignSystemAsset.Colors.gray80.color, for: .disabled)
        $0.setBackgroundColor(DesignSystemAsset.Colors.mainPink.color, for: .normal)
        $0.isEnabled = false
    }
    
    private let bottomBackground = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray80.color
    }
    
    
    override func setup() {
        backgroundColor = DesignSystemAsset.Colors.gray100.color
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureView)
        nicknameField.delegate = self
        
        addSubViews([
            backButton,
            imageView,
            nicknameLabel1,
            nicknameField,
            nicknameLabel2,
            warningImage,
            warningLabel,
            signinButton,
            bottomBackground
        ])
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.width.height.equalTo(24)
        }

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(nicknameLabel1.snp.top).offset(-14)
            $0.height.equalTo(96)
        }
        
        nicknameLabel1.snp.makeConstraints {
            $0.bottom.equalTo(nicknameField.snp.top).offset(-6)
            $0.centerX.equalToSuperview()
        }
        
        nicknameField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        nicknameLabel2.snp.makeConstraints {
            $0.top.equalTo(nicknameField.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }

        bottomBackground.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        signinButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(bottomBackground.snp.top)
            $0.height.equalTo(64)
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

//extension Reactive where Base: NicknameView {
//    var tapBackground: ControlEvent<Void> {
//        return ControlEvent(events: base.tapGestureView.rx.event.map { _ in () })
//    }
//    
//    var isStartButtonEnable: Binder<Bool> {
//        return Binder(self.base) { view, isEnable in
//            view.startButton1.isEnabled = isEnable
//            view.startButton2.isEnabled = isEnable
//        }
//    }
//    
//    var isErrorLabelHidden: Binder<Bool> {
//        return Binder(self.base) { view, isHidden in
//            view.warningImage.isHidden = isHidden
//            view.warningLabel.isHidden = isHidden
//        }
//    }
//}
