import UIKit

import Common
import DesignSystem
import NMapsMap
import SnapKit
import Then

final class HomeView: BaseView {
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
    }
    
    let addressButton = AddressButton()
    
    let categoryFilterButton = UIButton().then {
        $0.layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        $0.layer.borderWidth = 1
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 10
        $0.setTitle("전체 메뉴", for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.gray70.color, for: .normal)
        $0.setImage(DesignSystemAsset.Icons.category.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.gray70.color), for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        $0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 14)
    }
    
    let sortingButton = SortingButton()
    
    let onlyBossToggleButton = OnlyBossToggleButton()
    
    let currentLocationButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.locationCurrent.image.withTintColor(DesignSystemAsset.Colors.systemBlack.color), for: .normal)
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.borderWidth = 1
        $0.layer.borderColor = DesignSystemAsset.Colors.gray20.color.cgColor
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = DesignSystemAsset.Colors.systemBlack.color.cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowOpacity = 0.1
    }
    
    let viewTypeButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Icons.list.image.resizeImage(scaledTo: 16).withTintColor(DesignSystemAsset.Colors.systemWhite.color), for: .normal)
        $0.setTitle("리스트뷰", for: .normal)
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
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.register([HomeCell.self])
        $0.backgroundColor = .clear
        $0.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = false
    }
    
    override func setup() {
        addSubViews([
            mapView,
            addressButton,
            categoryFilterButton,
            sortingButton,
            onlyBossToggleButton,
            currentLocationButton,
            viewTypeButton,
            collectionView
        ])
    }
    
    override func bindConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }
        
        addressButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
        }
        
        categoryFilterButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalTo(addressButton.snp.bottom).offset(14)
            $0.height.equalTo(34)
        }
        
        sortingButton.snp.makeConstraints {
            $0.left.equalTo(categoryFilterButton.snp.right).offset(10)
            $0.centerY.equalTo(categoryFilterButton)
            $0.height.equalTo(34)
        }
        
        onlyBossToggleButton.snp.makeConstraints {
            $0.left.equalTo(sortingButton.snp.right).offset(10)
            $0.centerY.equalTo(categoryFilterButton)
            $0.height.equalTo(34)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.bottom.equalTo(collectionView.snp.top).offset(-16)
            $0.width.height.equalTo(40)
        }
        
        viewTypeButton.snp.makeConstraints {
            $0.centerY.equalTo(currentLocationButton)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-15)
            $0.height.equalTo(HomeCell.Layout.size.height)
        }
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = HomeCardFlowLayout()
        layout.itemSize = HomeCell.Layout.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        return layout
    }
}
