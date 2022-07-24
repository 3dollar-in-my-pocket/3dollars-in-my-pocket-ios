import UIKit

import Base

final class VisitHistoryTableViewCell: BaseTableViewCell {
    static let registerId = "\(VisitHistoryTableViewCell.self)"
    
    private let pointView = UIView().then {
        $0.layer.cornerRadius = 2
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .semiBold(size: 12)
        $0.textColor = R.color.gray40()
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .light(size: 12)
        $0.textColor = R.color.gray40()
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = .black
    }
    
    override func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.addSubViews([
            self.pointView,
            self.dateLabel,
            self.timeLabel,
            self.nameLabel
        ])
    }
    
    override func bindConstraints() {
        self.pointView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalTo(self.nameLabel)
            make.width.height.equalTo(4)
        }
        
        self.dateLabel.snp.makeConstraints { make in
            make.left.equalTo(self.pointView.snp.right).offset(8)
            make.centerY.equalTo(self.nameLabel)
        }
        
        self.timeLabel.snp.makeConstraints { make in
            make.left.equalTo(self.dateLabel.snp.right).offset(2)
            make.centerY.equalTo(self.nameLabel)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(self.timeLabel.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func bind(visitHistory: VisitHistory) {
        switch visitHistory.type {
        case .exists:
            self.pointView.backgroundColor = UIColor(r: 0, g: 198, b: 103)
            
        case .notExists:
            self.pointView.backgroundColor = R.color.red()
        }
        
        self.dateLabel.text = DateUtils.toString(
            dateString: visitHistory.createdAt,
            format: "MM월 dd일"
        )
        self.timeLabel.text = DateUtils.toString(
            dateString: visitHistory.createdAt,
            format: "HH:mm:ss"
        )
        self.nameLabel.text = visitHistory.user.name
    }
}
