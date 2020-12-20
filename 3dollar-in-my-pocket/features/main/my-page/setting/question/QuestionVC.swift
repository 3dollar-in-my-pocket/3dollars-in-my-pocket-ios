import RxSwift
import MessageUI
import DeviceKit

class QuestionVC: BaseVC {
  
  private lazy var questionView = QuestionView(frame: self.view.frame)
  private let viewModel = QestionViewModel(
    userService: UserService(),
    userDefaults: UserDefaultsUtil()
  )
  
  static func instance() -> QuestionVC {
    return QuestionVC(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = questionView
    self.initilizeTableView()
    self.viewModel.fetchMyInfo()
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.showMailComposer
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showMailComposer)
      .disposed(by: disposeBag)
    
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.questionView.showLoading(isShow:))
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
    self.questionView.backButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
  }
  
  private func initilizeTableView() {
    self.questionView.tableView.register(
      QuestionCell.self,
      forCellReuseIdentifier: QuestionCell.registerId
    )
    self.questionView.tableView.dataSource = self
    self.questionView.tableView.delegate = self
  }
  
  private func popVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func showMailComposer(
    iosVersion: String,
    nickname: String,
    appVersion: String,
    deviceModel: Device
  ) {
    guard MFMailComposeViewController.canSendMail() else {
      return
    }
    
    let composer = MFMailComposeViewController().then {
        $0.mailComposeDelegate = self
        $0.setToRecipients(["3dollarinmypocket@gmail.com"])
        $0.setSubject("가슴속 3천원 문의")
        $0.setMessageBody("\n\n\n\nOS: ios \(iosVersion)\n닉네임: \(nickname)\n앱 버전: \(appVersion)\n디바이스: \(deviceModel)", isHTML: false)
    }
    
    self.present(composer, animated: true, completion: nil)
  }
  
  private func goToFAQ() {
    let faqVC = FAQVC.instance()
    
    self.navigationController?.pushViewController(faqVC, animated: true)
  }
}

extension QuestionVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: QuestionCell.registerId,
      for: indexPath
    ) as? QuestionCell else {
      return BaseTableViewCell()
    }
    
    if indexPath.row == 0{
      cell.bind(title: "question_faq".localized)
    } else {
      cell.bind(title: "question_email".localized)
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      self.goToFAQ()
    } else {
      self.viewModel.input.tapMail.onNext(())
    }
  }
}

extension QuestionVC: MFMailComposeViewControllerDelegate {
  func mailComposeController(
    _ controller: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult,
    error: Error?
  ) {
    controller.dismiss(animated: true, completion: nil)
  }
}
