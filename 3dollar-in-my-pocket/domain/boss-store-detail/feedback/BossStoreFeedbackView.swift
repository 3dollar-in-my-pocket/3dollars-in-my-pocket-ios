import UIKit

import Base
import RxSwift
import RxCocoa

final class BossStoreFeedbackView: Base.BaseView {
    private let navigationContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_black(), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 16)
        $0.textColor = R.color.gray100()
        $0.text = R.string.localization.boss_store_feedback_title()
    }
        
    let feedbackTableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.backgroundColor = .white
        $0.allowsMultipleSelection = true
        $0.rowHeight = BossStoreFeedbackTableViewCell.height
        $0.register(
            BossStoreFeedbackTableViewCell.self,
            forCellReuseIdentifier: BossStoreFeedbackTableViewCell.registerId
        )
        $0.register(
            BossStoreFeedbackHeaderView.self,
            forHeaderFooterViewReuseIdentifier: BossStoreFeedbackHeaderView.registerId
        )
        $0.sectionHeaderHeight = BossStoreFeedbackHeaderView.height
        $0.tableHeaderView = BossStoreFeedbackHeaderView(frame: .init(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: BossStoreFeedbackHeaderView.height
        ))
    }
    
    let sendFeedbackButton = UIButton().then {
        $0.backgroundColor = R.color.green()
        $0.setTitle(R.string.localization.boss_store_feedback_send_feedback(), for: .normal)
        $0.titleLabel?.font = .medium(size: 16)
        $0.setTitleColor(.white, for: .normal)
    }
    
    private let bottomBackgroundView = UIView().then {
        $0.backgroundColor = R.color.green()
    }
    
    override func setup() {
        self.backgroundColor = .white
        self.addSubViews([
            self.navigationContainerView,
            self.backButton,
            self.titleLabel,
            self.feedbackTableView,
            self.sendFeedbackButton,
            self.bottomBackgroundView
        ])
    }
    
    override func bindConstraints() {
        self.navigationContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(59)
        }
        
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalTo(self.navigationContainerView).offset(-21)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.feedbackTableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.sendFeedbackButton.snp.top)
            make.top.equalTo(self.navigationContainerView.snp.bottom)
        }
        
        self.sendFeedbackButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.bottomBackgroundView.snp.top)
            make.height.equalTo(64)
        }
        
        self.bottomBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func setEnableSendFeedbackButton(isEnable: Bool) {
        self.sendFeedbackButton.isEnabled = isEnable
        if isEnable {
            self.sendFeedbackButton.backgroundColor = R.color.green()
            self.bottomBackgroundView.backgroundColor = R.color.green()
        } else {
            self.sendFeedbackButton.backgroundColor = R.color.gray30()
            self.bottomBackgroundView.backgroundColor = R.color.gray30()
        }
    }
}

extension Reactive where Base: BossStoreFeedbackView {
    var isEnableSendFeedbackButton: Binder<Bool> {
        return Binder(self.base) { view, isEnable in
            view.setEnableSendFeedbackButton(isEnable: isEnable)
        }
    }
}
