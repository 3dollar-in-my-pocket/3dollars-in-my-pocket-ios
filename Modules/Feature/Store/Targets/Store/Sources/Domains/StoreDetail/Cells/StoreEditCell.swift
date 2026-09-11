import UIKit

import Common
import DesignSystem
import Model
import SnapKit

import NMapsMap

final class StoreEditCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mapHeight: CGFloat = 140
        static let mapCornerRadius: CGFloat = 20
        static let overlayMargin: CGFloat = 8
        static let addressHeight: CGFloat = 34
        static let enlargeButtonSize: CGFloat = 36
        static let editSpacing: CGFloat = 12
        static let editBarHeight: CGFloat = 44
    }

    var onAction: ((StoreSectionAction) -> Void)?

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Layout.editSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 0, left: Layout.horizontalMargin, bottom: 0, right: Layout.horizontalMargin)
        stack.insetsLayoutMarginsFromSafeArea = false
        return stack
    }()

    private let mapContainerView = MapContainerView()

    private let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.isUserInteractionEnabled = false
        mapView.zoomLevel = 15
        mapView.layer.cornerRadius = Layout.mapCornerRadius
        mapView.clipsToBounds = true
        return mapView
    }()

    private let marker: NMFMarker = {
        let marker = NMFMarker()
        marker.width = 32
        marker.height = 40
        marker.iconImage = NMFOverlayImage(image: Icons.markerFocuesd.image)
        return marker
    }()

    private let addressButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        config.imagePadding = 4
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = Layout.addressHeight / 2
        button.clipsToBounds = true
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        return button
    }()

    private let enlargeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = Layout.enlargeButtonSize / 2
        button.layer.shadowColor = Colors.systemBlack.color.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 2
        return button
    }()

    private let editStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.isHidden = true
        return stack
    }()

    private var location: StoreMapLocation?
    private var lastAppliedMapSize: CGSize = .zero

    override func prepareForReuse() {
        super.prepareForReuse()
        addressButton.clear()
        enlargeButton.clear()
        editStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        editStack.isHidden = true
        mapContainerView.isHidden = false
        location = nil
        lastAppliedMapSize = .zero
        onAction = nil
    }

    override func setup() {
        mapContainerView.onLayout = { [weak self] in
            DispatchQueue.main.async {
                self?.applyLocationIfNeeded()
            }
        }
        mapContainerView.addSubViews([mapView, addressButton, enlargeButton])
        contentStack.addArrangedSubview(mapContainerView)
        contentStack.addArrangedSubview(editStack)
        contentView.addSubview(contentStack)
    }

    override func bindConstraints() {
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mapContainerView.snp.makeConstraints {
            $0.height.equalTo(Layout.mapHeight)
        }
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        addressButton.snp.makeConstraints {
            $0.leading.equalTo(mapView).offset(Layout.overlayMargin)
            $0.trailing.lessThanOrEqualTo(enlargeButton.snp.leading).offset(-Layout.overlayMargin)
            $0.bottom.equalTo(mapView).offset(-Layout.overlayMargin)
            $0.height.equalTo(Layout.addressHeight)
        }
        enlargeButton.snp.makeConstraints {
            $0.trailing.equalTo(mapView).offset(-Layout.overlayMargin)
            $0.bottom.equalTo(mapView).offset(-Layout.overlayMargin)
            $0.size.equalTo(Layout.enlargeButtonSize)
        }
        editStack.snp.makeConstraints {
            $0.height.equalTo(Layout.editBarHeight)
        }
    }

    func bind(_ section: StoreEditSection) {
        bindMap(section.map)
        bindEditBars(section.actionBars)
    }

    private func bindMap(_ map: StoreEditMap?) {
        guard let map else {
            mapContainerView.isHidden = true
            location = nil
            return
        }
        mapContainerView.isHidden = false
        location = map.location
        lastAppliedMapSize = .zero
        mapContainerView.setNeedsLayout()

        addressButton.setOptionalSDButton(map.footerLeft?.button)
        enlargeButton.setSDButton(map.footerRight.button)

        addressButton.removeTarget(nil, action: nil, for: .touchUpInside)
        enlargeButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = map.footerLeft?.storeSectionAction {
            addressButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        if let action = map.footerRight.storeSectionAction {
            enlargeButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }

    private func bindEditBars(_ actionBars: [SDActionBar]) {
        editStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard actionBars.isEmpty.isNot else {
            editStack.isHidden = true
            return
        }
        editStack.isHidden = false

        actionBars.forEach { actionBar in
            let button = UIButton(type: .custom)
            button.titleLabel?.font = Fonts.medium.font(size: 13)
            button.layer.cornerRadius = 12
            button.clipsToBounds = true
            button.setSDButton(actionBar.button)
            if let action = actionBar.storeSectionAction {
                button.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
            }
            editStack.addArrangedSubview(button)
        }
    }

    private func applyLocationIfNeeded() {
        guard let location, mapView.bounds.width > 0, mapView.bounds.size != lastAppliedMapSize else { return }
        lastAppliedMapSize = mapView.bounds.size
        moveCamera(to: location)
    }

    private func moveCamera(to location: StoreMapLocation) {
        let position = NMGLatLng(lat: location.latitude, lng: location.longitude)
        marker.position = position
        marker.mapView = mapView
        mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(position, zoom: mapView.zoomLevel)))
    }
}

private final class MapContainerView: UIView {
    var onLayout: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?()
    }
}
