import UIKit
import Combine

import DesignSystem

final class WriteDetailView: BaseView {
    private let bgTap = UITapGestureRecognizer().then {
        $0.cancelsTouchesInView = false
    }
    
    private let navigationView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
    }
    
    let backButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.arrowLeft.image, for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.text = "write_detail_title".localized
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    
    let closeButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.close.image, for: .normal)
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
    
    let writeButton = UIButton().then {
        $0.backgroundColor = DesignSystemAsset.Colors.mainPink.color
        $0.setTitle("write_store_register_button".localized, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
    }
    
    private let writeButtonBg = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.mainPink.color
    }
    
    override func setup() {
        addGestureRecognizer(bgTap)
        backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        addSubViews([
            navigationView,
            titleLabel,
            backButton,
            closeButton,
            collectionView,
            writeButton,
            writeButtonBg
        ])
        
        bgTap.addTarget(self, action: #selector(onTapBackground))
        setBackgroundColorObserver()
    }
    
    override func bindConstraints() {
        navigationView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(56)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalTo(navigationView)
        }
        
        backButton.snp.makeConstraints {
            $0.centerY.equalTo(navigationView)
            $0.left.equalToSuperview().offset(16)
            $0.width.height.equalTo(24)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(navigationView)
            $0.right.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(navigationView.snp.bottom)
            $0.bottom.equalTo(writeButton.snp.top)
        }
        
        writeButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        writeButtonBg.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setSaveButtonEnable(isEnable: Bool) {
        writeButton.isUserInteractionEnabled = isEnable
        writeButton.backgroundColor = isEnable ? DesignSystemAsset.Colors.mainPink.color : DesignSystemAsset.Colors.gray30.color
        writeButtonBg.backgroundColor = isEnable ? DesignSystemAsset.Colors.mainPink.color : DesignSystemAsset.Colors.gray30.color
    }
    
    func updateCollectionViewLayout(keyboardHeight: CGFloat) {
        if keyboardHeight == 0 {
            collectionView.snp.remakeConstraints {
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.top.equalTo(navigationView.snp.bottom)
                $0.bottom.equalTo(writeButton.snp.top)
            }
        } else {
            collectionView.snp.remakeConstraints {
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.top.equalTo(navigationView.snp.bottom)
                $0.bottom.equalToSuperview().offset(-keyboardHeight)
            }
        }
    }
    
    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }
    
    private func setBackgroundColorObserver() {
        collectionView.publisher(for: \.contentOffset)
            .withUnretained(self)
            .sink { owner, contentOffset in
                let isMinus = contentOffset.y <= 0
                owner.collectionView.backgroundColor = isMinus ? DesignSystemAsset.Colors.systemWhite.color : DesignSystemAsset.Colors.gray0.color
            }
            .store(in: &cancellables)
    }
    
    @objc private func onTapBackground() {
        endEditing(true)
    }
}
