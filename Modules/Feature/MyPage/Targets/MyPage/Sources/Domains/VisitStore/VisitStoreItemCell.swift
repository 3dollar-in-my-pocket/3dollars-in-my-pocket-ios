import UIKit

import Common
import DesignSystem
import Model

final class VisitStoreItemCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 80
    }

    private let visitTypeView: UIView = {
        let visitTypeView = UIView()
        visitTypeView.layer.cornerRadius = 16
        visitTypeView.clipsToBounds = true
        visitTypeView.backgroundColor = Colors.gray95.color
        return visitTypeView
    }()
    
    private let visitTypeImageView = UIImageView()
    
    private let visitTimeLabel: UILabel = {
        let visitTimeLabel = UILabel()
        visitTimeLabel.font = Fonts.medium.font(size: 10)
        visitTimeLabel.textColor = Colors.systemWhite.color
        return visitTimeLabel
    }()
    
    private let storeView: UIView = {
        let storeView = UIView()
        storeView.layer.cornerRadius = 16
        storeView.clipsToBounds = true
        storeView.backgroundColor = Colors.gray95.color
        return storeView
    }()

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
            visitTypeView,
            storeView
        ])
        
        visitTypeView.addSubViews([
            visitTypeImageView,
            visitTimeLabel
        ])
        
        storeView.addSubViews([
            imageView,
            titleStackView,
            tagStackView
        ])
        
        titleStackView.addArrangedSubview(tagStackView)
        titleStackView.addArrangedSubview(titleLabel)
    
        tagStackView.addArrangedSubview(tagLabel)
    }

    override func bindConstraints() {
        super.bindConstraints()

        visitTypeView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(80)
        }
        
        visitTypeImageView.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(15)
        }
        
        visitTimeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(visitTypeImageView.snp.bottom).offset(6)
        }
        
        storeView.snp.makeConstraints {
            $0.leading.equalTo(visitTypeView.snp.trailing).offset(8)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }

        titleStackView.snp.makeConstraints {
            $0.centerY.equalTo(imageView)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }

    func bind(item: MyVisitStore) {
        imageView.setImage(urlString: item.store.categories.first?.imageUrl)
        titleLabel.text = item.store.name
        tagLabel.text = item.store.categories.map { "#\($0.name)" }.joined(separator: " ")
        visitTimeLabel.text = DateUtils.toString(dateString: item.createdAt, format: "HH:mm:ss")
        
        switch item.type {
        case .exists:
            visitTypeImageView.image = Icons.faceSmile.image.withTintColor(Colors.mainGreen.color)
            visitTypeView.backgroundColor = Colors.mainGreen.color.withAlphaComponent(0.1)
        case .notExists:
            visitTypeImageView.image = Icons.faceSad.image.withTintColor(Colors.mainRed.color)
            visitTypeView.backgroundColor = Colors.mainRed.color.withAlphaComponent(0.1)
        case .unknown:
            break
        }
    }
}
