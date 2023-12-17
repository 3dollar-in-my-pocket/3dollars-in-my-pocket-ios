import UIKit
import Common
import DesignSystem
import Model

final class BossStoreInfoCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateHeight(introduction: String?) -> CGFloat {
            let introducationHeight = calculageIntroductionHeight(introduction: introduction)
            
            return introducationHeight + 356
        }
        
        static func calculageIntroductionHeight(introduction: String?) -> CGFloat {
            guard let introduction else { return .zero }
            let label = UILabel()
            label.font = Fonts.medium.font(size: 12)
            label.numberOfLines = 0
            label.text = introduction
            label.sizeToFit()
            
            return label.frame.height
        }
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.text = Strings.BossStoreDetail.Info.title
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
        $0.text = Strings.BossStoreDetail.Info.sns
    }

    let snsButton = UIButton().then {
        $0.titleLabel?.font = Fonts.medium.font(size: 12)
        $0.setTitleColor(Colors.mainPink.color, for: .normal)
        $0.titleLabel?.textAlignment = .right
    }

    private let introductionTitleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.text = Strings.BossStoreDetail.Info.introduction
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
        $0.backgroundColor = Colors.gray10.color
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
            $0.bottom.equalTo(introductionValueLabel).offset(16)
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
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    func bind(_ viewModel: BossStoreInfoCellViewModel) {
        if let snsUrl = viewModel.output.info.snsUrl {
            snsButton.isHidden = snsUrl.isEmpty
            snsButton.setTitle(snsUrl, for: .normal)
        } else {
            snsButton.isHidden = true
        }
        introductionValueLabel.text = viewModel.output.info.introduction
        if let imageUrl = viewModel.output.info.imageUrl {
            photoView.setImage(urlString: imageUrl)
        }

        updatedAtLabel.text = DateUtils.toString(dateString: viewModel.output.info.updatedAt, format: "yyyy.MM.dd " + Strings.BossStoreDetail.Info.update)
        
        snsButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapSnsButton)
            .store(in: &cancellables)
    }
}
