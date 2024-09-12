import UIKit

import Common
import DesignSystem
import Model

/// 메인 리스트뷰 리스트 광고 (STORE_LIST)
final class HomeListAdCell: BaseCollectionViewCell {

    enum Layout {
        static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 90)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.backgroundColor = Colors.systemWhite.color
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray90.color
        label.textAlignment = .left
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray50.color
        label.textAlignment = .left
        return label
    }()

    private let adButton: UIButton = {
        let button = UIButton()
        button.setTitle("광고", for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 10)
        button.backgroundColor = Colors.pink100.color
        button.layer.cornerRadius = 9
        button.setTitleColor(Colors.mainPink.color, for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()

    private var viewModel: HomeListAdCellViewModel?

    override func setup() {
        super.setup()

        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubViews([
            imageView,
            adButton,
            titleLabel,
            contentLabel,
        ])
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(CGSize(width: 90, height: 90))
        }

        adButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.size.equalTo(CGSize(width: 32, height: 18))
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(adButton.snp.bottom).offset(4)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }

    func bind(viewModel: HomeListAdCellViewModel) {
        self.viewModel = viewModel

        let advertisement = viewModel.output.item
        imageView.setImage(urlString: advertisement.image?.url)
        
        titleLabel.text = advertisement.title?.content
        if let titleColor = advertisement.title?.fontColor {
            titleLabel.textColor = UIColor(hex: titleColor)
        }
        
        
        contentLabel.text = advertisement.subTitle?.content
        if let contentColor = advertisement.subTitle?.fontColor {
            contentLabel.textColor = UIColor(hex: contentColor)
        }
        
        if let backgroundColor = advertisement.background?.color {
            containerView.backgroundColor = UIColor(hex: backgroundColor)
        }
    }
}
