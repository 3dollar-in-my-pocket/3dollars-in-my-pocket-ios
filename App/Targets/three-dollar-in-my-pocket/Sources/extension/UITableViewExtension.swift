import UIKit

import RxSwift
import RxCocoa

extension UITableView {
    func register(_ types: [BaseTableViewCell.Type]) {
        for type in types {
            self.register(type, forCellReuseIdentifier: "\(type.self)")
        }
    }
    
    func addIndicatorFooter() {
        let indicator = UIActivityIndicatorView(style: .medium)
        
        indicator.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 60
        )
        self.tableFooterView = indicator
    }
}


extension Reactive where Base: UITableView {
    var isFooterHidden: Binder<Bool> {
        return Binder(self.base) { view, isFooterHidden in
            if let indicator = view.tableFooterView as? UIActivityIndicatorView {
                if isFooterHidden {
                    indicator.stopAnimating()
                } else {
                    indicator.startAnimating()
                }
            }
            view.tableFooterView?.isHidden = isFooterHidden
        }
    }
}
