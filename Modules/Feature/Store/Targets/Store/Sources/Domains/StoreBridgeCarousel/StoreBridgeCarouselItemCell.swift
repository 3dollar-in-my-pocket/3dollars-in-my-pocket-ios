import UIKit
import Common
import DesignSystem
import SnapKit
import Then
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
    
    private let imageContainerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.borderColor = Colors.gray10.color.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray100.color
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let metricsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    private let ratingStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    
    private let starIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let ratingLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
    }
    
    private let reviewStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    
    private let reviewIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let reviewLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
    }
    
    private let distanceStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }
    
    private let locationIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let distanceLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.mainPink.color
    }
    
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
