import UIKit

final class StreetFoodListEmptyCell: BaseCollectionViewCell {
    static let registerId = "\(StreetFoodListEmptyCell.self)"
    static let height: CGFloat = 169
    
    private let emptyImage = UIImageView().then {
        $0.image = R.image.img_empty()
    }
    
    private let emptyLabel = UILabel().then {
        $0.text = R.string.localization.category_list_empty()
        $0.textColor = R.color.gray1()
        $0.font = .bold(size: 16)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.emptyImage,
            self.emptyLabel
        ])
    }
    
    override func bindConstraints() {
        self.emptyImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(112)
        }
        
        self.emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.emptyImage.snp.bottom).offset(5)
        }
    }
}
