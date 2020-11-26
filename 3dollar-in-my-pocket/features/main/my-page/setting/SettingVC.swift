import RxSwift
import UIKit

class SettingVC: BaseVC {
  
  private lazy var settingView = SettingView(frame: self.view.frame)
  private let viewModel = SettingViewModel(
    userDefaults: UserDefaultsUtil(),
    userService: UserService()
  )
  
  static func instance() -> SettingVC {
    return SettingVC(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = settingView
    self.initilizeTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.fetchMyInfo()
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.user
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] user in
        guard let self = self else { return }
        self.settingView.bind(user: user)
        self.settingView.tableView.reloadData()
      })
      .disposed(by: disposeBag)
    
    self.viewModel.output.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
    
  }
  
  override func bindEvent() {
    self.settingView.backButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
  }
  
  private func initilizeTableView() {
    self.settingView.tableView.register(
      SettingMenuCell.self,
      forCellReuseIdentifier: SettingMenuCell.registerId
    )
    self.settingView.tableView.register(
      SettingAccountCell.self,
      forCellReuseIdentifier: SettingAccountCell.registerId
    )
    self.settingView.tableView.delegate = self
    self.settingView.tableView.dataSource = self
  }
  
  private func popVC() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension SettingVC: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 2
    } else {
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      guard let cell = tableView.dequeueReusableCell(
              withIdentifier: SettingMenuCell.registerId,
              for: indexPath
      ) as? SettingMenuCell else { return BaseTableViewCell() }
      
      if indexPath.row == 0 {
        cell.bind(
          image: UIImage(named: "ic_setting_notice")!,
          title: "setting_menu_question".localized
        )
      } else {
        cell.bind(
          image: UIImage(named: "ic_setting_message")!,
          title: "setting_menu_terms".localized
        )
      }
      return cell
    } else {
      guard let cell = tableView.dequeueReusableCell(
              withIdentifier: SettingAccountCell.registerId,
              for: indexPath
      ) as? SettingAccountCell else { return BaseTableViewCell() }
      
      cell.bind(socialType: self.viewModel.output.user.value.socialType)
      
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
