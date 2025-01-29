import UIKit
import SnapKit

import Common
import DesignSystem
import Model

final class BossStoreDetailReviewFeedbackSummaryCell: BaseCollectionViewCell {
    enum Layout {
        static let buttonMaximumDisplayCount: Int = 3
        static let buttonColumnCount: Int = 2
        static let buttonHeight: CGFloat = 30
        static let buttonContentEdgeInsets: UIEdgeInsets = .init(top: 6, left: 10, bottom: 6, right: 10)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.pink100.color
        $0.layer.cornerRadius = 12
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "피드백"
        $0.font = Fonts.medium.font(size: 10)
        $0.textColor = Colors.gray50.color
    }
    
    private var buttonContainerView = UIView()
    
    private let seeAllButton = UIButton().then {
        $0.setTitle("전체 보기", for: .normal)
        $0.titleLabel?.font = Fonts.medium .font(size: 12)
        $0.imageEdgeInsets.left = 4
        $0.semanticContentAttribute = .forceRightToLeft
        $0.contentEdgeInsets = Layout.buttonContentEdgeInsets
        $0.setTitleColor(Colors.gray90.color, for: .normal)
        $0.setImage(Icons.arrowRight.image
            .resizeImage(scaledTo: 12)
            .withTintColor(Colors.gray50.color), for: .normal)
        $0.backgroundColor = Colors.systemWhite.color
        $0.layer.cornerRadius = Layout.buttonHeight / 2
    }
    
    private weak var viewModel: BossStoreDetailReviewFeedbackSummaryCellViewModel?
    
    override func setup() {
        super.setup()

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(buttonContainerView)
        containerView.addSubview(seeAllButton)
    }
    
    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        buttonContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(64)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    func bind(viewModel: BossStoreDetailReviewFeedbackSummaryCellViewModel) {
        if viewModel != self.viewModel {
            updateUI(with: viewModel.output.feedbacks)
        }
        
        seeAllButton.tapPublisher
            .subscribe(viewModel.input.didTapSeeAllButton)
            .store(in: &cancellables)
        
        self.viewModel = viewModel
    }
    
    private func updateUI(with feedbacks: [FeedbackCountWithRatioResponse]) {
        buttonContainerView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let chunkedArray = Array(feedbacks.prefix(Layout.buttonMaximumDisplayCount)).chunked(into: Layout.buttonColumnCount)
        
        let buttonSpacing: CGFloat = 4
        var currentY: CGFloat = 0
        
        for (index, feedbacks) in chunkedArray.enumerated() {
            let stackView = UIStackView()
            stackView.alignment = .center
            stackView.spacing = buttonSpacing
            buttonContainerView.addSubview(stackView)
            stackView.snp.makeConstraints {
                $0.top.equalTo(currentY)
                $0.centerX.equalToSuperview()
            }
            feedbacks.forEach {
                let button = createFeedbackButton(emoji: $0.feedbackType.emoji, text: $0.feedbackType.description, count: $0.count)
                stackView.addArrangedSubview(button)
            }
            
            if index == chunkedArray.count - 1 {
                stackView.addArrangedSubview(seeAllButton)
            }
            
            currentY = (CGFloat((index + 1)) * Layout.buttonHeight) + buttonSpacing
        }
    }
    
    private func createFeedbackButton(emoji: String, text: String, count: Int) -> UIButton {
        let button = UIButton()
        button.setTitle("\(emoji) \(text) \(count)개", for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        button.setTitleColor(Colors.gray95.color, for: .normal)
        button.backgroundColor = Colors.systemWhite.color
        button.layer.cornerRadius = Layout.buttonHeight / 2
        button.contentEdgeInsets = Layout.buttonContentEdgeInsets
        return button
    }
}
