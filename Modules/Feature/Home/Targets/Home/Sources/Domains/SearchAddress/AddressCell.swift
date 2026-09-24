import UIKit

import Common
import DesignSystem
import Model

final class AddressCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 70)
    }
    
    private let buildingName: UILabel = {
        let buildingName = UILabel()
        buildingName.textColor = Colors.systemBlack.color
        buildingName.font = Fonts.bold.font(size: 16)
        return buildingName
    }()
    
    private let addressLabel: UILabel = {
        let addressLabel = UILabel()
        addressLabel.textColor = Colors.gray50.color
        addressLabel.font = Fonts.regular.font(size: 14)
        return addressLabel
    }()
    
    private let dividorView: UIView = {
        let dividorView = UIView()
        dividorView.backgroundColor = Colors.gray20.color
        return dividorView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        buildingName.text = nil
        addressLabel.text = nil
    }
    
    
    override func setup() {
        addSubViews([
            buildingName,
            addressLabel,
            dividorView
        ])
    }
    
    override func bindConstraints() {
        buildingName.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(12)
        }
        
        addressLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(buildingName)
            $0.top.equalTo(buildingName.snp.bottom).offset(2)
        }
        
        dividorView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(document: PlaceDocument) {
        buildingName.text = document.placeName
        if document.roadAddressName.isEmpty {
            addressLabel.text = document.addressName
        } else {
            addressLabel.text = document.roadAddressName
        }
    }
}
