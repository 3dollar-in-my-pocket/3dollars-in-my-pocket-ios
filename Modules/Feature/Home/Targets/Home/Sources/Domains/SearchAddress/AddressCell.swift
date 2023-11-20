import UIKit

import Common
import DesignSystem
import Model

final class AddressCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 70)
    }
    
    private let buildingName = UILabel().then {
        $0.textColor = Colors.systemBlack.color
        $0.font = Fonts.bold.font(size: 16)
    }
    
    private let addressLabel = UILabel().then {
        $0.textColor = Colors.gray50.color
        $0.font = Fonts.regular.font(size: 14)
    }
    
    private let dividorView = UIView().then {
        $0.backgroundColor = Colors.gray20.color
    }
    
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
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(12)
        }
        
        addressLabel.snp.makeConstraints {
            $0.left.right.equalTo(buildingName)
            $0.top.equalTo(buildingName.snp.bottom).offset(2)
        }
        
        dividorView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
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
