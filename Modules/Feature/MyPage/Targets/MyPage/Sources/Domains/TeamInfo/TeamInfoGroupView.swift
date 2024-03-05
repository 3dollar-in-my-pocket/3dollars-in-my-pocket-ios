import UIKit

import Common
import DesignSystem

final class TeamInfoGroupView: BaseView {
    enum Layout {
        static let size = CGSize(width: 280, height: 214)
    }
    
    private let designMemberView = TeamMemberView(
        teamName: "Design",
        member1: "이윤이",
        member2: "박은지"
    )
    
    private let iOSMemberView = TeamMemberView(
        teamName: "iOS",
        member1: "유현식",
        member2: "김하경"
    )
    
    private let androidMemberView = TeamMemberView(
        teamName: "Android",
        member1: "김민호",
        member2: "정진용"
    )
    
    private let backendMemberView = TeamMemberView(
        teamName: "Backend",
        member1: "강승호",
        member2: "고예림"
    )
    
    private let marketingMemberView = TeamMemberView(
        teamName: "Marketing",
        member1: "윤다영",
        member2: "이한나"
    )
    
    let adButton = TeamInfoAdButton()
    
    override func setup() {
        addSubViews([
            designMemberView,
            iOSMemberView,
            androidMemberView,
            backendMemberView,
            marketingMemberView,
            adButton
        ])
    }
    
    override func bindConstraints() {
        designMemberView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.size.equalTo(TeamMemberView.Layout.size)
        }
        
        iOSMemberView.snp.makeConstraints {
            $0.leading.equalTo(designMemberView.snp.trailing).offset(8)
            $0.top.equalToSuperview()
            $0.size.equalTo(TeamMemberView.Layout.size)
        }
        
        androidMemberView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(designMemberView.snp.bottom).offset(8)
            $0.size.equalTo(TeamMemberView.Layout.size)
        }
        
        backendMemberView.snp.makeConstraints {
            $0.trailing.equalTo(iOSMemberView)
            $0.top.equalTo(designMemberView.snp.bottom).offset(8)
            $0.size.equalTo(TeamMemberView.Layout.size)
        }
        
        marketingMemberView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(androidMemberView.snp.bottom).offset(8)
            $0.size.equalTo(TeamMemberView.Layout.size)
        }
        
        adButton.snp.makeConstraints {
            $0.trailing.equalTo(backendMemberView)
            $0.top.equalTo(backendMemberView.snp.bottom).offset(8)
            $0.size.equalTo(TeamInfoAdButton.Layout.size)
        }
        
        snp.makeConstraints {
            $0.top.equalTo(designMemberView).priority(.high)
            $0.leading.equalTo(designMemberView).priority(.high)
            $0.bottom.equalTo(marketingMemberView).priority(.high)
            $0.trailing.equalTo(iOSMemberView).priority(.high)
        }
    }
}
