import UIKit

import Common
import DesignSystem
import Then
import Model

final class PollDetailCommentCell: BaseCollectionViewCell {

    enum Layout {
        static func height(content: String) -> CGFloat {
            return content.height(font: Fonts.regular.font(size: 14), width: UIScreen.main.bounds.width - 40) + 90
        }
    }

    weak var containerVC: UIViewController?

    private let userNameLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray80.color
    }
 
    private let badgeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }

    private let medalView = CommunityUserMedalView()

    private let writerBadge = BadgeView(text: "작성자")

    private let pollOptionBadge = BadgeView(text: "")

    private let contentLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = Colors.gray80.color
        $0.numberOfLines = 0
    }

    private let dateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }

    private let dateSideDotView = UIView().then {
        $0.backgroundColor = Colors.gray40.color
    }

    private let dateLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray40.color
    }

    private let reportOrUpdateButton = UIButton().then {
        $0.titleLabel?.font = Fonts.bold.font(size: 12)
        $0.setTitleColor(Colors.gray60.color, for: .normal)
        $0.contentEdgeInsets = .zero
    }

    private let lineView = UIView().then {
        $0.backgroundColor = Colors.gray10.color
    }

    private var viewModel: PollDetailCommentCellViewModel?

    override func setup() {
        super.setup()

        contentView.addSubViews([
            userNameLabel,
            dateStackView,
            badgeStackView,
            contentLabel,
            lineView
        ])

        badgeStackView.addArrangedSubview(medalView)
        badgeStackView.addArrangedSubview(pollOptionBadge)
        badgeStackView.addArrangedSubview(writerBadge)

        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(dateSideDotView)
        dateStackView.addArrangedSubview(reportOrUpdateButton)

        dateStackView.setCustomSpacing(2, after: dateSideDotView)
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
    }

    private func bindUI(with data: PollCommentWithUserApiResponse, isMine: Bool) {
        userNameLabel.text = data.commentWriter.name

        dateLabel.text = data.comment.updatedAt.toDate()?.toRelativeString() ?? data.comment.updatedAt

        reportOrUpdateButton.setTitle(isMine ? "삭제" : "신고", for: .normal)

        contentLabel.text = data.comment.content

        backgroundColor = isMine ? Colors.pink100.color : .clear

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

private extension Date {
    func toRelativeString() -> String {
        let currentDate = Date()
        let components = Calendar.current.dateComponents([.minute, .day], from: self, to: currentDate)

        if let minutesDifference = components.minute, minutesDifference < 1 {
            return "방금"
        }

        if let dayDifference = components.day, dayDifference > 1 {
            return self.toString()
        }

        let timeAgoFormatter = RelativeDateTimeFormatter()
        timeAgoFormatter.dateTimeStyle = .named
        timeAgoFormatter.unitsStyle = .short
        timeAgoFormatter.locale = Locale.current
        let dateToString = timeAgoFormatter.localizedString(for: self, relativeTo: currentDate)
        return dateToString
    }
}

private final class BadgeView: BaseView {

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 4
        $0.backgroundColor = Colors.gray10.color
    }

    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 10)
        $0.textColor = Colors.gray80.color
    }

    private let suffixLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 10)
        $0.textColor = Colors.gray60.color
    }

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
