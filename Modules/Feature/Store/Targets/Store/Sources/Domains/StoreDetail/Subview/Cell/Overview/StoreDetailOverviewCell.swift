import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 376
    }
    
    let titleView = StoreDetailOverviewTitleView()
    
    let menuView = StoreDetailOverviewMenuView()
    
    let mapView = StoreDetailOverviewMapView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleView.prepareForReuse()
        mapView.prepareForReuse()
    }
    
    override func setup() {
        addSubViews([
            titleView,
            menuView,
            mapView
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
        
        mapView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(menuView.snp.bottom).offset(24)
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
    
    func bind(_ viewModel: StoreDetailOverviewCellViewModel) {
        titleView.bind(viewModel.output.overview)
        mapView.bind(
            location: viewModel.output.overview.location,
            address: viewModel.output.overview.address
        )
        menuView.favoriteButton.isSelected = viewModel.output.overview.isFavorited
        menuView.favoriteButton.setCount(viewModel.output.overview.subscribersCount)
        
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
        
        mapView.addressButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapAddress)
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
    }
}
