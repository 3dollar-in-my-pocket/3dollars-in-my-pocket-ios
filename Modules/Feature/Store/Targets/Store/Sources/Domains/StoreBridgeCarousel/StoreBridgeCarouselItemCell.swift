import UIKit
import Common
import DesignSystem
import SnapKit
import Then
import Model

final class StoreBridgeCarouselItemCell: BaseCollectionViewCell {
    enum Layout {
        static let bottomInfoHeight: CGFloat = 56 // 하단 정보들 고정 높이
        static let spacing: CGFloat = 8 // 이미지와 하단 정보 사이 고정 spacing
        
        // 서버 응답 이미지 크기에 따른 동적 사이즈 계산
        static func size(for imageStyle: SDImageStyle) -> CGSize {
            let imageWidth = max(imageStyle.width, 80) // 최소 너비 보장
            let imageHeight = max(imageStyle.height, 80) // 최소 높이 보장
            let totalHeight = imageHeight + spacing + bottomInfoHeight
            return CGSize(width: imageWidth, height: totalHeight)
        }
    }

    private let imageView = UIImageView().then {
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray10.color
        $0.contentMode = .scaleAspectFit // 68x68 정사각형 이미지에 맞게 변경
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
    }

    private let metricsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }

    private let ratingStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 2
        $0.alignment = .center
    }

    private let starIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFit
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
        $0.contentMode = .scaleAspectFit
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
        $0.contentMode = .scaleAspectFit
    }

    private let distanceLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 12)
        $0.textColor = Colors.mainPink.color
    }
    
    // 동적 constraint를 위한 저장 속성
    private var imageViewWidthConstraint: Constraint?
    private var imageViewHeightConstraint: Constraint?

    override func setup() {
        contentView.addSubViews([imageView, titleLabel, metricsStackView, distanceStackView])
        
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
        imageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            // 동적 크기는 bind 메서드에서 설정
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(Layout.spacing)
            $0.leading.trailing.equalToSuperview()
        }

        metricsStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview()
        }

        starIcon.snp.makeConstraints {
            $0.size.equalTo(12)
        }

        reviewIcon.snp.makeConstraints {
            $0.size.equalTo(12)
        }

        distanceStackView.snp.makeConstraints {
            $0.top.equalTo(metricsStackView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview() // 하단 영역이 Layout.bottomInfoHeight를 넘지 않도록
        }

        locationIcon.snp.makeConstraints {
            $0.size.equalTo(12)
        }
    }

    func bind(item: StoreImagePreviewCard) {
        // 서버 응답 이미지 크기에 따른 동적 크기 설정
        updateImageViewSize(imageStyle: item.image.style)
        
        // 이미지 설정
        imageView.setImage(urlString: item.image.url)
        
        // 제목 설정
        titleLabel.setSDText(item.title)
        
        // 메트릭 라벨 설정 (별점, 리뷰 개수)
        if item.metricLabel.count >= 2 {
            let ratingMetric = item.metricLabel[0]
            let reviewMetric = item.metricLabel[1]
            
            // 별점
            starIcon.setImage(urlString: ratingMetric.image?.url)
            ratingLabel.setSDText(ratingMetric.text)
            
            // 리뷰 개수
            reviewIcon.setImage(urlString: reviewMetric.image?.url)
            reviewLabel.setSDText(reviewMetric.text)
        }
        
        // 컨텍스트 라벨 설정 (거리)
        if let contextLabel = item.contextLabel.first {
            locationIcon.setImage(urlString: contextLabel.image?.url)
            distanceLabel.setSDText(contextLabel.text)
        }
    }
    
    private func updateImageViewSize(imageStyle: SDImageStyle) {
        // 기존 constraint 제거
        imageViewWidthConstraint?.deactivate()
        imageViewHeightConstraint?.deactivate()
        
        // 새로운 크기로 constraint 설정
        imageView.snp.makeConstraints {
            imageViewWidthConstraint = $0.width.equalTo(imageStyle.width).constraint
            imageViewHeightConstraint = $0.height.equalTo(imageStyle.height).constraint
        }
    }
}
