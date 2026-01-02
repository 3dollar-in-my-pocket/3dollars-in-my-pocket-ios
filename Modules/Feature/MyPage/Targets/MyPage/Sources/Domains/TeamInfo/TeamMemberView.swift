import UIKit

import Common
import DesignSystem

final class TeamMemberView: BaseView {
    enum Layout {
        static let size = CGSize(width: 136, height: 66)
        static let largeSize = CGSize(width: 136, height: 86)
    }

    private let memberCount: Int

    private let containerView: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 12
        view.backgroundColor = Colors.pink500.color
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.textColor = Colors.pink200.color
        label.font = Fonts.medium.font(size: 10)
        return label
    }()

    private let firstMemberLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.systemWhite.color
        return label
    }()

    private let secondMemberLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.systemWhite.color
        return label
    }()

    private let thirdMemberLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.systemWhite.color
        return label
    }()

    private let fourthMemberLabel: UILabel = {
        let label = UILabel()

        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.systemWhite.color
        return label
    }()

    init(teamName: String, members: [String]) {
        self.memberCount = members.count
        super.init(frame: .zero)

        bind(teamName: teamName, members: members)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        addSubViews([
            containerView,
            titleLabel,
            firstMemberLabel,
            secondMemberLabel,
            thirdMemberLabel,
            fourthMemberLabel
        ])
    }

    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
        }

        switch memberCount {
        case 1:
            setupSingleMemberLayout()
        case 4:
            setupFourMembersLayout()
        default:
            setupTwoMembersLayout()
        }
    }

    private func setupSingleMemberLayout() {
        firstMemberLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }

        secondMemberLabel.isHidden = true
        thirdMemberLabel.isHidden = true
        fourthMemberLabel.isHidden = true
    }

    private func setupTwoMembersLayout() {
        firstMemberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }

        secondMemberLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(firstMemberLabel)
        }

        thirdMemberLabel.isHidden = true
        fourthMemberLabel.isHidden = true
    }

    private func setupFourMembersLayout() {
        firstMemberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }

        secondMemberLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(firstMemberLabel)
        }

        thirdMemberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(firstMemberLabel.snp.bottom).offset(4)
        }

        fourthMemberLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(thirdMemberLabel)
        }
    }

    private func bind(teamName: String, members: [String]) {
        titleLabel.text = teamName

        if members.count >= 1 {
            firstMemberLabel.text = members[0]
        }
        if members.count >= 2 {
            secondMemberLabel.text = members[1]
        }
        if members.count >= 3 {
            thirdMemberLabel.text = members[2]
        }
        if members.count >= 4 {
            fourthMemberLabel.text = members[3]
        }
    }
}
