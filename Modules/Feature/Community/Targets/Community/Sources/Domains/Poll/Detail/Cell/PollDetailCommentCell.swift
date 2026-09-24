import UIKit

import Common
import DesignSystem
import Model

final class PollDetailCommentCell: BaseCollectionViewCell {
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    enum Layout {
        static func height(content: String) -> CGFloat {
            return content.height(font: Fonts.regular.font(size: 14), width: UIScreen.main.bounds.width - 40) + 106
        }
    }

    weak var containerVC: UIViewController?

    private let userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.font = Fonts.medium.font(size: 12)
        userNameLabel.textColor = Colors.gray80.color
        return userNameLabel
    }()
 
    private let badgeStackView: UIStackView = {
        let badgeStackView = UIStackView()
        badgeStackView.axis = .horizontal
        badgeStackView.spacing = 4
        return badgeStackView
    }()

    private let medalView = CommunityUserMedalView()

    private let writerBadge = BadgeView(text: "작성자")

    private let pollOptionBadge = BadgeView(text: "")

    private let contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.font = Fonts.regular.font(size: 14)
        contentLabel.textColor = Colors.gray80.color
        contentLabel.numberOfLines = 0
        return contentLabel
    }()

    private let dateStackView: UIStackView = {
        let dateStackView = UIStackView()
        dateStackView.axis = .horizontal
        dateStackView.spacing = 4
        dateStackView.alignment = .center
        return dateStackView
    }()

    private let dateSideDotView: UIView = {
        let dateSideDotView = UIView()
        dateSideDotView.backgroundColor = Colors.gray40.color
        return dateSideDotView
    }()

    private let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = Fonts.medium.font(size: 12)
        dateLabel.textColor = Colors.gray40.color
        return dateLabel
    }()

    private let reportOrUpdateButton: UIButton = {
        let reportOrUpdateButton = UIButton()
        reportOrUpdateButton.titleLabel?.font = Fonts.bold.font(size: 12)
        reportOrUpdateButton.setTitleColor(Colors.gray60.color, for: .normal)
        reportOrUpdateButton.contentEdgeInsets = .zero
        return reportOrUpdateButton
    }()
    
    let likeButton = LikeButton()

    private let lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = Colors.gray10.color
        return lineView
    }()

    private var viewModel: PollDetailCommentCellViewModel?

    override func setup() {
        super.setup()

        contentView.addSubViews([
            userNameLabel,
            dateStackView,
            badgeStackView,
            contentLabel,
            likeButton,
            lineView
        ])

        badgeStackView.addArrangedSubview(medalView)
        badgeStackView.addArrangedSubview(pollOptionBadge)
        badgeStackView.addArrangedSubview(writerBadge)

        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(dateSideDotView)
        dateStackView.addArrangedSubview(reportOrUpdateButton)

        dateStackView.setCustomSpacing(2, after: dateSideDotView)
        feedbackGenerator.prepare()
    }

    override func bindConstraints() {
        super.bindConstraints()

        userNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(20)
        }

        badgeStackView.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(20)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(badgeStackView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        dateStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(20)
        }

        dateSideDotView.snp.makeConstraints {
            $0.size.equalTo(2)
        }
        
        likeButton.snp.makeConstraints {
            $0.leading.equalTo(contentLabel)
            $0.top.equalTo(contentLabel.snp.bottom).offset(8)
        }

        lineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func bind(viewModel: PollDetailCommentCellViewModel) {
        self.viewModel = viewModel

        // Input
        reportOrUpdateButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReportOrUpdateButton)
            .store(in: &cancellables)
        
        likeButton.controlPublisher(for: .touchUpInside)
            .throttle(for: 1, scheduler: RunLoop.main, latest: false)
            .mapVoid
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.feedbackGenerator.selectionChanged()
            })
            .subscribe(viewModel.input.didTapReviewLikeButton)
            .store(in: &cancellables)

        // Output
        bindUI(with: viewModel.output.item, isMine: viewModel.output.isMine)

        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)

        viewModel.output.showDeleteAlert
            .main
            .withUnretained(self)
            .sink { owner, _ in owner.showDeleteAlert() }
            .store(in: &cancellables)
        
        viewModel.output.refresh
            .main
            .withUnretained(self)
            .sink { (owner: PollDetailCommentCell, _) in
                guard let viewModel = owner.viewModel else { return }
                owner.bindUI(with: viewModel.output.item, isMine: viewModel.output.isMine)
            }
            .store(in: &cancellables)
    }

    private func bindUI(with data: PollCommentWithUserApiResponse, isMine: Bool) {
        userNameLabel.text = data.commentWriter.name

        dateLabel.text = data.comment.updatedAt.toDate()?.toRelativeString() ?? data.comment.updatedAt

        reportOrUpdateButton.setTitle(isMine ? "삭제" : "신고", for: .normal)

        contentLabel.text = data.comment.content

        backgroundColor = isMine ? Colors.pink100.color : Colors.systemWhite.color

        writerBadge.isHidden = !data.poll.isWriter
        writerBadge.setBackgroundColor(isMine ? Colors.systemWhite.color : Colors.gray10.color)

        if let selectedOptionName = data.poll.selectedOptions.first?.name {
            pollOptionBadge.bind(text: selectedOptionName, suffix: "투표")
            pollOptionBadge.setBackgroundColor(isMine ? Colors.systemWhite.color : Colors.gray10.color)
            pollOptionBadge.isHidden = false
        } else {
            pollOptionBadge.isHidden = true
        }

        medalView.bind(
            imageUrl: data.commentWriter.medal.iconUrl,
            title: data.commentWriter.medal.name
        )
        medalView.setBackgroundColor(isMine ? Colors.systemWhite.color : nil)
        likeButton.bind(count: data.stickers.first?.count ?? 0, reactedByMe: data.stickers.first?.reactedByMe ?? false)
    }

    private func showDeleteAlert() {
        guard let containerVC else { return }

        let okAction = UIAlertAction(
            title: "삭제",
            style: .default
        ) { [weak self] _ in
            self?.viewModel?.input.deleteAction.send()
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        AlertUtils.show(
            viewController: containerVC,
            title: "삭제하시겠습니까?",
            message: "",
            [okAction, cancelAction]
        )
    }
}

