import UIKit
import Combine

import DesignSystem
import Networking
import Common
import Model
import Log

import NMapsMap
import CombineCocoa

public final class WriteAddressViewController: BaseViewController {
    private let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 17
        return mapView
    }()
    
    private let marker = UIImageView(image: Icons.markerFocuesd.image)
    
    private let currentLocationButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = Icons.locationCurrent.image.withRenderingMode(.alwaysTemplate)
        config.baseForegroundColor = Colors.gray70.color
        config.baseBackgroundColor = Colors.systemWhite.color
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.tintColor = Colors.gray70.color
        button.layer.shadowColor = Colors.systemBlack.color.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.gray20.color.cgColor
        button.layer.cornerRadius = 23
        return button
    }()
    
    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()
    
    private let addressLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 12, bottomInset: 12, leftInset: 12, rightInset: 12)
        label.backgroundColor = Colors.gray10.color
        label.layer.cornerRadius = 12
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray70.color
        label.textAlignment = .center
        label.layer.masksToBounds = true
        return label
    }()
    
    private let addressButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.mainPink.color
        button.setTitle(Strings.WriteAddress.button, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let bossDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray60.color
        label.text = Strings.WriteAddress.bossDescription
        return label
    }()
    
    private let bossButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = Strings.WriteAddress.bossButton
        config.attributedTitle = AttributedString(Strings.WriteAddress.bossButton, attributes: .init([.font: Fonts.semiBold.font(size: 14)]))
        config.baseForegroundColor = Colors.mainGreen.color
        let button = UIButton(configuration: config)
        return button
    }()

    
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let viewModel: WriteAddressViewModel
    
    public init(viewModel: WriteAddressViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(
            title: nil,
            image: DesignSystemAsset.Icons.writeSolid.image,
            tag: TabBarTag.write.rawValue
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        setupMap()
    }
    
    private func setupUI() {
        title = Strings.WriteAddress.title
        setupNavigationBar()
        view.backgroundColor = Colors.systemWhite.color
        
        view.addSubViews([
            mapView,
            marker,
            currentLocationButton,
            bottomContainer
        ])
        
        bottomContainer.addSubViews([
            addressLabel,
            addressButton,
            bossDescriptionLabel,
            bossButton
        ])
        
        mapView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomContainer.snp.top).offset(20)
        }
        
        marker.snp.makeConstraints {
            $0.center.equalTo(mapView)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(mapView).offset(-28)
            $0.width.equalTo(46)
            $0.height.equalTo(46)
        }
        
        bottomContainer.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(UIUtils.bottomSafeAreaInset + 222)
        }
        
        addressLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(26)
            $0.height.equalTo(48)
        }
        
        addressButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(addressLabel.snp.bottom).offset(24)
            $0.height.equalTo(48)
        }
        
        bossDescriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(addressButton.snp.bottom).offset(16)
        }
        
        bossButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bossDescriptionLabel.snp.bottom)
            $0.height.equalTo(28)
        }
    }
    
    private func setupNavigationBar() {
        guard let writeNavigationController = navigationController as? WriteNavigationController else { return }
        
        let closeImage = Icons.close.image
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(Colors.gray100.color)
            .resizeImage(scaledTo: 24)
        let closeButtonItem = UIBarButtonItem(
            image: closeImage,
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
        closeButtonItem.tintColor = Colors.gray100.color
        navigationItem.setAutoInsetRightBarButtonItem(closeButtonItem)
        
        writeNavigationController.setProgressHidden(true)
    }
    
    @objc func didTapClose() {
        presentDismissModal()
    }
    
    private func bind() {
        // Input
        addressButton.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.didTapSetAddress)
            .store(in: &cancellables)
        
        currentLocationButton.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.didTapCurrentLocation)
            .store(in: &cancellables)
        
        bossButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapBossButton)
            .store(in: &cancellables)
                
        viewModel.output.cameraPosition
            .main
            .sink { [weak self] location in
                self?.moveCamera(location: location)
            }
            .store(in: &cancellables)
        
        viewModel.output.address
            .main
            .sink(receiveValue: { [weak self] address in
                self?.addressLabel.text = address
            })
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func setupMap() {
        mapView.addCameraDelegate(delegate: self)
    }
    
    private func moveCamera(location: CLLocation) {
        let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        ))
        
        camera.animation = .easeIn
        mapView.moveCamera(camera)
    }
}


// MARK: Route
extension WriteAddressViewController {
    private func presentDismissModal() {
        let viewController = WriteCloseViewController { [weak self] in
            self?.dismiss(animated: true)
        }
        present(viewController, animated: true)
    }
    
    private func presentConfirmPopup(_ viewModel: AddressConfirmBottomSheetViewModel) {
        let viewController = AddressConfirmBottomSheetViewController(viewModel: viewModel)
        viewController.onDismissed = { [weak self] in
            self?.viewModel.input.didTapConfirmAddress.send(())
        }
        presentPanModal(viewController)
    }
    
    private func presentBossAppBottomSheet(_ viewModel: BossAppBottomSheetViewModel) {
        let viewController = BossAppBottomSheetViewController(viewModel: viewModel)
        presentPanModal(viewController)
    }
}

extension WriteAddressViewController: NMFMapViewCameraDelegate {
    public func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if animated && reason == NMFMapChangedByGesture {
            let location = CLLocation(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )
            
            viewModel.input.moveMapCenter.send(location)
        }
    }
}

// MARK: Route
extension WriteAddressViewController {
    private func handleRoute(_ route: WriteAddressViewModel.Route) {
        switch route {
        case .presentConfirmPopup(let viewModel):
            presentConfirmPopup(viewModel)
        case .presentBossAppBottomSheet(let viewModel):
            presentBossAppBottomSheet(viewModel)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
