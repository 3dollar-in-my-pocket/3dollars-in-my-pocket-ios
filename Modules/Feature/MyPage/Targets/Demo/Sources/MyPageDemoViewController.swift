import UIKit

import Common
import MyPage

import SnapKit

final class MyPageDemoViewController: UIViewController {
    private let tableView = UITableView(frame: .zero)
    private let datasource: [ViewType] = [
        .myPage,
        .setting
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
        title = "MyPage 모듈"
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
    
    private func presentMyPage() {
        let viewController = MyPageViewController.instance()
        viewController.modalPresentationStyle = .overCurrentContext
        
        navigationController?.present(viewController, animated: false)
    }
    
    private func pushSetting() {
        let viewController = SettingViewController()
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MyPageDemoViewController: UITableViewDataSource {
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

extension MyPageDemoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch datasource[indexPath.item] {
        case .myPage:
            presentMyPage()
        case .setting:
            pushSetting()
        }
    }
}
