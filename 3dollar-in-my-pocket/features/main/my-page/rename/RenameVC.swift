import UIKit

class RenameVC: BaseVC {
    
    private lazy var renameView = RenameView(frame: self.view.frame)
    
    
    static func instance() -> RenameVC {
        return RenameVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = renameView
        renameView.nicknameField.delegate = self
    }
    
    override func bindViewModel() {
        renameView.backBtn.rx.tap.bind {
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        renameView.nicknameField.rx.text.bind { (text) in
            guard let text = text else {return}
            
            self.renameView.setBtnEnable(isEnable: !text.isEmpty)
        }.disposed(by: disposeBag)
        
        renameView.tapGestureView.rx.event.bind { (recognizer) in
            self.renameView.nicknameField.resignFirstResponder()
        }.disposed(by: disposeBag)
        
        renameView.startBtn1.rx.tap.bind {
            
        }.disposed(by: disposeBag)
        
        renameView.startBtn2.rx.tap.bind {
            
        }.disposed(by: disposeBag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension RenameVC: UITextFieldDelegate {
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

