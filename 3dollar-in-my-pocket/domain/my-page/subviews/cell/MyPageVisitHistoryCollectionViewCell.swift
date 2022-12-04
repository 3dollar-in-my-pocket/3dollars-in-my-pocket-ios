import UIKit

final class MyPageVisitHistoryCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(MyPageVisitHistoryCollectionViewCell.self)"
    static let size = CGSize(width: 260, height: 112)
    
    private let verticalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
    }
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.verticalStackView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.storeContainerView.addSubViews([
            self.categoryImage,
            self.storeNameLabel,
            self.categoryLabel
        ])
        self.addSubViews([self.verticalStackView])
    }
    
    override func bindConstraints() {
        self.verticalStackView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(Self.size.width)
        }
        
        self.storeContainerView.snp.makeConstraints { make in
            make.height.equalTo(80)
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
    
    func bind(visitHitory: VisitHistory?) {
        guard let visitHitory = visitHitory else {
            self.setEmpty()
            return
        }
        self.visitDateLabel.isHidden = false
        self.visitDateLabel.bind(visitDate: visitHitory.createdAt, visitType: visitHitory.type)
        self.categoryImage.image = visitHitory.store.categories[0].image
        self.storeNameLabel.text = visitHitory.store.storeName
        self.storeNameLabel.textColor = .white
        self.categoryLabel.text = visitHitory.store.categoriesString
        self.categoryLabel.textColor = UIColor(named: "gray30")
        self.verticalStackView.addArrangedSubview(self.visitDateLabel)
        self.verticalStackView.addArrangedSubview(self.storeContainerView)
    }
    
    private func setEmpty() {
        self.visitDateLabel.isHidden = true
        self.categoryImage.image = UIImage(named: "img_empty_my")
        self.storeNameLabel.text = "my_page_visit_history_empty_title".localized
        self.storeNameLabel.textColor = R.color.gray30()
        self.categoryLabel.text = "my_page_visit_history_empty_description".localized
        self.categoryLabel.textColor = R.color.gray60()
        self.verticalStackView.addArrangedSubview(self.storeContainerView)
    }
}
