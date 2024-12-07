import UIKit

import Common
import DesignSystem
import Model
import AppInterface

final class StoreDetailOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 437
    }
    
    let titleView = StoreDetailOverviewTitleView()
    
    let menuView = StoreDetailOverviewMenuView()
    
    let mapView = StoreDetailOverviewMapView()
    
    let bossTooltipView = TooltipView(emoji: "💌", message: Strings.StoreDetail.Tooltip.bookmark, tailDirection: .topLeft)
    
    let adBannerView: AdBannerViewProtocol = {
        let view = Environment.appModuleInterface.createAdBannerView(adType: .storeDetail)
        
        view.backgroundColor = DesignSystemAsset.Colors.gray0.color
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleView.prepareForReuse()
        mapView.prepareForReuse()
    }
    
    override func setup() {
        addSubViews([
            titleView,
            menuView,
            mapView,
            adBannerView,
            bossTooltipView
        ])
    }
    
    override func bindConstraints() {
        titleView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
            $0.right.equalToSuperview()
            $0.height.equalTo(StoreDetailOverviewTitleView.Layout.height)
        }
        
        menuView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(titleView.snp.bottom).offset(20)
            $0.height.equalTo(StoreDetailOverviewMenuView.Layout.height)
            $0.right.equalToSuperview()
        }
        
        bossTooltipView.snp.makeConstraints {
            $0.top.equalTo(menuView.snp.bottom).offset(-12)
            $0.left.equalTo(menuView).offset(12)
        }
        
        mapView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(menuView.snp.bottom).offset(24)
            $0.right.equalToSuperview()
            $0.bottom.equalTo(adBannerView.snp.top).offset(-12)
        }
        
        adBannerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(49)
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
    
    func bind(_ viewModel: StoreDetailOverviewCellViewModel, rootViewController: UIViewController) {
        titleView.bind(viewModel.output.overview)
        mapView.bind(
            location: viewModel.output.overview.location,
            address: viewModel.output.overview.address
        )
        menuView.bind(viewModel.output.menuList)
        menuView.favoriteButton.label.text = "\(viewModel.output.overview.subscribersCount)"
        menuView.favoriteButton.isSelected = viewModel.output.overview.isFavorited
        menuView.favoriteButton.setCount(viewModel.output.overview.subscribersCount)
        adBannerView.load(in: rootViewController)
        
        bossTooltipView.didTap = { [weak viewModel] in
            viewModel?.input.didTapTooltip.send(())
        }
        
        menuView.favoriteButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapFavorite)
            .store(in: &cancellables)
        
        menuView.shareButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapShare)
            .store(in: &cancellables)
        
        menuView.navigationButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapNavigation)
            .store(in: &cancellables)
        
        menuView.reviewButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapWriteReview)
            .store(in: &cancellables)

        menuView.snsButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapSnsButton)
            .store(in: &cancellables)

        mapView.addressButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapAddress)
            .store(in: &cancellables)
        
        mapView.zoomButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapMapDetail)
            .store(in: &cancellables)
        
        viewModel.output.isFavorited
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSelected, on: menuView.favoriteButton)
            .store(in: &cancellables)
        
        viewModel.output.subscribersCount
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: StoreDetailOverviewCell, count) in
                owner.menuView.favoriteButton.setCount(count)
            }
            .store(in: &cancellables)
        
        viewModel.output.showTooltip
            .main
            .withUnretained(self)
            .sink { (owner: StoreDetailOverviewCell, isShow: Bool) in
                owner.bossTooltipView.isHidden = !isShow
            }
            .store(in: &cancellables)
    }
}
