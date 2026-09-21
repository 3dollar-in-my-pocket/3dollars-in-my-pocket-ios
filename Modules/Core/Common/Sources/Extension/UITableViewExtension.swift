import UIKit

public extension UITableView {
    /// 셀 타입 이름을 reuseIdentifier 로 등록한다 (UICollectionView 확장과 동일 규칙).
    func register(_ cellTypes: [UITableViewCell.Type]) {
        for cellType in cellTypes {
            register(cellType, forCellReuseIdentifier: "\(cellType.self)")
        }
    }

    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as? T else {
            fatalError("정의되지 않은 UITableViewCell 입니다.")
        }

        return cell
    }
}
