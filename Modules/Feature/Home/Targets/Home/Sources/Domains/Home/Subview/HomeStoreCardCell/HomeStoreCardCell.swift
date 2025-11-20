import UIKit

import Common
import DesignSystem
import Model

import CombineCocoa
import Kingfisher

final class HomeStoreCardCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 81, height: 152)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = DesignSystemAsset.Colors.gray100.color
        return view
    }()
    
    private let categoryImage = UIImageView()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        label.textColor = DesignSystemAsset.Colors.gray40.color
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = DesignSystemAsset.Colors.systemWhite.color
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let badgeImageView = UIImageView()
    
    private let tagStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private let infoView = HomeStoreCardInfoView()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.mainPink.color
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 14)
        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        return button
    }()
    
    private var viewModel: HomeStoreCardCellViewModel?
    
    func bind(viewModel: HomeStoreCardCellViewModel) {
        bindData(viewModel.output.data)
        
        actionButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapActionButton)
            .store(in: &cancellables)
        
        self.viewModel = viewModel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        infoView.prepareForReuse()
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        actionButton.kf.cancelImageDownloadTask()
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            categoryImage,
            categoryLabel,
            titleLabel,
            badgeImageView,
            tagStackView,
            infoView,
            actionButton
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        categoryImage.snp.makeConstraints {
            $0.width.height.equalTo(48)
            $0.left.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(categoryImage)
            $0.left.equalTo(categoryImage.snp.right).offset(14)
            $0.right.equalToSuperview().offset(-16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(categoryLabel)
            $0.top.equalTo(categoryLabel.snp.bottom).offset(4)
        }
        
        badgeImageView.snp.makeConstraints {
            $0.width.height.equalTo(14)
            $0.left.equalTo(titleLabel.snp.right).offset(4)
            $0.top.equalTo(titleLabel)
        }
        
        tagStackView.snp.makeConstraints {
            $0.left.equalTo(categoryLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        infoView.snp.makeConstraints {
            $0.left.equalTo(categoryLabel)
            $0.centerY.equalTo(actionButton)
        }
        
        actionButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func bindData(_ data: HomeCardSectionResponse) {
        categoryImage.setImage(urlString: data.image?.url)
        
        if let subTitle = data.subTitle {
            categoryLabel.setSDText(subTitle)
        }
        
        if let title = data.title {
            titleLabel.setSDText(title)
        }
        
        setupTagLabels(labels: data.labels)
        
        if let badge = data.badge {
            setupBadge(badge: badge)
        }
        
        infoView.bind(data.metadata)
        setupButton(button: data.button)
    }
    
    private func setupTagLabels(labels: [SDChip]) {
        for label in labels {
            let tagView = HomeStoreCardCellTagView()
            tagView.bind(chip: label)
            tagStackView.addArrangedSubview(tagView)
        }
    }
    
    private func setupBadge(badge: SDImage) {
        badgeImageView.setImage(urlString: badge.url)
        badgeImageView.snp.updateConstraints {
            $0.width.equalTo(badge.style.width)
            $0.height.equalTo(badge.style.height)
        }
    }
    
    private func setupButton(button: SDButton?) {
        if let button {
            actionButton.setSDButton(button)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }
}
