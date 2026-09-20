import UIKit

import Common
import DesignSystem
import Model

final class MyPageStoreItemCell: BaseCollectionViewCell {

    enum Layout {
        static let defaultHeight: CGFloat = 72
        
        static func size(_ data: MyPageStore) -> CGSize {
            return CGSize(width: 250, height: data.visitInfo.isNil && data.coupon.isNil ? defaultHeight : 118)
        }
    }

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        containerView.backgroundColor = Colors.gray95.color
        return containerView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private let visitDateView = MyPageStoreVisitDateView()
    private let couponView = MyPageStoreCouponView()
    private let storeView = UIView()

    private let titleStackView: UIStackView = {
        let titleStackView = UIStackView()
        titleStackView.axis = .vertical
        titleStackView.spacing = 4
        return titleStackView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 16)
        titleLabel.textColor = Colors.systemWhite.color
        return titleLabel
    }()

    private let tagStackView: UIStackView = {
        let tagStackView = UIStackView()
        tagStackView.axis = .horizontal
        tagStackView.spacing = 4
        return tagStackView
    }()

    private let tagLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.font = Fonts.medium.font(size: 12)
        tagLabel.textColor = Colors.gray40.color
        return tagLabel
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        return imageView
    }()

    override func setup() {
        super.setup()

        backgroundColor = .clear
        
        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            stackView
        ])
        
        storeView.addSubViews([
            titleStackView,
            tagStackView,
            imageView
        ])
        
        stackView.addArrangedSubview(couponView)
        stackView.addArrangedSubview(visitDateView)
        stackView.addArrangedSubview(storeView)
        
        titleStackView.addArrangedSubview(tagStackView)
        titleStackView.addArrangedSubview(titleLabel)

        tagStackView.addArrangedSubview(tagLabel)
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        storeView.snp.makeConstraints {
            $0.height.equalTo(48)
        }

        imageView.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
        }

        titleStackView.snp.makeConstraints {
            $0.centerY.equalTo(imageView)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(12)
        }
    }

    func bind(item: MyPageStore) {
        imageView.setImage(urlString: item.store.categories.first?.imageUrl)
        titleLabel.text = item.store.name
        tagLabel.text = item.store.categoriesString
        if let visitInfo = item.visitInfo {
            visitDateView.bind(item: visitInfo)
            visitDateView.isHidden = false
        } else {
            visitDateView.isHidden = true
        }
        if let coupon = item.coupon {
            couponView.bind(item: coupon)
            couponView.isHidden = false
        } else {
            couponView.isHidden = true
        }
    }
}

final private class MyPageStoreVisitDateView: BaseView {
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 13
        containerView.clipsToBounds = true
        containerView.backgroundColor = Colors.gray90.color
        return containerView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private let iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFill
        return iconView
    }()
    
    private let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = Fonts.medium.font(size: 12)
        dateLabel.textColor = Colors.systemWhite.color
        return dateLabel
    }()
    
    override func setup() {
        super.setup()
        
        addSubViews([
            containerView
        ])
        
        containerView.addSubViews([
            stackView
        ])
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(dateLabel)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        snp.makeConstraints {
            $0.height.equalTo(26)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        iconView.snp.makeConstraints {
            $0.size.equalTo(14)
        }
    }
    
    func bind(item: MyPageStore.VisitInfo) {
        iconView.image = switch item.visitType {
        case .exists: Icons.faceSmile.image.withTintColor(Colors.mainGreen.color)
        case .notExists: Icons.faceSad.image.withTintColor(Colors.mainRed.color)
        case .unknown: nil
        }
        
        dateLabel.text = item.visitDate
    }
}

// MARK: - Coupon
final private class MyPageStoreCouponView: BaseView {
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 13
        containerView.clipsToBounds = true
        containerView.backgroundColor = Colors.gray90.color
        return containerView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private let iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFill
        iconView.image = MyPageAsset.iconCouponSolid.image
        return iconView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.medium.font(size: 12)
        titleLabel.textColor = Colors.systemWhite.color
        return titleLabel
    }()
    
    override func setup() {
        super.setup()
        
        addSubViews([
            containerView
        ])
        
        containerView.addSubViews([
            stackView
        ])
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        snp.makeConstraints {
            $0.height.equalTo(26)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
        
        iconView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
    }
    
    func bind(item: StoreCouponSimpleResponse) {
        titleLabel.text = item.name
    }
}
