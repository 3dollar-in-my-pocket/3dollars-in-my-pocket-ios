import UIKit

import Common
import DesignSystem
import Model

/// 메인 리스트뷰 리스트 광고 (STORE_LIST)
final class HomeListAdCell: BaseCollectionViewCell {

    enum Layout {
        static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 90)
    }
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.systemWhite.color
    }

    private let imageView = UIImageView().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        $0.layer.masksToBounds = true
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray90.color
        $0.textAlignment = .left
    }

    private let contentLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
        $0.textAlignment = .left
    }

    private let adButton = UIButton().then {
        $0.setTitle("광고", for: .normal)
        $0.titleLabel?.font = Fonts.medium.font(size: 10)
        $0.backgroundColor = Colors.pink100.color
        $0.layer.cornerRadius = 9
        $0.setTitleColor(Colors.mainPink.color, for: .normal)
        $0.isUserInteractionEnabled = false
    }

    private var viewModel: HomeListAdCellViewModel?

    override func setup() {
        super.setup()

        contentView.addSubview(containerView)
        containerView.addSubViews([
            imageView,
            adButton,
            titleLabel,
            contentLabel,
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

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

        imageView.setImage(urlString: viewModel.output.item.imageUrl)
        titleLabel.text = viewModel.output.item.title
        contentLabel.text = viewModel.output.item.subTitle
        if let fontColor = viewModel.output.item.fontColor {
            contentLabel.textColor = UIColor(hex: fontColor)
        }
        if let backgroundColor = viewModel.output.item.bgColor {
            containerView.backgroundColor = UIColor(hex: backgroundColor)
        }
    }
}
