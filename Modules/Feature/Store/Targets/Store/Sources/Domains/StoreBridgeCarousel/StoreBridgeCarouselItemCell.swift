import UIKit
import Common
import DesignSystem
import SnapKit
import Model

final class StoreBridgeCarouselItemCell: BaseCollectionViewCell {
    enum Layout {
        static let imageContainerSize: CGFloat = 128
        static let bottomInfoHeight: CGFloat = 56 // 하단 정보들 고정 높이
        static let spacing: CGFloat = 8 // 이미지와 하단 정보 사이 고정 spacing
        
        // 서버 응답 이미지 크기에 따른 동적 사이즈 계산
        static func size() -> CGSize {
            let totalHeight = imageContainerSize + spacing + bottomInfoHeight
            return CGSize(width: imageContainerSize, height: totalHeight)
        }
    }
    
    private let imageContainerView: UIView = {
        let imageContainerView = UIView()
        imageContainerView.backgroundColor = Colors.gray0.color
        imageContainerView.layer.borderColor = Colors.gray10.color.cgColor
        imageContainerView.layer.borderWidth = 1
        imageContainerView.layer.cornerRadius = 16
        imageContainerView.clipsToBounds = true
        return imageContainerView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.semiBold.font(size: 14)
        titleLabel.textColor = Colors.gray100.color
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        return titleLabel
    }()
    
    private let metricsStackView: UIStackView = {
        let metricsStackView = UIStackView()
        metricsStackView.axis = .horizontal
        metricsStackView.spacing = 4
        metricsStackView.alignment = .center
        return metricsStackView
    }()
    
    private let ratingStackView: UIStackView = {
        let ratingStackView = UIStackView()
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 2
        ratingStackView.alignment = .center
        return ratingStackView
    }()
    
    private let starIcon: UIImageView = {
        let starIcon = UIImageView()
        starIcon.contentMode = .scaleAspectFill
        return starIcon
    }()
    
    private let ratingLabel: UILabel = {
        let ratingLabel = UILabel()
        ratingLabel.font = Fonts.medium.font(size: 12)
        ratingLabel.textColor = Colors.gray60.color
        return ratingLabel
    }()
    
    private let reviewStackView: UIStackView = {
        let reviewStackView = UIStackView()
        reviewStackView.axis = .horizontal
        reviewStackView.spacing = 2
        reviewStackView.alignment = .center
        return reviewStackView
    }()
    
    private let reviewIcon: UIImageView = {
        let reviewIcon = UIImageView()
        reviewIcon.contentMode = .scaleAspectFill
        return reviewIcon
    }()
    
    private let reviewLabel: UILabel = {
        let reviewLabel = UILabel()
        reviewLabel.font = Fonts.medium.font(size: 12)
        reviewLabel.textColor = Colors.gray60.color
        return reviewLabel
    }()
    
    private let distanceStackView: UIStackView = {
        let distanceStackView = UIStackView()
        distanceStackView.axis = .horizontal
        distanceStackView.spacing = 2
        distanceStackView.alignment = .center
        return distanceStackView
    }()
    
    private let locationIcon: UIImageView = {
        let locationIcon = UIImageView()
        locationIcon.contentMode = .scaleAspectFill
        return locationIcon
    }()
    
    private let distanceLabel: UILabel = {
        let distanceLabel = UILabel()
        distanceLabel.font = Fonts.medium.font(size: 12)
        distanceLabel.textColor = Colors.mainPink.color
        return distanceLabel
    }()
    
    override func setup() {
        contentView.addSubViews([imageContainerView, titleLabel, metricsStackView, distanceStackView])
        
        imageContainerView.addSubview(imageView)
        
        ratingStackView.addArrangedSubview(starIcon)
        ratingStackView.addArrangedSubview(ratingLabel)
        
        reviewStackView.addArrangedSubview(reviewIcon)
        reviewStackView.addArrangedSubview(reviewLabel)
        
        metricsStackView.addArrangedSubview(ratingStackView)
        metricsStackView.addArrangedSubview(reviewStackView)
        
        distanceStackView.addArrangedSubview(locationIcon)
        distanceStackView.addArrangedSubview(distanceLabel)
    }
    
    override func bindConstraints() {
        imageContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.imageContainerSize)
            $0.width.equalTo(Layout.imageContainerSize)
        }
        
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageContainerView.snp.bottom).offset(Layout.spacing)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        metricsStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        distanceStackView.snp.makeConstraints {
            $0.top.equalTo(metricsStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        starIcon.snp.makeConstraints {
            $0.size.equalTo(12)
        }
        
        reviewIcon.snp.makeConstraints {
            $0.size.equalTo(12)
        }
        
        locationIcon.snp.makeConstraints {
            $0.size.equalTo(12)
        }
    }
    
    func bind(item: StoreImagePreviewCard) {
        // 이미지 설정
        imageView.setImage(urlString: item.image.url)
        imageView.snp.updateConstraints {
            $0.width.equalTo(item.image.style.width)
            $0.height.equalTo(item.image.style.height)
        }
        
        // 제목 설정
        titleLabel.setSDText(item.title)
        
        metricsStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        // 메트릭 라벨 설정 (별점, 리뷰 개수)
        if let ratingMetric = item.metricLabel[safe: 0] {
            if let image = ratingMetric.image {
                starIcon.setImage(urlString: image.url)
                let size = CGSize(width: image.style.width, height: image.style.height)
                starIcon.snp.updateConstraints {
                    $0.size.equalTo(size)
                }
                starIcon.isHidden = false
            } else {
                starIcon.isHidden = true
            }
            
            ratingLabel.setSDText(ratingMetric.text)
            
            metricsStackView.addArrangedSubview(ratingStackView)
        }
        
        if let reviewMetric = item.metricLabel[safe: 1] {
            let divider = UIView()
            divider.backgroundColor = reviewMetric.text.flatMap { UIColor(hex: $0.fontColor) }
            divider.snp.makeConstraints {
                $0.width.equalTo(1)
                $0.height.equalTo(8)
            }
            metricsStackView.addArrangedSubview(divider)
            
            if let image = reviewMetric.image {
                reviewIcon.setImage(urlString: image.url)
                let size = CGSize(width: image.style.width, height: image.style.height)
                reviewIcon.snp.updateConstraints {
                    $0.size.equalTo(size)
                }
                reviewIcon.isHidden = false
            } else {
                reviewIcon.isHidden = true
            }
            
            reviewLabel.setSDText(reviewMetric.text)
            
            metricsStackView.addArrangedSubview(reviewStackView)
        }
        
        // 컨텍스트 라벨 설정 (거리)
        if let contextLabel = item.contextLabel.first {
            if let image = contextLabel.image {
                locationIcon.setImage(urlString: image.url)
                let size = CGSize(width: image.style.width, height: image.style.height)
                locationIcon.snp.updateConstraints {
                    $0.size.equalTo(size)
                }
                locationIcon.isHidden = false
            } else {
                locationIcon.isHidden = true
            }
            distanceLabel.setSDText(contextLabel.text)
        }
    }
}
