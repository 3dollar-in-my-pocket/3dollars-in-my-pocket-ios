import UIKit

import Common
import DesignSystem
import Model

final class RecentSearchAddressCell: BaseCollectionViewCell {
    private let placeNameLabel = UILabel().then {
        $0.textColor = Colors.systemBlack.color
        $0.font = Fonts.semiBold.font(size: 14)
    }
    
    private let addressLabel = UILabel().then {
        $0.textColor = Colors.gray50.color
        $0.font = Fonts.regular.font(size: 14)
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = Colors.gray20.color
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(Icons.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.gray50.color
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        placeNameLabel.text = nil
        addressLabel.text = nil
    }
    
    
    override func setup() {
        addSubViews([
            placeNameLabel,
            addressLabel,
            dividerView,
            deleteButton
        ])
    }
    
    override func bindConstraints() {
        placeNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(12)
        }
        
        addressLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(placeNameLabel)
            $0.top.equalTo(placeNameLabel.snp.bottom).offset(4)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    func bind(_ viewModel: RecentSearchAddressCellViewModel) {
        placeNameLabel.text = viewModel.output.placeName
        addressLabel.text = viewModel.output.addressName
        
        deleteButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapDeleteButton)
            .store(in: &cancellables)
    }
}
