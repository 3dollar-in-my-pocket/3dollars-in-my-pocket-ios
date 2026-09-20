import UIKit

import Common
import DesignSystem
import Model

final class RecentSearchAddressCell: BaseCollectionViewCell {
    private let placeNameLabel: UILabel = {
        let placeNameLabel = UILabel()
        placeNameLabel.textColor = Colors.systemBlack.color
        placeNameLabel.font = Fonts.semiBold.font(size: 14)
        return placeNameLabel
    }()
    
    private let addressLabel: UILabel = {
        let addressLabel = UILabel()
        addressLabel.textColor = Colors.gray50.color
        addressLabel.font = Fonts.regular.font(size: 14)
        return addressLabel
    }()
    
    private let dividerView: UIView = {
        let dividerView = UIView()
        dividerView.backgroundColor = Colors.gray20.color
        return dividerView
    }()
    
    private let deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.setImage(Icons.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        deleteButton.tintColor = Colors.gray50.color
        return deleteButton
    }()
    
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
