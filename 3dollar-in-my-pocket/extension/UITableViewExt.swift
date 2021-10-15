import UIKit

extension UITableView {
  func register(_ types: [BaseTableViewCell.Type]) {
    for type in types {
      self.register(type, forCellReuseIdentifier: "\(type.self)")
    }
  }
}
