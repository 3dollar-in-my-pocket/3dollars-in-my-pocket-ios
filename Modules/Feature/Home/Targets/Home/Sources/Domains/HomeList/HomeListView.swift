import UIKit

import SnapKit
import Common
import DesignSystem
import AppInterface
import Model

final class HomeListView: BaseView {
    let categoryFilterButton = CategoryFilterButton()
    
    let sortingButton = SortingButton()
    
    let onlyBossToggleButton = OnlyBossToggleButton()
    
    let adBannerView: AdBannerViewProtocol = {
        let view = Environment.appModuleInterface.createAdBannerView(adType: .homeList)
        
        view.backgroundColor = DesignSystemAsset.Colors.gray0.color
        return view
    }()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
    }
    
    let mapViewButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.map.image.resizeImage(scaledTo: 16).withTintColor(DesignSystemAsset.Colors.systemWhite.color), for: .normal)
        $0.setTitle(HomeStrings.categoryFileterMapView, for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.layer.cornerRadius = 20
        $0.backgroundColor = DesignSystemAsset.Colors.gray80.color
        $0.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        $0.contentEdgeInsets = .init(top: 11, left: 12, bottom: 11, right: 16)
        $0.layer.shadowColor = DesignSystemAsset.Colors.systemBlack.color.cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowOpacity = 0.1
    }
    
    private var adBannerViewHeightConstraint: Constraint?
    
    override func setup() {
        backgroundColor = DesignSystemAsset.Colors.gray0.color
        
        addSubViews([
            categoryFilterButton,
            sortingButton,
            onlyBossToggleButton,
            adBannerView,
            collectionView,
            mapViewButton
        ])
    }
    
    override func bindConstraints() {
        categoryFilterButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(22)
            $0.top.equalTo(safeAreaLayoutGuide).offset(13)
        }
        
        sortingButton.snp.makeConstraints {
            $0.centerY.equalTo(categoryFilterButton)
            $0.left.equalTo(categoryFilterButton.snp.right).offset(10)
        }
        
        onlyBossToggleButton.snp.makeConstraints {
            $0.centerY.equalTo(categoryFilterButton)
            $0.left.equalTo(sortingButton.snp.right).offset(10)
        }
        
        adBannerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(categoryFilterButton.snp.bottom).offset(13)
            adBannerViewHeightConstraint = $0.height.equalTo(49).constraint
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(adBannerView.snp.bottom)
        }
        
        mapViewButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
        }
    }
    
    func bindAdvertisement(isHidden: Bool, in rootViewController: UIViewController) {
        adBannerView.isHidden = isHidden
        adBannerViewHeightConstraint?.update(offset: isHidden ? 0 : 49)
        if !isHidden {
            adBannerView.load(in: rootViewController)
        }
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.headerReferenceSize = HomeListHeaderCell.Layout.size
        
        return layout
    }
}
