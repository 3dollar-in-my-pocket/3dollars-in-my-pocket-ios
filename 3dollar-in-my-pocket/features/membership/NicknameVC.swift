import UIKit

class NicknameVC: BaseVC {
    
    private lazy var nicknameView = NicknameView(frame: self.view.frame)
    
    
    static func instance() -> NicknameVC {
        return NicknameVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = nicknameView
        nicknameView.nicknameField.delegate = self
    }
    
    override func bindViewModel() {
        nicknameView.nicknameField.rx.text.bind { (text) in
            guard let text = text else {return}
            
            self.nicknameView.setBtnEnable(isEnable: !text.isEmpty)
        }.disposed(by: disposeBag)
        
        nicknameView.tapGestureView.rx.event.bind { (recognizer) in
            self.nicknameView.nicknameField.resignFirstResponder()
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
