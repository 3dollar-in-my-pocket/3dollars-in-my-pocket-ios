import UIKit

final class MyVisitHistoryTableViewCell: BaseTableViewCell {
    static let registerId = "\(MyVisitHistoryTableViewCell.self)"
    
    private let visitImageView = MyVisitHistoryImageView()
    
    private let containerView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 15
    }
    
    private let categoryImage = UIImageView()
    
    private let storeNameLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = .white
        $0.text = "강남역 0번 출구"
    }
    
    private let categoryLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray30()
        $0.text = "#붕어빵 #땅콩과자 #호떡"
    }
    
    override func setup() {
        self.selectionStyle = .none
        self.addSubViews([
            self.visitImageView,
            self.containerView,
            self.categoryImage,
            self.storeNameLabel,
            self.categoryImage
        ])
    }
    
    override func bindConstraints() {
        self.visitImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(16)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalTo(self.visitImageView.snp.right).offset(8)
            make.top.equalTo(self.visitImageView)
            make.bottom.equalTo(self.visitImageView)
            make.right.equalToSuperview().offset(-24)
        }
        
        self.categoryImage.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.centerY.equalTo(self.containerView)
        }
        
        self.storeNameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.categoryImage.snp.right).offset(8)
            make.top.equalTo(self.categoryImage)
        }
        
        self.categoryLabel.snp.makeConstraints { make in
            make.left.equalTo(self.storeNameLabel)
            make.top.equalTo(self.storeNameLabel.snp.bottom).offset(8)
        }
    }
    
    func bind(visitHistory: VisitHistory) {
        self.visitImageView.bind(visitHistory: visitHistory)
        self.categoryImage.image = visitHistory.store.categories[0].image
        self.storeNameLabel.text = visitHistory.store.storeName
        self.categoryLabel.text = visitHistory.store.categoriesString
    }
}
