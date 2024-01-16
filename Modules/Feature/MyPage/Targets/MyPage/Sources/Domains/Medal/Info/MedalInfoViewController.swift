import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common

final class MedalInfoViewController: BaseViewController {
    private let medalInfoView = MedalInfoView()
    
    private let viewModel: MedalInfoViewModel
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(viewModel: MedalInfoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.medalInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        medalInfoView.tableView.dataSource = self
        medalInfoView.tableView.delegate = self
    }
    
    override func bindEvent() {
        medalInfoView.closeButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
    }
}

extension MedalInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.medals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let medal = viewModel.output.medals[safe: indexPath.item] else { return UITableViewCell() }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MedalInfoTableViewCell.registerId, for: indexPath) as? MedalInfoTableViewCell else { return UITableViewCell() }
        cell.bind(medal: medal)
        return cell
    }
}

extension MedalInfoViewController: UITableViewDelegate {
    
}
