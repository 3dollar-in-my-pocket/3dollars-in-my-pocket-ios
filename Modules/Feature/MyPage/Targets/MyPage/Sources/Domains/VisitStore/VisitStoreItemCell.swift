import UIKit

import Common
import DesignSystem
import Then
import Model

final class VisitStoreItemCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 80
    }

    private let visitTypeView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray95.color
    }
    
    private let visitTypeImageView = UIImageView()
    
    private let visitTimeLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 10)
        $0.textColor = Colors.systemWhite.color
    }
    
    private let storeView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray95.color
    }

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
