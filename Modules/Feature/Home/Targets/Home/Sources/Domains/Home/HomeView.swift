import UIKit

import Common
import DesignSystem
import Model

import NMapsMap
import SnapKit
import Then

final class HomeView: BaseView {
    /// 바텀시트 short form 의 가시 영역 높이. HomeListLayout.Layout.tipVisibleHeight 와 동일.
    private let bottomSheetShortFormHeight: CGFloat = HomeListLayout.Layout.tipVisibleHeight

    private let homeFilterSelectable: HomeFilterSelectable
    
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
    }

    /// 바텀시트가 `.full` 상태일 때 상단 주소/필터 영역에도 시트와 동일한 배경색을 깔아 하나의 화면처럼 보이게 한다.
    /// 평소(`.tip`) 에는 alpha 0 으로 지도를 보여주고, 시트가 끌어올려질수록 alpha 가 1 로 보간된다.
    let topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
    }()

    let addressButton = AddressButton()
    
    lazy var homeFilterCollectionView = HomeFilterCollectionView(homeFilterSelectable: homeFilterSelectable)
    
    let researchButton = UIButton().then {
        $0.setTitle(HomeStrings.homeResearchButton, for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 12)
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        $0.backgroundColor = DesignSystemAsset.Colors.mainRed.color
        $0.layer.cornerRadius = 17
        $0.alpha = 0.0
    }
    
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
    
    let feedButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.Home.feedButton, for: .normal)
        button.setTitleColor(Colors.mainGreen.color, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        button.backgroundColor = Colors.systemWhite.color
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.mainGreen.color.cgColor
        button.layer.shadowColor = Colors.mainGreen.color.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()
    
    private var homeFilterTooltip: HomeFilterTooltip?
    private var feedButtonTimer: Timer?
    private var buttonStateFlag = true
    
    init(homeFilterSelectable: HomeFilterSelectable) {
        self.homeFilterSelectable = homeFilterSelectable
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        addSubViews([
            mapView,
            topBackgroundView,
            researchButton,
            addressButton,
            homeFilterCollectionView,
            currentLocationButton,
            feedButton
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

        homeFilterCollectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalTo(addressButton.snp.bottom)
            $0.right.equalToSuperview()
            $0.height.equalTo(60)
        }

        topBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(homeFilterCollectionView.snp.bottom)
        }
        
        researchButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(homeFilterCollectionView)
            make.height.equalTo(34)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-bottomSheetShortFormHeight - 12)
            $0.width.height.equalTo(40)
        }

        feedButton.snp.makeConstraints {
            $0.centerY.equalTo(currentLocationButton)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(44)
        }
    }
    
    func setHiddenResearchButton(isHidden: Bool) {
        UIView.transition(
            with: researchButton,
            duration: 0.3,
            options: .curveEaseInOut
        ) { [weak self] in
            self?.researchButton.transform = isHidden ? .identity : .init(translationX: 0, y: 35)
            self?.researchButton.alpha = isHidden ? 0.0 : 1.0
        }
    }
    
    func moveCamera(location: CLLocation) {
        let target = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        let cameraPosition = NMFCameraPosition(target, zoom: mapView.zoomLevel)
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    func setAdvertisementMarker(_ advertisement: AdvertisementResponse) {
        guard let urlString = advertisement.image?.url,
              let url = URL(string: urlString) else { return }
        
        
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.mapView.locationOverlay.icon = NMFOverlayImage(image: image)
                self?.mapView.locationOverlay.iconWidth = CGFloat(advertisement.image?.width ?? 0)
                self?.mapView.locationOverlay.iconHeight = CGFloat(advertisement.image?.height ?? 0)
            }
        }
    }
    
    func showFilterTooltiop(isShow: Bool) {
        if isShow,
           let indexPath = homeFilterCollectionView.firstRadioCellIndexPath,
           let cell = homeFilterCollectionView.cellForItem(at: indexPath) as? HomeFilterCell {
            let homeFilterTooltip = HomeFilterTooltip()
            addSubview(homeFilterTooltip)
            homeFilterTooltip.snp.makeConstraints {
                $0.centerX.equalTo(cell)
                $0.top.equalTo(cell.snp.bottom).offset(4)
            }
            self.homeFilterTooltip = homeFilterTooltip
        } else {
            homeFilterTooltip?.removeFromSuperview()
        }
    }

    /// 바텀시트의 .tip → .full 진행도(0~1) 를 상단 배경 alpha 와 주소 버튼 테두리에 함께 매핑한다.
    func updateTopBackground(progress: CGFloat) {
        let clamped = max(0, min(1, progress))
        topBackgroundView.alpha = clamped
        addressButton.updateBorder(progress: clamped)
    }
    
    func startFeedButtonAnimation() {
        feedButtonTimer?.invalidate()
        feedButtonTimer = nil
        feedButtonTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            if buttonStateFlag {
                UIView.animate(withDuration: 0.3) {
                    self.feedButton.setTitle(Strings.Home.feedButton, for: .normal)
                    self.feedButton.setTitleColor(Colors.mainGreen.color, for: .normal)
                    self.feedButton.backgroundColor = Colors.systemWhite.color
                    self.feedButton.layer.borderWidth = 1
                    self.feedButton.layer.borderColor = Colors.mainGreen.color.cgColor
                }
                buttonStateFlag = false
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.feedButton.setTitle(Strings.Home.feedButton2, for: .normal)
                    self.feedButton.setTitleColor(Colors.systemWhite.color, for: .normal)
                    self.feedButton.backgroundColor = Colors.mainGreen.color
                    self.feedButton.layer.borderColor = Colors.systemWhite.color.withAlphaComponent(0.5).cgColor
                }
                buttonStateFlag = true
            }
        }
    }
}
