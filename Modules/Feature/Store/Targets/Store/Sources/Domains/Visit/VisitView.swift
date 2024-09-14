import UIKit

import Common
import DesignSystem
import Model

import NMapsMap

final class VisitView: BaseView {
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.close.image.withTintColor(Colors.systemWhite.color), for: .normal)
        
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.regular.font(size: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let mapContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = Colors.gray90.color
        
        return view
    }()
    
    let storeCategoryImage = UIImageView()
    
    let storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.systemWhite.color
        
        return label
    }()
    
    let storeCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.mainPink.color
        
        return label
    }()
    
    let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.layer.cornerRadius = 16
        mapView.positionMode = .direction
        
        return mapView
    }()
    
    let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.locationCurrent.image.withTintColor(Colors.systemBlack.color), for: .normal)
        button.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.gray20.color.cgColor
        button.layer.cornerRadius = 20
        button.backgroundColor = Colors.systemWhite.color
        
        return button
    }()
    
    let bottomContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = Colors.gray90.color
        
        return view
    }()
    
    let bottomRightCircleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.backgroundColor = Colors.gray80.color
        
        return view
    }()
    
    let bottomRightCategoryImage = UIImageView()
    
    let indicatorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.iconDistanceIndicator.image
        
        return imageView
    }()
    
    private let progressBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray80.color
        view.layer.cornerRadius = 6
        
        return view
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackTintColor = .clear
        progressView.progressTintColor = Colors.mainPink.color
        progressView.layer.cornerRadius = 3
        return progressView
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.systemWhite.color
        
        return label
    }()
    
    let bottomSheetContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.pink300.color
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.alpha = 0
        
        return view
    }()
    
    let notExistedButton = VisitButton(type: .notExists)
    
    let existedButton = VisitButton(type: .exists)
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        
        bottomContainerView.addSubViews([
            bottomRightCircleView,
            bottomRightCategoryImage,
            indicatorImage,
            progressBackgroundView,
            progressView,
            distanceLabel
        ])
        
        bottomSheetContainerView.addSubViews([
            existedButton,
            notExistedButton
        ])
        
        addSubViews([
            closeButton,
            titleLabel,
            mapContainerView,
            storeCategoryImage,
            storeNameLabel,
            storeCategoryLabel,
            mapView,
            currentLocationButton,
            bottomContainerView,
            bottomSheetContainerView
        ])
    }
    
    override func bindConstraints() {
        closeButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
        }
        
        bottomContainerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-100)
        }
        
        bottomRightCircleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(26)
            $0.right.equalToSuperview().offset(-40)
            $0.size.equalTo(48)
        }
        
        bottomRightCategoryImage.snp.makeConstraints {
            $0.center.equalTo(bottomRightCircleView)
            $0.size.equalTo(40)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.centerX.equalTo(indicatorImage.snp.centerX)
            $0.top.equalTo(progressBackgroundView.snp.bottom).offset(8)
        }
        
        progressBackgroundView.snp.makeConstraints {
            $0.height.equalTo(12)
            $0.centerY.equalTo(bottomRightCircleView)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalTo(bottomRightCircleView.snp.left).offset(4)
        }
        
        progressView.snp.makeConstraints {
            $0.left.equalTo(progressBackgroundView).offset(3)
            $0.right.equalTo(progressBackgroundView).offset(-3)
            $0.top.equalTo(progressBackgroundView).offset(3)
            $0.bottom.equalTo(progressBackgroundView).offset(-3)
        }
        
        indicatorImage.snp.makeConstraints {
            $0.centerX.equalTo(progressView.snp.left)
                .offset(CGFloat(progressView.progress) * progressView.frame.width)
            $0.bottom.equalTo(progressBackgroundView.snp.top)
            $0.width.equalTo(24)
            $0.height.equalTo(28)
        }
        
        mapContainerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.height.equalTo(111)
            $0.top.equalTo(titleLabel.snp.bottom).offset(28)
        }
        
        storeCategoryImage.snp.makeConstraints {
            $0.left.equalTo(mapContainerView).offset(16)
            $0.top.equalTo(mapContainerView).offset(12)
            $0.size.equalTo(44)
        }
        
        storeNameLabel.snp.makeConstraints {
            $0.left.equalTo(storeCategoryImage.snp.right).offset(12)
            $0.top.equalTo(mapContainerView).offset(13)
            $0.right.lessThanOrEqualTo(mapContainerView).offset(-16)
            $0.height.equalTo(24)
        }
        
        storeCategoryLabel.snp.makeConstraints {
            $0.left.right.equalTo(storeNameLabel)
            $0.top.equalTo(storeNameLabel.snp.bottom)
            $0.height.equalTo(18)
        }
        
        mapView.snp.makeConstraints {
            $0.left.right.equalTo(mapContainerView)
            $0.top.equalTo(storeCategoryImage.snp.bottom).offset(12)
            $0.bottom.equalTo(bottomContainerView.snp.top).offset(-40)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.right.equalTo(mapView).offset(-16)
            $0.bottom.equalTo(mapView).offset(-16)
            $0.size.equalTo(40)
        }
        
        bottomSheetContainerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(existedButton).offset(-24)
            $0.bottom.equalToSuperview()
        }
        
        existedButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.right.equalTo(snp.centerX).offset(-8)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-8)
            $0.height.equalTo(existedButton.snp.width)
        }
        
        notExistedButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-24)
            $0.centerY.equalTo(existedButton)
            $0.left.equalTo(snp.centerX).offset(8)
            $0.height.equalTo(notExistedButton.snp.width)
        }
    }
    
    func bind(store: VisitableStore) {
        storeNameLabel.text = store.storeName
        storeCategoryImage.setImage(urlString: store.categories.first?.imageUrl)
        storeCategoryLabel.text = store.categoriesString
        bottomRightCategoryImage.setImage(urlString: store.categories.first?.imageUrl)
        if let location = store.location {
            setupMap(location: location)
        }
    }
    
    func bindDistance(distance: Int) {
        /// 기준 거리인 300m보다 멀리 있으면 0.5로 고정, 300m보다 가까이 있으면 프로그래스 바 설정
        let progress = distance > 300 ? 0.5 : Float(300 - distance)/300
        
        progressView.progress = progress
        indicatorImage.snp.updateConstraints {
            $0.centerX.equalTo(progressView.snp.left).offset(CGFloat(progress) * progressView.frame.width)
        }
        
        distanceLabel.text = Strings.Visit.distanceFormat(distance)
    }
    
    func moveCamera(latitude: Double, longitude: Double) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: .init(
            lat: latitude,
            lng: longitude
        ))
        
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    func bindVisitable(canVisit: Bool) {
        if canVisit {
            setVisitable()
        } else {
            setUnvisitable()
        }
        currentLocationButton.isHidden = canVisit
    }
    
    private func setVisitable() {
        setupTitleLabel(canVisit: true)
        mapView.snp.remakeConstraints {
            $0.left.right.equalTo(mapContainerView)
            $0.top.equalTo(storeCategoryImage.snp.bottom).offset(12)
            $0.bottom.equalTo(bottomSheetContainerView.snp.top).offset(-40)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            backgroundColor = Colors.mainPink.color
            bottomSheetContainerView.alpha = 1
            bottomContainerView.alpha = 0
            mapContainerView.backgroundColor = Colors.pink400.color
            layoutIfNeeded()
            storeCategoryLabel.textColor = Colors.pink200.color
        }
    }
    
    private func setUnvisitable() {
        setupTitleLabel(canVisit: false)
        mapView.snp.remakeConstraints {
            $0.left.right.equalTo(mapContainerView)
            $0.top.equalTo(storeCategoryImage.snp.bottom).offset(12)
            $0.bottom.equalTo(bottomContainerView.snp.top).offset(-40)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            backgroundColor = Colors.gray100.color
            bottomSheetContainerView.alpha = 0
            bottomContainerView.alpha = 1
            mapContainerView.backgroundColor = Colors.gray90.color
            self.layoutIfNeeded()
            storeCategoryLabel.textColor = Colors.mainPink.color
        }
    }
    
    private func setupMap(location: LocationResponse) {
        moveCamera(latitude: location.latitude, longitude: location.longitude)
        setupRangeOverlayView(location: location)
        setupMarker(location: location)
    }
    
    private func setupRangeOverlayView(location: LocationResponse) {
        let rangeOverlayView = NMFCircleOverlay()
        rangeOverlayView.center = NMGLatLng(lat: location.latitude, lng: location.longitude)
        rangeOverlayView.radius = 100
        rangeOverlayView.fillColor = Colors.mainPink.color.withAlphaComponent(0.2)
        rangeOverlayView.mapView = mapView
    }
    
    private func setupMarker(location: LocationResponse) {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: location.latitude, lng: location.longitude)
        marker.iconImage = NMFOverlayImage(image: Icons.markerFocuesd.image)
        marker.width = 30
        marker.height = 34
        marker.mapView = mapView
        marker.globalZIndex = 1
    }
    
    private func setupTitleLabel(canVisit: Bool) {
        if canVisit {
            let text = Strings.Visit.Title.exists
            let attributedString = NSMutableAttributedString(string: text)
            let range = (text as NSString).range(of: Strings.Visit.Title.existsBold)
            attributedString.addAttribute(.font, value: Fonts.bold.font(size: 24), range: range)
            titleLabel.attributedText = attributedString
        } else {
            let text = Strings.Visit.Title.notExists
            let attributedString = NSMutableAttributedString(string: text)
            let range = (text as NSString).range(of: Strings.Visit.Title.notExistsBold)
            attributedString.addAttribute(.font, value: Fonts.bold.font(size: 24), range: range)
            titleLabel.attributedText = attributedString
        }
    }
}
