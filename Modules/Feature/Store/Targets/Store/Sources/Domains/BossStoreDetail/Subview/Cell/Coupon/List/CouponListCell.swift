import UIKit
import Common
import DesignSystem
import Model
import StoreInterface

final class CouponListCell: BaseCollectionViewCell {
    
    enum Layout {
        static func size(width: CGFloat, viewModel: BossStoreCouponViewModel) -> CGSize {
            let couponHeight = BossStoreCouponView.Layout.size(width: width, viewModel: viewModel).height
            var totalHeight: CGFloat = 0
            totalHeight += 28
            totalHeight += 48
            totalHeight += 12
            totalHeight += couponHeight
            totalHeight += 28
            return CGSize(width: width, height: totalHeight)
        }
    }
    
    private let couponView = BossStoreCouponView()
    private let storeView = UIView()
    private let lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = Colors.gray80.color
        return lineView
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

    private let storeTapGesture = UITapGestureRecognizer()
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
        
        contentView.addSubViews([
            storeView,
            couponView,
            lineView
        ])
        
        storeView.addSubViews([
            titleStackView,
            tagStackView,
            imageView
        ])
        
        titleStackView.addArrangedSubview(tagStackView)
        titleStackView.addArrangedSubview(titleLabel)

        tagStackView.addArrangedSubview(tagLabel)
        
        storeView.isUserInteractionEnabled = true
        storeView.addGestureRecognizer(storeTapGesture)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        storeView.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalToSuperview().inset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        lineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
        
        couponView.snp.makeConstraints {
            $0.top.equalTo(storeView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(28)
        }
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        titleStackView.snp.makeConstraints {
            $0.centerY.equalTo(imageView)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    func bind(viewModel: BossStoreCouponViewModel) {
        couponView.bind(viewModel: viewModel)
        if let store = viewModel.output.store {
            imageView.setImage(urlString: store.categories.first?.imageUrl)
            titleLabel.text = store.name
            tagLabel.text = store.categoriesString
        }
        storeTapGesture.tapPublisher.mapVoid
            .subscribe(viewModel.input.didTapStoreView)
            .store(in: &cancellables)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.clear()
        titleLabel.text = nil
        tagLabel.text = nil
    }
}
