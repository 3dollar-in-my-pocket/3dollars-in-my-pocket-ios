import UIKit
import Common
import DesignSystem
import Model

final class BossStoreInfoCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 446
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.text = "가게 정보 & 메뉴"
    }

    private let updatedAtLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
    }

    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 20
    }

    private let snsTitleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.text = "SNS"
    }

    let snsButton = UIButton().then {
        $0.titleLabel?.font = Fonts.medium.font(size: 12)
        $0.setTitleColor(Colors.mainPink.color, for: .normal)
    }

    private let introductionTitleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.text = "사장님 한마디"
    }

    private let introductionValueLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }

    private let photoView = UIImageView().then {
        $0.layer.cornerRadius = 12
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
    }

    override func setup() {
        backgroundColor = .clear

        addSubViews([
            titleLabel,
            updatedAtLabel,
            containerView,
            photoView
        ])

        containerView.addSubViews([
            snsTitleLabel,
            snsButton,
            introductionTitleLabel,
            introductionValueLabel
        ])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        updatedAtLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview()
        }

        photoView.snp.makeConstraints {
            $0.top.equalTo(updatedAtLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(210)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(photoView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(168)
        }

        snsTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.width.equalTo(104)
        }

        snsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.leading.equalTo(snsTitleLabel.snp.trailing)
            $0.centerY.equalTo(snsTitleLabel)
        }

        introductionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(snsTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(16)
        }

        introductionValueLabel.snp.makeConstraints {
            $0.top.equalTo(introductionTitleLabel.snp.bottom).offset(2)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    func bind(_ viewModel: BossStoreInfoCellViewModel) {
        if let snsUrl = viewModel.output.snsUrl {
            self.snsButton.isHidden = snsUrl.isEmpty
            self.snsButton.setTitle(snsUrl, for: .normal)
        } else {
            self.snsButton.isHidden = true
        }
        self.introductionValueLabel.text = viewModel.output.introduction
        if let imageUrl = viewModel.output.imageUrl {
            self.photoView.setImage(urlString: imageUrl)
        }

        updatedAtLabel.text = viewModel.output.updatedAt
    }
}
