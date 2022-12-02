import UIKit

final class MyPageVisitHistoryCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(MyPageVisitHistoryCollectionViewCell.self)"
    static let size = CGSize(width: 250, height: 112)
    
    private let visitDateLabel = VisitDateView()
    
    private let storeContainerView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 15
    }
    
    private let categoryImage = UIImageView().then {
        $0.image = R.image.img_32_bungeoppang_on()
    }
    
    private let storeNameLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = .white
    }
    
    private let categoryLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray30()
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.visitDateLabel,
            self.storeContainerView,
            self.categoryImage,
            self.storeNameLabel,
            self.categoryLabel
        ])
    }
    
    override func bindConstraints() {
        self.visitDateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.storeContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.visitDateLabel.snp.bottom).offset(8)
            make.width.equalTo(Self.size.width)
            make.bottom.equalToSuperview()
        }
        
        self.categoryImage.snp.makeConstraints { make in
            make.left.equalTo(self.storeContainerView).offset(16)
            make.centerY.equalTo(self.storeContainerView)
            make.width.height.equalTo(48)
        }
        
        self.storeNameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.categoryImage.snp.right).offset(8)
            make.top.equalTo(self.storeContainerView).offset(20)
            make.right.equalTo(self.storeContainerView).offset(-16)
        }
        
        self.categoryLabel.snp.makeConstraints { make in
            make.left.equalTo(self.storeNameLabel)
            make.top.equalTo(self.storeNameLabel.snp.bottom).offset(8)
            make.right.equalTo(self.storeNameLabel)
        }
    }
    
    func bind(visitHitory: VisitHistory) {
        self.visitDateLabel.bind(visitDate: visitHitory.createdAt, visitType: visitHitory.type)
        self.categoryImage.image = visitHitory.store.categories[0].image
        self.storeNameLabel.text = visitHitory.store.storeName
        self.categoryLabel.text = visitHitory.store.categoriesString
    }
}
