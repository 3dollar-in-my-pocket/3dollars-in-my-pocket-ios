import UIKit

import Common
import DesignSystem
import Model
import AppInterface

final class StoreDetailOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 78 + topPadding + bottomPadding
        static let topPadding: CGFloat = 8
        static let bottomPadding: CGFloat = 20
    }
    
    private let categoryImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray50.color
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private let metadataStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        labelStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        metadataStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setup() {
        contentView.addSubViews([
            categoryImage,
            subtitleLabel,
            titleLabel,
            badgeImageView,
            labelStackView,
            metadataStackView
        ])
        
        categoryImage.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalTo(categoryImage.snp.trailing).offset(8)
            $0.top.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(subtitleLabel)
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(4)
        }
        
        badgeImageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.size.equalTo(14)
            $0.top.equalTo(titleLabel).offset(4)
        }
        
        labelStackView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        metadataStackView.snp.makeConstraints {
            $0.centerY.equalTo(labelStackView)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func bind(_ viewModel: StoreDetailOverviewCellViewModel) {
        let data = viewModel.output.data
        
        if let image = data.image {
            categoryImage.setImage(urlString: image.url)
        }
        
        if let title = data.title {
            titleLabel.setSDText(title)
        }
        
        if let subtitle = data.subTitle {
            subtitleLabel.setSDText(subtitle)
        }
        
        if let badge = data.badge {
            badgeImageView.setImage(urlString: badge.url)
            badgeImageView.snp.updateConstraints {
                $0.width.equalTo(badge.style.width)
                $0.height.equalTo(badge.style.height)
            }
        }
        
        setupLabelStackView(labels: data.labels)
        setupMetdataStackView(metadatas: data.metadata)
    }
    
    private func setupLabelStackView(labels: [SDChip]) {
        for label in labels {
            let tagView = TagView()
            tagView.bind(chip: label)
            labelStackView.addArrangedSubview(tagView)
        }
    }
    
    private func setupMetdataStackView(metadatas: [SDChip]) {
        for metadata in metadatas {
            let metadataLabel = MetadataLabel(sdChip: metadata)
            metadataStackView.addArrangedSubview(metadataLabel)
        }
    }
}

extension StoreDetailOverviewCell {
    private final class TagView: UIStackView {
        enum Layout {
            static let defaultImageSize = CGSize(width: 16, height: 16)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setupUI()
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            layer.cornerRadius = 12
            layer.masksToBounds = true
            layoutMargins = .init(top: 4, left: 8, bottom: 4, right: 8)
            isLayoutMarginsRelativeArrangement = true
            spacing = 4
        }
        
        func bind(chip: SDChip) {
            if let image = chip.image {
                let imageView = UIImageView()
                imageView.setImage(urlString: image.url)
                
                imageView.snp.makeConstraints {
                    $0.width.equalTo(image.style.width)
                    $0.height.equalTo(image.style.height)
                }
                addArrangedSubview(imageView)
            }
            
            let label = UILabel()
            label.font = Fonts.medium.font(size: 12)
            label.setSDText(chip.text)
            addArrangedSubview(label)
            
            if let style = chip.style {
                backgroundColor = UIColor(hex: style.backgroundColor)
            }
        }
    }
    
    private class MetadataLabel: UIStackView {
        private let metadata: SDChip
        
        init(sdChip: SDChip) {
            self.metadata = sdChip
            super.init(frame: .zero)
            
            setupUI()
        }
        
        @MainActor required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            axis = .horizontal
            spacing = 2
            
            if let image = metadata.image {
                let imageView = UIImageView()
                imageView.setImage(urlString: image.url)
                imageView.snp.makeConstraints {
                    $0.width.equalTo(image.style.width)
                    $0.height.equalTo(image.style.height)
                }
                addArrangedSubview(imageView)
            }
            
            let label = UILabel()
            label.font = Fonts.medium.font(size: 12)
            label.textColor = Colors.gray40.color
            label.setSDText(metadata.text)
            addArrangedSubview(label)
        }
    }
}
