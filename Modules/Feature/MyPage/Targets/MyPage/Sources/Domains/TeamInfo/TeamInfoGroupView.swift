import UIKit

import Common
import DesignSystem
import Model

final class TeamInfoGroupView: BaseView {
    enum Layout {
        static let spacing: CGFloat = 8
    }

    let adButton = TeamInfoAdButton()

    private let leadingStackView = TeamInfoGroupView.makeColumnStackView()

    private let trailingStackView = TeamInfoGroupView.makeColumnStackView()

    override func setup() {
        addSubViews([
            leadingStackView,
            trailingStackView
        ])
        leadingStackView.addArrangedSubview(adButton)
    }

    override func bindConstraints() {
        leadingStackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.width.equalTo(TeamMemberView.Layout.width)
            $0.bottom.lessThanOrEqualToSuperview()
        }

        trailingStackView.snp.makeConstraints {
            $0.leading.equalTo(leadingStackView.snp.trailing).offset(Layout.spacing)
            $0.trailing.top.equalToSuperview()
            $0.width.equalTo(TeamMemberView.Layout.width)
            $0.bottom.lessThanOrEqualToSuperview()
        }

        adButton.snp.makeConstraints {
            $0.size.equalTo(TeamInfoAdButton.Layout.size)
        }
    }

    func bind(creatorGroups: [CreatorGroupResponse]) {
        [leadingStackView, trailingStackView].forEach { stackView in
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }

        var leadingRowCount = 0
        var trailingRowCount = 0
        for group in creatorGroups {
            let memberView = TeamMemberView(teamName: group.role, members: group.creatorNames)
            let rowCount = (group.creatorNames.count + 1) / TeamMemberView.Layout.membersPerRow + 1

            if leadingRowCount <= trailingRowCount {
                leadingStackView.addArrangedSubview(memberView)
                leadingRowCount += rowCount
            } else {
                trailingStackView.addArrangedSubview(memberView)
                trailingRowCount += rowCount
            }
        }

        let adStackView = leadingRowCount <= trailingRowCount ? leadingStackView : trailingStackView
        adStackView.addArrangedSubview(adButton)
    }

    private static func makeColumnStackView() -> UIStackView {
        let stackView = UIStackView()

        stackView.axis = .vertical
        stackView.spacing = Layout.spacing
        stackView.alignment = .fill
        return stackView
    }
}
