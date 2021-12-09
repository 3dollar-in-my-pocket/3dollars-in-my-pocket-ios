import UIKit

import RxSwift

final class MyReviewViewController: BaseVC, MyReviewCoordinator {
    private var coordinator: MyReviewCoordinator?
    private let myReviewView = MyReviewView()
    private let viewModel = MyReviewViewModel(reviewService: ReviewService())
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> MyReviewViewController {
        return MyReviewViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.myReviewView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.viewModel.input.viewDidLoad.onNext(())
    }
    
    override func bindEvent() {
        self.myReviewView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popup()
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelInput() {
        self.myReviewView.tableView.rx.itemSelected
            .map { $0.row }
            .bind(to: self.viewModel.input.tapReview)
            .disposed(by: disposeBag)
        
        self.myReviewView.tableView.rx.willDisplayCell
            .map { $0.indexPath.row }
            .bind(to: self.viewModel.input.willDisplayCell)
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelOutput() {
        self.viewModel.output.reviewsPublisher
            .asDriver(onErrorJustReturn: [])
            .drive(self.myReviewView.tableView.rx.items(
                cellIdentifier: MyReviewCell.registerId,
                cellType: MyReviewCell.self
            )) { row, review, cell in
                cell.bind(review: review)
                cell.moreButton.rx.tap
                    .bind(onNext: { [weak self] _ in
                        self?.coordinator?.showMoreActionSheet(row: row, onTapDelete: {
                            self?.viewModel.input.deleteReview.onNext(row)
                        })
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        self.viewModel.output.isHiddenFooter
            .asDriver(onErrorJustReturn: true)
            .drive(self.myReviewView.tableView.rx.isFooterHidden)
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.goToStoreDetail
            .asDriver(onErrorJustReturn: -1)
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.goToStoreDetail(storeId: storeId)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.showLoading
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.showRootLoading(isShow: isShow)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
    }
}
