import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common

final class MedalInfoView: BaseView {
    private let titleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 16)
        $0.textColor = .white
        $0.text = "칭호 살펴보기"
    }
    
    let closeButton = UIButton().then {
        $0.setImage(Icons.close.image.withTintColor(Colors.systemWhite.color), for: .normal)
    }
    
    let tableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(
            MedalInfoTableViewCell.self,
            forCellReuseIdentifier: MedalInfoTableViewCell.registerId
        )
        $0.rowHeight = UITableView.automaticDimension
    }
    
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
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(14)
            make.width.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.closeButton)
        }
        
        self.tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(32)
            make.bottom.equalToSuperview()
        }
    }
}
