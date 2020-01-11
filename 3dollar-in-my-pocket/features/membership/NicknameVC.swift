import UIKit

class NicknameVC: BaseVC {
    
    private lazy var nicknameView = NicknameView(frame: self.view.frame)
    var id: String
    var social: String
    
    
    init(id: String, social: String) {
        self.id = id
        self.social = social
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    static func instance(id: String, social: String) -> NicknameVC {
        return NicknameVC.init(id: id, social: social)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = nicknameView
        nicknameView.nicknameField.delegate = self
    }
    
    override func bindViewModel() {
        nicknameView.backBtn.rx.tap.bind {
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        nicknameView.nicknameField.rx.text.bind { (text) in
            guard let text = text else {return}
            
            self.nicknameView.setBtnEnable(isEnable: !text.isEmpty)
        }.disposed(by: disposeBag)
        
        nicknameView.tapGestureView.rx.event.bind { (recognizer) in
            self.nicknameView.nicknameField.resignFirstResponder()
        }.disposed(by: disposeBag)
        
        nicknameView.startBtn1.rx.tap.bind {
            self.signIn()
        }.disposed(by: disposeBag)
        
        nicknameView.startBtn2.rx.tap.bind {
            self.signIn()
        }.disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func goToMain() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToMain()
        }
    }
    
    private func signIn() {
        let nickname = nicknameView.nicknameField.text!
        let user = User.init(nickname: nickname, socialId: self.id, socialType: self.social)
        
        UserService.signIn(user: user) { [weak self] (response) in
            switch response.result {
            case .success(let signIn):
                UserDefaultsUtil.setUserToken(token: signIn.token)
                UserDefaultsUtil.setUserId(id: signIn.id)
                self?.goToMain()
            case.failure(let error):
                AlertUtils.show(title: "error", message: error.localizedDescription)
            }
        }
    }
}

extension NicknameVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        return count <= 8
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
}
