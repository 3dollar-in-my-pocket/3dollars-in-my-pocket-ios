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
    
    self.viewModel.output.goToRename
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToRename(currentName:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToSignIn
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToSignIn)
      .disposed(by: disposeBag)
    
    self.viewModel.output.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
    
    self.viewModel.httpErrorAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showHTTPErrorAlert(error:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.settingView.backButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
    
    self.settingView.nicknameModifyLabelButton.rx.tap
      .bind(to: self.viewModel.input.tapRename)
      .disposed(by: disposeBag)
    
    self.settingView.nicknameModifyButton.rx.tap
      .bind(to: self.viewModel.input.tapRename)
      .disposed(by: disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
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
    self.settingView.tableView.register(
      SettingWithdrawalCell.self,
      forCellReuseIdentifier: SettingWithdrawalCell.registerId
    )
    self.settingView.tableView.delegate = self
    self.settingView.tableView.dataSource = self
  }
  
  private func popVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func showSignOutAlert() {
    AlertUtils.showWithCancel(
      controller: self,
      title: "로그아웃 하시겠습니까?",
      message: nil) {
      self.viewModel.input.signOut.onNext(())
    }
  }
  
  private func showWithdrawalAlert() {
    AlertUtils.showWithCancel(
      controller: self,
      title: "회원탈퇴",
      message: "회원탈퇴 이후에 제보했던 가게와 작성한 댓글을 더이상 볼 수 없어요.\n정말로 탈퇴하시겠어요?"
    ) {
      self.viewModel.input.withdrawal.onNext(())
    }
  }
  
  private func goToRename(currentName: String) {
    let renameVC = RenameVC.instance(currentName: currentName)
    
    self.navigationController?.pushViewController(renameVC, animated: true)
  }
  
  private func goToQuestion() {
    let questionVC = QuestionVC.instance()
    
    self.navigationController?.pushViewController(questionVC, animated: true)
  }
  
  private func goToPrivacy() {
    let privacyVC = PrivacyVC.instance()
    
    self.navigationController?.pushViewController(privacyVC, animated: true)
  }
  
  private func goToSignIn() {
    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
      sceneDelegate.goToSignIn()
    }
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
      return 2
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
          title: "setting_menu_privacy".localized
        )
      }
      return cell
    } else {
      if indexPath.row == 0 {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingAccountCell.registerId,
                for: indexPath
        ) as? SettingAccountCell else { return BaseTableViewCell() }
        
        cell.bind(socialType: self.viewModel.output.user.value.socialType)
        
        return cell
      } else {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingWithdrawalCell.registerId,
                for: indexPath
        ) as? SettingWithdrawalCell else { return BaseTableViewCell() }
        
        return cell
      }
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      if indexPath.row == 0 {
        self.goToQuestion()
      } else {
        self.goToPrivacy()
      }
    } else {
      if indexPath.row == 0 {
        self.showSignOutAlert()
      } else {
        self.showWithdrawalAlert()
      }
    }
  }
}
