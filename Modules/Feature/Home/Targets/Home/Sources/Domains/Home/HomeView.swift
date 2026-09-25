import UIKit

import Common
import DesignSystem
import Model

import NMapsMap
import SnapKit

final class HomeView: BaseView {
    enum Layout {
        static let focusBoundsPadding: CGFloat = 24
    }

    /// 바텀시트 short form 의 가시 영역 높이. HomeListLayout.Layout.tipVisibleHeight 와 동일.
    private let bottomSheetShortFormHeight: CGFloat = HomeListLayout.Layout.tipVisibleHeight

    private let homeFilterSelectable: HomeFilterSelectable
    
    let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 15
        return mapView
    }()

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
    
    let researchButton: UIButton = {
        let researchButton = UIButton()
        researchButton.setTitle(HomeStrings.homeResearchButton, for: .normal)
        researchButton.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        researchButton.titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 12)
        researchButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        researchButton.backgroundColor = DesignSystemAsset.Colors.mainRed.color
        researchButton.layer.cornerRadius = 17
        researchButton.alpha = 0.0
        return researchButton
    }()
    
    let mapControlView = HomeMapControlView()

    let writeButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.Home.writeButton, for: .normal)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.setImage(
            Icons.plus.image.resizeImage(scaledTo: 16).withTintColor(Colors.systemWhite.color),
            for: .normal
        )
        button.contentEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 16)
        button.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: -4)
        button.imageEdgeInsets = .init(top: 0, left: -4, bottom: 0, right: 4)
        button.backgroundColor = Colors.mainPink.color
        button.layer.cornerRadius = 22
        button.layer.shadowColor = Colors.mainPink.color.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()
    
    private var homeFilterTooltip: HomeFilterTooltip?
    
    init(homeFilterSelectable: HomeFilterSelectable) {
        self.homeFilterSelectable = homeFilterSelectable
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateMapContentInset()
    }

    override func setup() {
        addSubViews([
            mapView,
            topBackgroundView,
            researchButton,
            addressButton,
            homeFilterCollectionView,
            mapControlView,
            writeButton
        ])
    }
    
    override func bindConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }

        addressButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
        }

        homeFilterCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(addressButton.snp.bottom)
            $0.trailing.equalToSuperview()
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
        
        mapControlView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-bottomSheetShortFormHeight - 12)
        }

        writeButton.snp.makeConstraints {
            $0.bottom.equalTo(mapControlView)
            $0.trailing.equalToSuperview().offset(-20)
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
    
    private func updateMapContentInset() {
        let contentInset = UIEdgeInsets(
            top: addressButton.frame.maxY,
            left: 0,
            bottom: safeAreaInsets.bottom + bottomSheetShortFormHeight,
            right: 0
        )

        if mapView.contentInset != contentInset {
            mapView.contentInset = contentInset
        }
    }

    /// 서버 조회에 사용할 지도 반경(m).
    /// 초기 조회와 재조회가 다른 기준을 쓰지 않도록 반경 계산은 이 프로퍼티 하나로만 한다.
    var mapMaxDistance: Double {
        let boundsLatLngs = mapView.contentBounds.boundsLatLngs

        return boundsLatLngs[0].distance(to: boundsLatLngs[1]) / 3
    }

    /// - Parameter animated: 최초 진입처럼 이동 직후 `mapMaxDistance` 를 측정해야 하는 경우 `false` 로 넘겨
    ///   애니메이션 없이 즉시 카메라를 적용한다. 애니메이션 중에는 `contentBounds` 가 최종 값이 아니다.
    func moveCamera(location: CLLocation, zoomLevel: Double? = nil, animated: Bool = true) {
        let currentCameraPosition = mapView.cameraPosition
        let target = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        let cameraPosition = NMFCameraPosition(
            target,
            zoom: zoomLevel ?? currentCameraPosition.zoom,
            tilt: currentCameraPosition.tilt,
            heading: currentCameraPosition.heading
        )
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)

        cameraUpdate.animation = animated ? .easeIn : .none
        mapView.moveCamera(cameraUpdate)
    }

    func moveCamera(bounds: LocationBoundsResponse) {
        let southWest = NMGLatLng(lat: bounds.southWest.latitude, lng: bounds.southWest.longitude)
        let northEast = NMGLatLng(lat: bounds.northEast.latitude, lng: bounds.northEast.longitude)
        let latLngBounds = NMGLatLngBounds(southWest: southWest, northEast: northEast)
        let paddingInsets = UIEdgeInsets(
            top: homeFilterCollectionView.frame.maxY - mapView.contentInset.top + Layout.focusBoundsPadding,
            left: Layout.focusBoundsPadding,
            bottom: Layout.focusBoundsPadding,
            right: Layout.focusBoundsPadding
        )
        let cameraUpdate = NMFCameraUpdate(fit: latLngBounds, paddingInsets: paddingInsets)

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
    
}
