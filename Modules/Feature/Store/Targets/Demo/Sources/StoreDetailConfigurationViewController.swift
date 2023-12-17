import UIKit

import Common
import Store

final class StoreDetailConfigurationViewController: UIViewController {
    private let idField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "가게 id를 입력해주세요."
        
        return textField
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setup() {
        view.backgroundColor = .white
        view.addSubViews([
            idField
        ])
        
        navigationItem.rightBarButtonItem = .init(title: "이동", style: .plain, target: self, action: #selector(didTapMove))
    }
    
    private func bindConstraints() {
        idField.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    @objc private func didTapMove() {
        guard let storeIdString = idField.text,
              let storeId = Int(storeIdString) else { return }
        let viewController = StoreDetailViewController(storeId: storeId)
        
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}
