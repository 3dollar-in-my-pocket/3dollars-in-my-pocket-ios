import UIKit

import Common

final class AccountInfoViewController: BaseViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        setupNavigationBar()
        
        view.backgroundColor = Colors.gray100.color
    }
    
    private func setupNavigationBar() {
        addNavigationBar()
        navigationItem.title = "회원 정보"
        navigationBar?.tintColor = Colors.systemWhite.color
    }
}
