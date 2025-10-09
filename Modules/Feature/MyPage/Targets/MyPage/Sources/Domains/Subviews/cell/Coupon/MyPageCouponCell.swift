import UIKit

import Common
import DesignSystem
import Then
import Model

final class MyPageCouponCell: BaseCollectionViewCell {

    enum Layout {
        static let defaultHeight: CGFloat = 72
        
        static func size(_ data: MyPageStore) -> CGSize {
            return CGSize(width: 250, height: data.visitInfo.isNil ? defaultHeight : 118)
        }
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray95.color
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }
    
    private let visitDateView = MyPageStoreVisitDateView()
    private let storeView = UIView()

    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.systemWhite.color
    }

    private let tagStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }

    private let tagLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray40.color
    }

    private let imageView = UIImageView().then {
        $0.backgroundColor = .clear
    }

    override func setup() {
        super.setup()

        backgroundColor = .clear
        
        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            stackView,
        ])
        
        storeView.addSubViews([
            titleStackView,
            tagStackView,
            imageView
        ])
        
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
    }
}

final private class MyPageStoreVisitDateView: BaseView {
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 13
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray90.color
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    private let iconView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let dateLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.systemWhite.color
    }
    
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
        
//        DateUtils.toString(
//            dateString: item.visitDate,
//            format: "MM월 dd일 HH:mm:ss"
//        )
    }
}

