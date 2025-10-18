import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailOverviewTitleView: BaseView {
    enum Layout {
        static let height: CGFloat = 78
    }
    
    private let categoryImage = UIImageView()
    
    private let repoterLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 20)
        $0.textColor = Colors.gray100.color
    }
    
    private let newBadge = UIImageView(image: Assets.iconNewBadge.image)
    
    private let visitCountLabel = PaddingLabel(
        topInset: 3,
        bottomInset: 3,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.backgroundColor = Colors.pink100.color
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.textColor = Colors.mainPink.color
        $0.font = Fonts.medium.font(size: 12)
    }
    private let couponView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        let stackView = UIStackView()
        stackView.spacing = 4
        stackView.alignment = .center
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.verticalEdges.equalToSuperview()
            $0.height.equalTo(24)
        }
        let imageView = UIImageView(image: DesignSystemAsset.Icons.couponLine.image)
        imageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        stackView.addArrangedSubview(imageView)
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.systemWhite.color
        label.text = "쿠폰!"
        stackView.addArrangedSubview(label)
        return view
    }()
    
    private let infoView = StoreDetailOverviewInfoCellView()
    
    override func setup() {
        addSubViews([
            categoryImage,
            repoterLabel,
            titleLabel,
            newBadge,
            visitCountLabel,
            couponView,
            infoView
        ])
    }
    
    override func bindConstraints() {
        categoryImage.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.size.equalTo(48)
        }
        
        repoterLabel.snp.makeConstraints {
            $0.left.equalTo(categoryImage.snp.right).offset(8)
            $0.top.equalToSuperview()
            $0.right.lessThanOrEqualToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(repoterLabel)
            $0.top.equalTo(repoterLabel.snp.bottom).offset(4)
            $0.right.lessThanOrEqualToSuperview().offset(-18)
        }
        
        newBadge.snp.makeConstraints {
            $0.left.equalTo(titleLabel.snp.right).offset(4)
            $0.size.equalTo(14)
            $0.top.equalTo(titleLabel).offset(4)
        }
        
        visitCountLabel.snp.makeConstraints {
            $0.left.equalTo(repoterLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.height.equalTo(24)
        }
        
        couponView.snp.makeConstraints {
            $0.leading.equalTo(visitCountLabel.snp.trailing).offset(5)
            $0.centerY.equalTo(visitCountLabel)
        }
        
        infoView.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.centerY.equalTo(visitCountLabel)
        }
    }
    
    func prepareForReuse() {
        infoView.prepareForReuse()
    }
    
    func bind(_ overview: StoreDetailOverview) {
        categoryImage.setImage(urlString: overview.categories.first?.imageUrl)
        repoterLabel.text = Strings.StoreDetail.Overview.repoterNameFormat(overview.repoterName)
        titleLabel.text = overview.storeName
        newBadge.isHidden = !overview.isNew
        setVisitCount(overview.totalVisitSuccessCount)
        infoView.bind(reviewCount: overview.reviewCount, distance: overview.distance)

        if overview.isBossStore {
            repoterLabel.text = overview.categoriesString
            visitCountLabel.text = "사장님 직영"
        }
        
         couponView.isHidden = overview.hasIssuableCoupon.isNot
    }
    
    private func setVisitCount(_ totalVisitSuccessCount: Int) {
        let string = Strings.StoreDetail.Overview.successVisitCountFormat(totalVisitSuccessCount)
        let attributedString = NSMutableAttributedString(string: string)
        let range = (string as NSString).range(of: "\(totalVisitSuccessCount)명")
        
        attributedString.addAttributes([.font: Fonts.bold.font(size: 12) as Any], range: range)
        visitCountLabel.attributedText = attributedString
    }
}
