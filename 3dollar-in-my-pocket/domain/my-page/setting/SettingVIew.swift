import UIKit

import Base
import RxSwift
import RxCocoa

final class SettingView: BaseView {
    private let topBackground = UIView().then {
        $0.backgroundColor = R.color.gray95()
    }
    
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_white(), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = R.string.localization.setting_title()
        $0.textColor = .white
        $0.font = .semiBold(size: 16)
    }
    
    private let nicknameLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = .white
    }
    
    let editNicknameButton = UIButton().then {
        $0.setTitle(R.string.localization.setting_nickname_modify(), for: .normal)
        $0.setTitleColor(UIColor(r: 243, g: 162, b: 169), for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        $0.titleLabel?.font = .medium(size: 14)
        $0.setImage(R.image.ic_pencil(), for: .normal)
    }
    
    private let middleLineView = UIView().then {
        $0.backgroundColor = UIColor(r: 43, g: 43, b: 43)
    }
    
    let tableView = UITableView().then {
        $0.backgroundColor = R.color.gray100()
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.contentInset = UIEdgeInsets(top: 12.5, left: 0, bottom: 0, right: 0)
        $0.register(
            SettingMenuTableViewCell.self,
          forCellReuseIdentifier: SettingMenuTableViewCell.registerId
        )
        $0.register(
            SettingAccountTableViewCell.self,
          forCellReuseIdentifier: SettingAccountTableViewCell.registerId
        )
        $0.register(
            SettingSignoutTableViewCell.self,
          forCellReuseIdentifier: SettingSignoutTableViewCell.registerId
        )
    }
    
    
    override func setup() {
        self.backgroundColor = R.color.gray100()
        self.addSubViews([
            self.topBackground,
            self.backButton,
            self.titleLabel,
            self.nicknameLabel,
            self.editNicknameButton,
            self.middleLineView,
            self.tableView
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(15)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.nicknameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
            make.top.equalTo(self.backButton.snp.bottom).offset(35)
        }
        
        self.editNicknameButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.nicknameLabel)
            make.height.equalTo(16)
        }
        
        self.middleLineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(self.nicknameLabel.snp.bottom).offset(24)
        }
        
        self.topBackground.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(self.middleLineView)
        }
        
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.middleLineView.snp.bottom)
        }
    }
    
    func bind(user: User) {
        self.nicknameLabel.text = user.name
    }
}

extension Reactive where Base: SettingView {
    var user: Binder<User> {
        return Binder(self.base) { view, user in
            view.bind(user: user)
        }
    }
}
