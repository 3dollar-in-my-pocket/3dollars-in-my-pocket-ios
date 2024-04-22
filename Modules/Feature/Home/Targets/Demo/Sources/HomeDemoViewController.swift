import UIKit

import Common
import SnapKit
import Home

final class HomeDemoViewController: BaseViewController {
    enum HomeViewType: CaseIterable {
        case home
        
        var title: String {
            switch self {
            case .home:
                return "홈 화면"
            }
        }
    }
    
    private let homeDemoView = HomeDemoView()
    private let dataSource: [HomeViewType] = HomeViewType.allCases
    
    override func loadView() {
        view = homeDemoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        title = "Home 모듈"
        setupTableView()
    }
    
    private func setupTableView() {
        homeDemoView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        homeDemoView.tableView.dataSource = self
        homeDemoView.tableView.delegate = self
    }
    
    private func didSelectItem(_ item: HomeViewType) {
        switch item {
        case .home:
            let viewController = HomeViewController()
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension HomeDemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = dataSource[safe: indexPath.item] else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        cell.textLabel?.text = item.title
        return cell
    }
}

extension HomeDemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource[safe: indexPath.item] else { return }
        
        didSelectItem(item)
    }
}
