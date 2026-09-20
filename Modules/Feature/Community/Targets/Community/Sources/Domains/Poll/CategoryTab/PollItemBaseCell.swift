import UIKit

import Common
import DesignSystem
import Model

class PollItemBaseCell: BaseCollectionViewCell {

    let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.backgroundColor = Colors.systemWhite.color
        return containerView
    }()

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.semiBold.font(size: 20)
        titleLabel.textColor = Colors.gray90.color
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    let userInfoStackView: UIStackView = {
        let userInfoStackView = UIStackView()
        userInfoStackView.axis = .horizontal
        userInfoStackView.spacing = 4
        return userInfoStackView
    }()

    let userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.font = Fonts.medium.font(size: 12)
        userNameLabel.textColor = Colors.gray80.color
        return userNameLabel
    }()

    let medalView = CommunityUserMedalView()

    let selectionStackView: UIStackView = {
        let selectionStackView = UIStackView()
        selectionStackView.axis = .vertical
        selectionStackView.spacing = 8
        return selectionStackView
    }()

    let firstSelectionView = CommunityPollSelectionView()

    let secondSelectionView = CommunityPollSelectionView()

    let commentButton: UIButton = {
        let commentButton = UIButton()
        commentButton.titleLabel?.font = Fonts.medium.font(size: 12)
        commentButton.setTitleColor(Colors.gray50.color, for: .normal)
        commentButton.setImage(Icons.communityLine.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray50.color), for: .normal)
        commentButton.contentEdgeInsets.right = 2
        commentButton.imageEdgeInsets.left = -2
        commentButton.titleEdgeInsets.right = -2
        commentButton.isUserInteractionEnabled = false
        return commentButton
    }()

    let countButton: UIButton = {
        let countButton = UIButton()
        countButton.titleLabel?.font = Fonts.medium.font(size: 12)
        countButton.setTitleColor(Colors.gray50.color, for: .normal)
        countButton.setImage(Icons.fireLine.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray50.color), for: .normal)
        countButton.contentEdgeInsets.right = 2
        countButton.imageEdgeInsets.left = -2
        countButton.titleEdgeInsets.right = -2
        countButton.isUserInteractionEnabled = false
        return countButton
    }()

     let deadlineLabel: UILabel = {
         let deadlineLabel = UILabel()
        deadlineLabel.font = Fonts.medium.font(size: 12)
        deadlineLabel.textColor = Colors.gray50.color
         return deadlineLabel
     }()

    private var viewModel: PollItemCellViewModel?

    func bind(viewModel: PollItemCellViewModel) {
        self.viewModel = viewModel

        // Input
        firstSelectionView
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .filter { owner, _ in
                !owner.firstSelectionView.isSelected
            }
            .mapVoid
            .subscribe(viewModel.input.didSelectFirstOption)
            .store(in: &cancellables)

        secondSelectionView
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .filter { owner, _ in
                !owner.secondSelectionView.isSelected
            }
            .mapVoid
            .subscribe(viewModel.input.didSelectSecondOption)
            .store(in: &cancellables)

        // Output
        viewModel.output.item
            .main
            .withUnretained(self)
            .sink { owner, item in
                owner.bindUI(with: item)
            }
            .store(in: &cancellables)

        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)
    }

    private func bindUI(with item: PollWithMetaApiResponse) {
        titleLabel.text = item.poll.content.title
        userNameLabel.text = item.pollWriter.name
        medalView.bind(imageUrl: item.pollWriter.medal.iconUrl, title: item.pollWriter.medal.name)
        commentButton.setTitle("\(item.meta.totalCommentsCount)", for: .normal)
        countButton.setTitle("\(item.meta.totalParticipantsCount)명 투표", for: .normal)

        let firstOption = item.poll.options[safe: 0]
        let secondOption = item.poll.options[safe: 1]

        if firstOption?.choice.selectedByMe ?? false || secondOption?.choice.selectedByMe ?? false { // 선택
            updateState(firstOption: firstOption, secondOption: secondOption)
        } else {
            firstSelectionView.updateSelection(false)
            secondSelectionView.updateSelection(false)
            firstSelectionView.updateNotSelectedState()
            secondSelectionView.updateNotSelectedState()
        }

        firstSelectionView.titleLabel.text = firstOption?.name
        firstSelectionView.percentLabel.text = "\(Int((firstOption?.choice.ratio ?? 0) * 100))%"
        firstSelectionView.countLabel.text = "\(firstOption?.choice.count ?? 0)명"

        secondSelectionView.titleLabel.text = secondOption?.name
        secondSelectionView.percentLabel.text = "\(Int((secondOption?.choice.ratio ?? 0) * 100))%"
        secondSelectionView.countLabel.text = "\(secondOption?.choice.count ?? 0)명"

        updateDeadline(with: item)
    }

    private func updateDeadline(with item: PollWithMetaApiResponse) {
        let dateFormatter = DateFormatter()
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        if let endDate = item.poll.period.endDateTime.toDate()?.toString(format: dateFormat),
           let targetDate: Date = dateFormatter.date(from: endDate),
           let fromDate: Date = dateFormatter.date(from: Date().toString(format: dateFormat)) {
            switch targetDate.compare(fromDate) {
            case .orderedSame:
                deadlineLabel.text = "오늘 마감"
            case .orderedDescending:
                deadlineLabel.text = item.poll.period.endDateTime.toDate()?.toString(format: "yyyy-MM-dd")
            case .orderedAscending:
                deadlineLabel.text = "마감"
                updateState(firstOption: item.poll.options[safe: 0], secondOption: item.poll.options[safe: 1])
                firstSelectionView.isUserInteractionEnabled = false
                secondSelectionView.isUserInteractionEnabled = false
            }
        }
    }

    private func updateState(firstOption: PollOptionWithChoiceApiResponse?, secondOption: PollOptionWithChoiceApiResponse?) {
        if firstOption?.choice.count ?? 0 > secondOption?.choice.count ?? 0 {
            firstSelectionView.updateWinnerState()
            secondSelectionView.updateLoserState()
        } else if firstOption?.choice.count ?? 0 < secondOption?.choice.count ?? 0 {
            firstSelectionView.updateLoserState()
            secondSelectionView.updateWinnerState()
        } else {
            firstSelectionView.updateDrawState()
            secondSelectionView.updateDrawState()
        }
        firstSelectionView.updateSelection(firstOption?.choice.selectedByMe ?? false)
        secondSelectionView.updateSelection(secondOption?.choice.selectedByMe ?? false)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        firstSelectionView.isUserInteractionEnabled = true
        secondSelectionView.isUserInteractionEnabled = true
        medalView.bind(imageUrl: nil, title: nil)
    }
}

