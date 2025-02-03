import Foundation
import UIKit
import Combine

import Then
import Common
import DesignSystem
import Log
import Model

final class BossStoreFeedbackListViewController: BaseViewController {
    override var screenName: ScreenName {
        return .bossStoreDetail
    }
    
    enum Layout {
        static let itemSpacing: CGFloat = 24
        static let contentInsets: UIEdgeInsets = .init(top: 16, left: 0, bottom: 16, right: 0)
    }

    private let backButton = UIButton().then {
        $0.setImage(Icons.arrowLeft.image.withTintColor(Colors.gray100.color), for: .normal)
    }

    private let titleLabel = UILabel().then {
        $0.text = "피드백"
        $0.textColor = Colors.gray100.color
        $0.font = Fonts.medium.font(size: 16)
    }

    private let headerLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.text = "피드백"
    }

    private let countLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 16)
        $0.textColor = Colors.gray100.color
    }
    
    private let scrollView = UIScrollView()

    private let reviewWriteButton = UIButton().then {
        $0.titleLabel?.font = Fonts.bold.font(size: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("피드백/리뷰 작성하기", for: .normal)
        $0.backgroundColor = Colors.mainPink.color
    }
    
    private let bottomBackgroundView = UIControl().then {
        $0.backgroundColor = Colors.mainPink.color
    }

    private let itemContainerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 24
    }
    
    private let containerView = UIView()

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = Layout.itemSpacing
    }
    
    private let viewModel: BossStoreFeedbackListViewModel
    
    static func instance(_ viewModel: BossStoreFeedbackListViewModel) -> BossStoreFeedbackListViewController {
        return BossStoreFeedbackListViewController(viewModel)
    }
    
    init(_ viewModel: BossStoreFeedbackListViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubViews([
            backButton,
            titleLabel,
            headerLabel,
            countLabel,
            scrollView,
            reviewWriteButton,
            bottomBackgroundView
        ])
        
        scrollView.addSubview(containerView)
        containerView.addSubview(itemContainerView)
        itemContainerView.addSubview(stackView)
        
        backButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }

        headerLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
        }

        countLabel.snp.makeConstraints {
            $0.leading.equalTo(headerLabel.snp.trailing).offset(2)
            $0.centerY.equalTo(headerLabel)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(reviewWriteButton.snp.top)
        }

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        itemContainerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Layout.contentInsets.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(Layout.contentInsets.bottom)
        }
        
        reviewWriteButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomBackgroundView.snp.top)
            $0.height.equalTo(64)
        }
        
        bottomBackgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    override func bindEvent() {
        super.bindEvent()

        for index in viewModel.output.feedbacks.indices {
            let feedback = viewModel.output.feedbacks[index]
            let itemView = self.generateStackItem(feedback: feedback, index: index)

            self.stackView.addArrangedSubview(itemView)
        }

        countLabel.text = "\(viewModel.output.feedbackTotalCount)개"
        
        backButton.tapPublisher
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.back()
            }
            .store(in: &cancellables)
        
        reviewWriteButton.tapPublisher
            .merge(with: bottomBackgroundView.controlPublisher(for: .touchUpInside).mapVoid)
            .subscribe(viewModel.input.didTapReviewWrtieButton)
            .store(in: &cancellables)
    }

    private func generateStackItem(feedback: FeedbackCountWithRatioResponse, index: Int) -> BossStoreFeedbackItemView {
        let itemView = BossStoreFeedbackItemView()
        itemView.bind(feedback: feedback, isTopRate: index < 3)
        return itemView
    }
    
    private func back() {
        navigationController?.popViewController(animated: true)
    }
}
