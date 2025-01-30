import UIKit

import Common
import DesignSystem
import Model

final class BossStoreDetailReviewCell: BaseCollectionViewCell {
    private lazy var feedbackGenerator = UISelectionFeedbackGenerator()
    
    private static let sharedCell = BossStoreDetailReviewCell()
    
    enum Layout {
        static func size(width: CGFloat, viewModel: BossStoreDetailReviewCellViewModel) -> CGSize {
            
            sharedCell.bind(viewModel)
            
            let size: CGSize = .init(width: width, height: UIView.layoutFittingCompressedSize.height)
            let cellSize = sharedCell.systemLayoutSizeFitting(
                size,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return cellSize
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray80.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.StoreDetail.Review.report, for: .normal)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        
        return button
    }()
    
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray40.color
        view.layer.cornerRadius = 1
        
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray40.color
        label.font = Fonts.medium.font(size: 12)
        
        return label
    }()
    
    private let medalBadge = StoreDetailMedalBadgeView()
    
    private let starBadge = StoreDetailStarBadgeView()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray80.color
        label.font = Fonts.regular.font(size: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    private let stackView = UIStackView()
    private let photoListView = ReviewPhotoListView(config: .init(size: CGSize(width: 96, height: 96), canEdit: false))
    
    private let likeButton = LikeButton()
    
    private weak var viewModel: BossStoreDetailReviewCellViewModel?
    
    weak var containerViewController: UIViewController? {
        didSet {
            photoListView.containerViewController = containerViewController
        }
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
        ])
        
        containerView.addSubViews([
            nameLabel,
            rightButton,
            dotView,
            dateLabel,
            medalBadge,
            starBadge,
            stackView,
            contentLabel,
            likeButton
        ])
        
        stackView.addArrangedSubview(photoListView)
        
        feedbackGenerator.prepare()
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(dateLabel.snp.leading)
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(nameLabel)
        }
        
        dotView.snp.makeConstraints {
            $0.centerY.equalTo(rightButton)
            $0.size.equalTo(2)
            $0.trailing.equalTo(rightButton.snp.leading).offset(-4)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalTo(dotView.snp.leading).offset(-4)
            $0.centerY.equalTo(dotView)
        }
        
        medalBadge.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
        }

        starBadge.snp.makeConstraints {
            $0.centerY.equalTo(medalBadge)
            $0.leading.equalTo(medalBadge.snp.trailing).offset(4)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(medalBadge.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }

        contentLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(stackView.snp.bottom).offset(8)
        }
        
        likeButton.snp.makeConstraints {
            $0.leading.equalTo(contentLabel)
            $0.top.equalTo(contentLabel.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    func bind(_ viewModel: BossStoreDetailReviewCellViewModel) {
        self.viewModel = viewModel
        
        updateUI()
        
        viewModel.output.updateUI
            .main
            .sink { [weak self] in
                self?.updateUI()
            }
            .store(in: &cancellables)
        
        likeButton.tapPublisher
            .sink { [weak self] in
                self?.viewModel?.input.didTapLikeButton.send()
                DispatchQueue.main.async {
                    self?.feedbackGenerator.selectionChanged()
                }
            }
            .store(in: &cancellables)
        
        rightButton.tapPublisher
            .subscribe(viewModel.input.didTapRightButton)
            .store(in: &cancellables)
    }
    
    private func updateUI() {
        guard let viewModel else { return }
        
        let review = viewModel.output.review
        nameLabel.text = review.user.name
        dateLabel.text = DateUtils.toString(dateString: review.createdAt, format: "yyyy.MM.dd")
        medalBadge.bind(review.user.medal)
        starBadge.prepareForReuse()
        starBadge.bind(review.rating)
        contentLabel.text = review.contents
        contentLabel.setLineHeight(lineHeight: 20)
        likeButton.bind(count: review.likeCount, reactedByMe: review.reactedByMe)
        photoListView.isHidden = review.images.isEmpty
        photoListView.setImages(review.images)
        
        if review.isOwner {
            backgroundColor = Colors.pink100.color
            medalBadge.containerView.backgroundColor = Colors.systemWhite.color
            starBadge.containerView.backgroundColor = Colors.systemWhite.color
            rightButton.setTitle("삭제", for: .normal)
        } else {
            backgroundColor = Colors.systemWhite.color
            medalBadge.containerView.backgroundColor = Colors.pink100.color
            starBadge.containerView.backgroundColor = Colors.pink100.color
            rightButton.setTitle(Strings.StoreDetail.Review.report, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        starBadge.prepareForReuse()
        medalBadge.prepareForReuse()
        photoListView.isHidden = true
        photoListView.setImages([])
    }
}
