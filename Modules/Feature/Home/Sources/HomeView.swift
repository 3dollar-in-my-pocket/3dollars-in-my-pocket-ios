import UIKit

import Common
import DesignSystem
import NMapsMap
import SnapKit
import Then

public final class HomeView: BaseView {
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
    
    let sortingButton = UIButton().then {
        $0.layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        $0.layer.borderWidth = 1
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 10
        $0.setTitle("거리순 보기", for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.gray70.color, for: .normal)
        $0.setImage(DesignSystemAsset.Icons.change.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.gray70.color), for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        $0.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 14)
    }
    
    let onlyBossToggleButton = OnlyBossToggleButton()
    
    public override func setup() {
        addSubViews([
            mapView,
            addressButton,
            categoryFilterButton,
            sortingButton,
            onlyBossToggleButton
        ])
    }
    
    public override func bindConstraints() {
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
    }
}
