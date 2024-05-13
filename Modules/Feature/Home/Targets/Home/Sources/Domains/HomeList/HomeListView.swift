import UIKit

import SnapKit
import Common
import DesignSystem
import AppInterface
import Model

final class HomeListView: BaseView {
    private let homeFilterSelectable: HomeFilterSelectable
    
    private lazy var homeFilterCollectionView = HomeFilterCollectionView(homeFilterSelectable: homeFilterSelectable)
    
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
    
    init(homeFilterSelectable: HomeFilterSelectable) {
        self.homeFilterSelectable = homeFilterSelectable
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        backgroundColor = DesignSystemAsset.Colors.gray0.color
        
        addSubViews([
            homeFilterCollectionView,
            adBannerView,
            collectionView,
            mapViewButton
        ])
    }
    
    override func bindConstraints() {
        homeFilterCollectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.right.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        adBannerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(homeFilterCollectionView.snp.bottom)
            $0.height.equalTo(49)
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
    
    func bindAdvertisement(in rootViewController: UIViewController) {
        adBannerView.load(in: rootViewController)
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
