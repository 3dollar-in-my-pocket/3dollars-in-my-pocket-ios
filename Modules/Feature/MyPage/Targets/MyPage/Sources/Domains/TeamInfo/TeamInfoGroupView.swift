import UIKit

import Common
import DesignSystem

final class TeamInfoGroupView: BaseView {
    enum Layout {
        static let size = CGSize(width: 280, height: 308)
    }

    private let iOSMemberView = TeamMemberView(
        teamName: "iOS",
        members: ["유현식", "김하경"]
    )

    private let backendMemberView = TeamMemberView(
        teamName: "Backend",
        members: ["강승호", "고예림"]
    )

    private let androidMemberView = TeamMemberView(
        teamName: "Android",
        members: ["정진용", "전두영"]
    )

    private let plannerMemberView = TeamMemberView(
        teamName: "기획자",
        members: ["이한나"]
    )

    private let marketerMemberView = TeamMemberView(
        teamName: "Marketer",
        members: ["공서연", "정아린"]
    )

    private let designMemberView = TeamMemberView(
        teamName: "Design",
        members: ["이윤이", "박은지", "양민설", "조혜원"]
    )

    let adButton = TeamInfoAdButton()

    override func setup() {
        addSubViews([
            iOSMemberView,
            backendMemberView,
            androidMemberView,
            plannerMemberView,
            marketerMemberView,
            designMemberView,
            adButton
        ])
    }

    override func bindConstraints() {
        iOSMemberView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.size.equalTo(TeamMemberView.Layout.size)
        }

        backendMemberView.snp.makeConstraints {
            $0.leading.equalTo(iOSMemberView.snp.trailing).offset(8)
            $0.top.equalToSuperview()
            $0.size.equalTo(TeamMemberView.Layout.size)
        }

        androidMemberView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(iOSMemberView.snp.bottom).offset(8)
            $0.size.equalTo(TeamMemberView.Layout.size)
        }

        plannerMemberView.snp.makeConstraints {
            $0.trailing.equalTo(backendMemberView)
            $0.top.equalTo(iOSMemberView.snp.bottom).offset(8)
            $0.size.equalTo(TeamMemberView.Layout.size)
        }

        marketerMemberView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(androidMemberView.snp.bottom).offset(8)
            $0.size.equalTo(TeamMemberView.Layout.size)
        }

        designMemberView.snp.makeConstraints {
            $0.trailing.equalTo(backendMemberView)
            $0.top.equalTo(androidMemberView.snp.bottom).offset(8)
            $0.size.equalTo(TeamMemberView.Layout.largeSize)
        }

        adButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(marketerMemberView.snp.bottom).offset(8)
            $0.size.equalTo(TeamInfoAdButton.Layout.size)
        }

        snp.makeConstraints {
            $0.top.equalTo(iOSMemberView).priority(.high)
            $0.leading.equalTo(iOSMemberView).priority(.high)
            $0.bottom.equalTo(adButton).priority(.high)
            $0.trailing.equalTo(backendMemberView).priority(.high)
        }
    }
}
