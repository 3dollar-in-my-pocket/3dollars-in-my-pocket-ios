import UIKit

import Common
import DesignSystem

final class BookmarkListView: BaseView {
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
        label.text = "즐겨찾기"
        
        return label
    }()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let shareButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("공유하기", for: .normal)
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
            collectionView,
            bottomBackgroundView,
            shareButton,
        ])
        
        collectionView.backgroundColor = .clear
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
        
        shareButton.snp.makeConstraints {
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
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(shareButton.snp.top)
            $0.top.equalTo(backButton.snp.bottom).offset(16)
        }
    }
    
    func setEnableShare(_ isEnable: Bool) {
        let backgroundColor = isEnable ? Colors.mainPink.color : Colors.gray80.color
        let titleColor = isEnable ? Colors.systemWhite.color : Colors.gray60.color 
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            shareButton.isEnabled = !isEnable
            shareButton.backgroundColor = backgroundColor
            shareButton.setTitleColor(titleColor, for: .normal)
            bottomBackgroundView.backgroundColor = backgroundColor
        }
    }
}
