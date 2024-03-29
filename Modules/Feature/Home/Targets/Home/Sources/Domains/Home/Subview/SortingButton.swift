import UIKit
import Combine

import DesignSystem
import Model

final class SortingButton: UIButton {
    let sortTypePublisher = PassthroughSubject<StoreSortType, Never>()
    
    private var sortType: StoreSortType = .distanceAsc
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        layer.borderWidth = 1
        backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        layer.cornerRadius = 10
        setTitle(HomeStrings.homeSortingButtonDistance, for: .normal)
        setTitleColor(DesignSystemAsset.Colors.gray70.color, for: .normal)
        setImage(DesignSystemAsset.Icons.change.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.gray70.color), for: .normal)
        titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -4)
        contentEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 14)
        
        controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sortType = owner.sortType.toggled()
                owner.bind(owner.sortType)
            })
            .withUnretained(self)
            .map { owner, _ in
                return owner.sortType
            }
            .subscribe(sortTypePublisher)
            .store(in: &cancellables)
    }
    
    func bind(_ sortType: StoreSortType) {
        self.sortType = sortType
        switch sortType {
        case .distanceAsc:
            setTitle(HomeStrings.homeSortingButtonDistance, for: .normal)
        case .latest:
            setTitle(HomeStrings.homeSortingButtonLatest, for: .normal)
        case .unknown:
            break
        }
    }
}
