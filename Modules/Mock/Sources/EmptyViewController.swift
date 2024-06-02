import UIKit

final class EmptyViewController: UIViewController {
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "빈 화면입니다🤣"
        label.textColor = .black
        label.font = .systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(emptyLabel)
        emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if navigationController?.isNavigationBarHidden == false {
            navigationController?.isNavigationBarHidden = true
        }
    }
}
