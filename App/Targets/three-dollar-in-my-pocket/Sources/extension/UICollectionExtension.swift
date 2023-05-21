import UIKit

extension UICollectionView {
    func register(_ types: [BaseCollectionViewCell.Type]) {
        for type in types {
            self.register(type, forCellWithReuseIdentifier: "\(type.self)")
        }
    }
}
