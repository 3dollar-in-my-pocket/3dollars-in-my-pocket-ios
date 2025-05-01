import UIKit

import Common
import Store

final class StoreDetailConfigurationViewController: UIViewController {
    private let idField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "가게 id를 입력해주세요."
        
        return textField
    }()
    
    private let storeViewType: StoreViewType
    
    init(storeViewType: StoreViewType) {
        self.storeViewType = storeViewType
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
        guard let storeId = idField.text else { return }
        
        switch storeViewType {
        case .storeDetail:
            pushStoreDetail(id: storeId)
            
        case .bossStoreDetail:
            pushBossStoreDetail(id: storeId)
        }
    }
    
    private func pushStoreDetail(id: String) {
        guard let storeId = Int(id) else { return }
        let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushBossStoreDetail(id: String) {
        let viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: id, shouldPushReviewList: false)
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}
