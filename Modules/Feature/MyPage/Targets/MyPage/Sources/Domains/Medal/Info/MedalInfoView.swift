import UIKit

import SnapKit

import Model
import DesignSystem
import Common

final class MedalInfoView: BaseView {
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.medium.font(size: 16)
        titleLabel.textColor = .white
        titleLabel.text = "칭호 살펴보기"
        return titleLabel
    }()
    
    let closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.setImage(Icons.close.image.withTintColor(Colors.systemWhite.color), for: .normal)
        return closeButton
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register([MedalInfoTableViewCell.self])
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    override func setup() {
        self.backgroundColor = .black.withAlphaComponent(0.9)
        self.addSubViews([
            self.titleLabel,
            self.closeButton,
            self.tableView
        ])
    }
    
    override func bindConstraints() {
        self.closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(14)
            make.width.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.closeButton)
        }
        
        self.tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(32)
            make.bottom.equalToSuperview()
        }
    }
}
