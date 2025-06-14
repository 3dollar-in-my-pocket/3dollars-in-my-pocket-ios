import UIKit

import Common
import Model

final class FeedCellHeaderView: BaseView {
    enum Layout {
        static let height: CGFloat = 64
    }
    
    private let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray40.color
        label.numberOfLines = 1
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        return label
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    private let metadataStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 4
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        addSubViews([
            categoryImageView,
            verticalStackView
        ])
        
        verticalStackView.addArrangedSubview(topLabel)
        topLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        verticalStackView.setCustomSpacing(0, after: topLabel)
        verticalStackView.addArrangedSubview(contentLabel)
        contentLabel.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        verticalStackView.setCustomSpacing(4, after: contentLabel)
        verticalStackView.addArrangedSubview(metadataStackView)
        
        categoryImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(2)
            $0.bottom.equalToSuperview().offset(-2)
            $0.size.equalTo(60)
        }
        
        verticalStackView.snp.makeConstraints {
            $0.leading.equalTo(categoryImageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    func bind(header: GeneralFeedHeaderResponse) {
        categoryImageView.setImage(urlString: header.image.imageUrl)
        topLabel.setSDText(header.top)
        contentLabel.setSDText(header.content)
        setupMetadataStackView(header.metadata)
    }
    
    private func setupMetadataStackView(_ metadatas: [FeedHeaderMetadataResponse]) {
        for (index, metadata) in metadatas.enumerated() {
            let metadataView = MetadataView()
            metadataView.bind(metadata: metadata)
            metadataStackView.addArrangedSubview(metadataView)
            
            if index < metadatas.count {
                metadataStackView.addArrangedSubview(createDivider())
            }
        }
    }
    
    private func createDivider() -> UIView {
        let view = UIView()
        view.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(8)
        }
        view.backgroundColor = Colors.gray20.color
        return view
    }
}

extension FeedCellHeaderView {
    final class MetadataView: BaseView {
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 3
            return stackView
        }()
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        private let label: UILabel = {
            let label = UILabel()
            label.font = Fonts.medium.font(size: 12)
            label.textColor = Colors.gray40.color
            return label
        }()
        
        override func setup() {
            setupUI()
        }
        
        private func setupUI() {
            addSubview(stackView)
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(label)
            
            stackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            imageView.snp.makeConstraints {
                $0.size.equalTo(12)
            }
        }
        
        func bind(metadata: FeedHeaderMetadataResponse) {
            imageView.setImage(urlString: metadata.icon.imageUrl)
            label.setSDText(metadata.content)
        }
    }
}
