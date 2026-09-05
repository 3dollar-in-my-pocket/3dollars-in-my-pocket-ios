import UIKit

import Common
import DesignSystem
import Model
import SnapKit

import NMapsMap

final class StoreMapCell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mapHeight: CGFloat = 140
        static let mapCornerRadius: CGFloat = 20
        static let overlayMargin: CGFloat = 8
        static let addressHeight: CGFloat = 34
        static let enlargeButtonSize: CGFloat = 36
    }

    var onAction: ((StoreSectionAction) -> Void)?

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
        let button = UIButton()
        button.layer.cornerRadius = Layout.enlargeButtonSize / 2
        button.layer.shadowColor = Colors.systemBlack.color.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 2
        return button
    }()

    private var pendingLocation: StoreMapLocation?

    override func prepareForReuse() {
        super.prepareForReuse()
        addressButton.clear()
        enlargeButton.clear()
        pendingLocation = nil
        onAction = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let location = pendingLocation, mapView.bounds.width > 0 else { return }
        pendingLocation = nil
        moveCamera(to: location)
    }

    override func setup() {
        contentView.addSubViews([mapView, addressButton, enlargeButton])
    }

    override func bindConstraints() {
        mapView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
            $0.height.equalTo(Layout.mapHeight)
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
    }

    func bind(_ section: StoreMapSection) {
        pendingLocation = section.location
        setNeedsLayout()

        addressButton.setOptionalSDButton(section.footerLeft?.button)
        enlargeButton.setSDButton(section.footerRight.button)

        addressButton.removeTarget(nil, action: nil, for: .touchUpInside)
        enlargeButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.footerLeft?.storeSectionAction {
            addressButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        if let action = section.footerRight.storeSectionAction {
            enlargeButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }

    private func moveCamera(to location: StoreMapLocation) {
        let position = NMGLatLng(lat: location.latitude, lng: location.longitude)
        marker.position = position
        marker.mapView = mapView
        mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(position, zoom: mapView.zoomLevel)))
    }
}
