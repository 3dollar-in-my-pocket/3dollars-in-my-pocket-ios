import UIKit
import MapKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreMapCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let mapView: MKMapView = {
        let view = MKMapView()
        view.isScrollEnabled = false
        view.isZoomEnabled = false
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    private let footerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)

    override func prepareForReuse() {
        super.prepareForReuse()
        onAction = nil
    }

    override func setup() {
        footerStack.addArrangedSubview(leftButton)
        footerStack.addArrangedSubview(rightButton)
        contentView.addSubViews([mapView, footerStack])
    }

    override func bindConstraints() {
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(180)
        }
        footerStack.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
    }

    func bind(_ section: StoreMapSection) {
        let coordinate = CLLocationCoordinate2D(
            latitude: section.location.latitude,
            longitude: section.location.longitude
        )
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.setRegion(
            MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            ),
            animated: false
        )

        leftButton.setOptionalSDButton(section.footerLeft?.button)
        rightButton.setSDButton(section.footerRight.button)
        leftButton.removeTarget(nil, action: nil, for: .touchUpInside)
        rightButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.footerLeft?.storeSectionAction {
            leftButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
        if let action = section.footerRight.storeSectionAction {
            rightButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }
}
