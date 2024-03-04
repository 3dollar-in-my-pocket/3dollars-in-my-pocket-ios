import UIKit

import Common
import DesignSystem

final class TeamMemberView: BaseView {
    enum Layout {
        static let size = CGSize(width: 136, height: 66)
    }
    
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
    
    init(teamName: String, member1: String, member2: String) {
        super.init(frame: .zero)
        
        bind(teamName: teamName, member1: member1, member2: member2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        addSubViews([
            containerView,
            titleLabel,
            firstMemberLabel,
            secondMemberLabel
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
        
        firstMemberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        secondMemberLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(firstMemberLabel)
        }
    }
    
    func bind(teamName: String, member1: String, member2: String) {
        titleLabel.text = teamName
        firstMemberLabel.text = member1
        secondMemberLabel.text = member2
    }
}

