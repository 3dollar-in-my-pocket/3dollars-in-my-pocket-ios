import UIKit

import Common
import SnapKit

final class HomeDemoView: BaseView {
    let tableView = UITableView(frame: .zero)
    
    override func setup() {
        backgroundColor = .white
        addSubview(tableView)
    }
    
    override func bindConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