private final class BadgeView: BaseView {

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 4
        containerView.backgroundColor = Colors.gray10.color
        return containerView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.medium.font(size: 10)
        titleLabel.textColor = Colors.gray80.color
        return titleLabel
    }()

    private let suffixLabel: UILabel = {
        let suffixLabel = UILabel()
        suffixLabel.font = Fonts.medium.font(size: 10)
        suffixLabel.textColor = Colors.gray60.color
        return suffixLabel
    }()

    init(text: String) {
        super.init(frame: .zero)

        titleLabel.text = text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        addSubViews([containerView])
        containerView.addSubViews([stackView])

        backgroundColor = .clear
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.top.bottom.equalToSuperview().inset(3)
        }

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(suffixLabel)
    }

    func bind(text: String, suffix: String? = nil) {
        titleLabel.text = text
        suffixLabel.text = suffix
        suffixLabel.isHidden = suffix == nil
    }

    func setBackgroundColor(_ color: UIColor) {
        containerView.backgroundColor = color
    }
}

extension PollDetailCommentCell {
    final class LikeButton: UIButton {
        private let selectedImage = Icons.heartFill.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.mainRed.color)
        private let normalImage = Icons.heartLine.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray60.color)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func bind(count: Int, reactedByMe: Bool) {
            let state: UIControl.State = reactedByMe ? .selected : .normal
            setTitle("좋아요 \(count)", for: state)
            isSelected = reactedByMe
        }
        
        private func setup() {
            setTitle("좋아요", for: .normal)
            setTitleColor(Colors.gray60.color, for: .normal)
            setTitleColor(Colors.mainRed.color, for: .selected)
            titleLabel?.font = Fonts.medium.font(size: 10)
            setImage(selectedImage, for: .selected)
            setImage(normalImage, for: .normal)
            semanticContentAttribute = .forceLeftToRight
        }
    }
}
