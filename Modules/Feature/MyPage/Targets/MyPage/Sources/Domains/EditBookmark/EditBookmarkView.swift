import UIKit

import Common
import DesignSystem

final class EditBookmarkView: BaseView {
    let backButton: UIButton = {
        let button = UIButton()
        let image = Icons.arrowLeft.image.withTintColor(Colors.systemWhite.color)
        
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.systemWhite.color
        label.text = "정보 수정하기"
        
        return label
    }()
    
    private let editTitleView = EditBookmarkTitleView()
    
    private let editDescriptionVIew = EditBookmarkDescriptionView()
    
    let saveButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("저장하기", for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 16)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.backgroundColor = Colors.mainPink.color
        return button
    }()
    
    private let bottomBackgroundView: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.mainPink.color
        return view
    }()
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        addSubViews([
            backButton,
            titleLabel,
            editTitleView,
            editDescriptionVIew,
            saveButton,
            bottomBackgroundView
        ])
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        editTitleView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(27)
            $0.trailing.equalToSuperview()
        }
        
        editDescriptionVIew.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(editTitleView.snp.bottom).offset(41)
            $0.trailing.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        bottomBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}
