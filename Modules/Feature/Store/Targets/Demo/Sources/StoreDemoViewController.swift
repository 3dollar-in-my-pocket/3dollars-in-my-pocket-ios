import UIKit

import Common
import SnapKit

final class StoreDemoViewController: UIViewController {
    private let tableView = UITableView(frame: .zero)
    private let datasource: [StoreViewType] = [
        .storeDetail,
        .bossStoreDetail
    ]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        title = "Store 모듈"
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func bindConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func pushStoreDetailConfiguration(storeViewType: StoreViewType) {
        let viewController = StoreDetailConfigurationViewController(storeViewType: storeViewType)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension StoreDemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectionStyle = .none
        cell.textLabel?.text = datasource[indexPath.item].title
        return cell
    }
}

extension StoreDemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch datasource[indexPath.item] {
        case .storeDetail:
            pushStoreDetailConfiguration(storeViewType: .storeDetail)
            
        case .bossStoreDetail:
            pushStoreDetailConfiguration(storeViewType: .bossStoreDetail)
        }
    }
}
