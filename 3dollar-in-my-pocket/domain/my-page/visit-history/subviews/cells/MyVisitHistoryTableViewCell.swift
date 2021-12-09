import UIKit

final class MyVisitHistoryTableViewCell: BaseTableViewCell {
    static let registerId = "\(MyVisitHistoryTableViewCell.self)"
    
    private let dateLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = .white
    }
    
    private let dividorView = UIView().then {
        $0.backgroundColor = R.color.gray80()
        $0.layer.cornerRadius = 0.5
    }
    
    private let visitImageView = MyVisitHistoryImageView()
    
    private let containerView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 15
    }
    
    private let categoryImage = UIImageView()
    
    private let storeNameLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = .white
    }
    
    private let categoryLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray30()
    }
    
    override func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.addSubViews([
            self.dateLabel,
            self.dividorView,
            self.visitImageView,
            self.containerView,
            self.categoryImage,
            self.storeNameLabel,
            self.categoryLabel
        ])
    }
    
    override func bindConstraints() {
        self.dateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(26)
        }
        
        self.dividorView.snp.makeConstraints { make in
            make.left.equalTo(self.dateLabel.snp.right).offset(13)
            make.centerY.equalTo(self.dateLabel)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(1)
        }
        
        self.visitImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.dateLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-6)
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
            make.width.height.equalTo(40)
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
        self.dateLabel.text = DateUtils.toString(
            dateString: visitHistory.createdAt,
            format: "yyyy년 MM월 dd일 EEEE"
        )
        self.visitImageView.bind(visitHistory: visitHistory)
        self.categoryImage.image = visitHistory.store.categories[0].image
        self.storeNameLabel.text = visitHistory.store.storeName
        self.categoryLabel.text = visitHistory.store.categoriesString
    }
}