// MARK: - CommunityPollSelectionView

final class CommunityPollSelectionView: UIControl {

    enum Layout {
        static let height: CGFloat = 44
    }

    let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 12
        containerView.layer.borderColor = Colors.gray30.color.cgColor
        containerView.layer.borderWidth = 1
        containerView.isUserInteractionEnabled = false
        return containerView
    }()

    private let titleStackView: UIStackView = {
        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.spacing = 4
        return titleStackView
    }()

    let checkImageView: UIImageView = {
        let checkImageView = UIImageView()
        checkImageView.image = Icons.check.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.mainRed.color)
        checkImageView.isHidden = true
        return checkImageView
    }()

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.medium.font(size: 16)
        titleLabel.textColor = Colors.gray100.color
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    let emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.font = Fonts.bold.font(size: 16)
        emojiLabel.textColor = Colors.gray100.color
        return emojiLabel
    }()

    let percentLabel: UILabel = {
        let percentLabel = UILabel()
        percentLabel.font = Fonts.bold.font(size: 16)
        percentLabel.textColor = Colors.gray60.color
        return percentLabel
    }()

    let countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.font = Fonts.medium.font(size: 10)
        countLabel.textColor = Colors.gray40.color
        return countLabel
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }()

    init() {
        super.init(frame: .zero)

        setup()
        bindConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubViews([
            containerView
        ])

        containerView.addSubViews([
            titleStackView,
            stackView
        ])

        titleStackView.addArrangedSubview(checkImageView)
        titleStackView.addArrangedSubview(titleLabel)

        stackView.addArrangedSubview(emojiLabel)
        stackView.addArrangedSubview(percentLabel)
        stackView.addArrangedSubview(countLabel)
    }

    private func bindConstraints() {
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(stackView.snp.leading).offset(-16).priority(.high)
            $0.trailing.equalToSuperview().inset(16).priority(.medium)
        }

        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }

        checkImageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }

        checkImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        emojiLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        percentLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        stackView.arrangedSubviews.forEach {
            $0.isHidden = true
        }
    }

    func updateNotSelectedState() {
        containerView.layer.borderColor = Colors.gray30.color.cgColor
        containerView.backgroundColor = Colors.systemWhite.color

        titleLabel.textAlignment = .center
        titleLabel.font = Fonts.medium.font(size: 16)
        titleLabel.textColor = Colors.gray100.color

        stackView.arrangedSubviews.forEach {
            $0.isHidden = true
        }

        checkImageView.isHidden = true
    }

    func updateDrawState() {
        containerView.backgroundColor = Colors.gray100.color

        titleLabel.textAlignment = .left
        titleLabel.font = Fonts.bold.font(size: 12)
        titleLabel.textColor = Colors.systemWhite.color

        stackView.arrangedSubviews.forEach {
            $0.isHidden = false
        }

        percentLabel.textColor = Colors.systemWhite.color
        emojiLabel.text = "😠"

        countLabel.textColor = Colors.gray30.color
    }

    func updateWinnerState() {
        containerView.backgroundColor = Colors.gray100.color

        titleLabel.textAlignment = .left
        titleLabel.font = Fonts.bold.font(size: 12)
        titleLabel.textColor = Colors.systemWhite.color

        stackView.arrangedSubviews.forEach {
            $0.isHidden = false
        }

        percentLabel.textColor = Colors.systemWhite.color
        emojiLabel.text = "🤣"

        countLabel.textColor = Colors.gray30.color
    }

    func updateLoserState() {
        containerView.backgroundColor = Colors.systemWhite.color

        titleLabel.textAlignment = .left
        titleLabel.font = Fonts.bold.font(size: 12)
        titleLabel.textColor = Colors.gray60.color

        stackView.arrangedSubviews.forEach {
            $0.isHidden = false
        }

        percentLabel.textColor = Colors.gray60.color
        emojiLabel.text = "😞"

        countLabel.textColor = Colors.gray40.color
    }

    func updateSelection(_ isSelected: Bool) {
        checkImageView.isHidden = !isSelected
        containerView.layer.borderColor = isSelected ? Colors.mainRed.color.cgColor : Colors.gray30.color.cgColor
        self.isSelected = isSelected
    }
}
