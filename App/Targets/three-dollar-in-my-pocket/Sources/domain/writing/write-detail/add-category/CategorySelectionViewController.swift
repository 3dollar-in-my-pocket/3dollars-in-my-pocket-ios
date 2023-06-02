import UIKit

final class CategorySelectionViewController: BaseBottomSheetViewController {
    private let categorySelectionView = CategorySelectionView()
    
    static func instance() -> CategorySelectionViewController {
        return CategorySelectionViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = categorySelectionView
    }
    
    override func bindEvent() {
        categorySelectionView.backgroundButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss()
            }
            .store(in: &cancellables)
    }
}
