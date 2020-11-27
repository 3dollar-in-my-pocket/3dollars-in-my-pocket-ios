import RxSwift
import MessageUI

class QuestionVC: BaseVC {
  
  private lazy var questionView = QuestionView(frame: self.view.frame)
  
  static func instance() -> QuestionVC {
    return QuestionVC(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = questionView
    self.initilizeTableView()
  }
  
  override func bindViewModel() {
    
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
  
  private func showMailComposer() {
    guard MFMailComposeViewController.canSendMail() else {
      return
    }
    
    let composer = MFMailComposeViewController()
    composer.mailComposeDelegate = self
    composer.setToRecipients(["3dollarinmypocket@gmail.com"])
    composer.setSubject("가슴속 3천원 문의")
    
    self.present(composer, animated: true, completion: nil)
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
      
    } else {
      self.showMailComposer()
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
