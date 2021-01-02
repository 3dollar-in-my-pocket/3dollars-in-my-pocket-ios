import UIKit
import RxSwift
import RxCocoa

class BaseTableViewCell: UITableViewCell {
  
  var disposeBag = DisposeBag()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setup()
    bindConstraints()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setup()
    bindConstraints()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.disposeBag = DisposeBag()
  }
  
  func setup() { }
  
  func bindConstraints() { }
}
