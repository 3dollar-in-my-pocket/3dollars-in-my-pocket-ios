import RxSwift
import RxCocoa

final class MyReviewViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
        let tapReview = PublishSubject<Int>()
        let tapMore = PublishSubject<Int>()
        let willDisplayCell = PublishSubject<Int>()
        let deleteReview = PublishSubject<Int>()
    }
    
    struct Output {
        let isHiddenFooter = PublishRelay<Bool>()
        let goToStoreDetail = PublishRelay<Int>()
        let reviewsPublisher = PublishRelay<[Review]>()
        
        var reviews: [Review] = [] {
            didSet {
                self.reviewsPublisher.accept(reviews)
            }
        }
    }
    
    let input = Input()
    var output = Output()
    let reviewService: ReviewServiceProtocol
    
    var cursor: Int?
    
    
    init(reviewService: ReviewServiceProtocol) {
        self.reviewService = reviewService
        
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .map { [weak self] in self?.cursor }
            .bind(onNext: { [weak self] cursor in
                self?.fetchMyReviews(cursor: cursor)
            })
            .disposed(by: self.disposeBag)
        
        self.input.tapReview
            .compactMap { [weak self] index in self?.output.reviews[index].store }
            .filter { !$0.isDeleted }
            .map { $0.storeId }
            .bind(to: self.output.goToStoreDetail)
            .disposed(by: self.disposeBag)
        
        self.input.willDisplayCell
            .filter { [weak self] in
                guard let self = self else { return false }
                
                return self.canLoadMore(reviews: self.output.reviews, index: $0)
            }
            .map { [weak self] _ in self?.cursor }
            .bind(onNext: { [weak self] cursor in
                self?.fetchMyReviews(cursor: cursor)
            })
            .disposed(by: self.disposeBag)
        
        self.input.deleteReview
            .compactMap { [weak self] index in
                self?.output.reviews[index].reviewId
            }
            .bind(onNext: { [weak self] reviewId in
                self?.deleteReview(reviewId: reviewId)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func fetchMyReviews(cursor: Int?) {
        self.output.isHiddenFooter.accept(false)
        self.reviewService.fetchMyReviews(
            cursor: cursor,
            size: 20
        )
        .do(onNext: { [weak self] pagination in
            self?.cursor = pagination.nextCursor
        })
        .map { $0.contents.map(Review.init) }
        .map { [weak self] newReviews -> [Review] in
            guard let self = self else { return [] }
            return self.output.reviews + newReviews
        }
        .subscribe(
            onNext: { [weak self] reviews in
                self?.output.reviews = reviews
                self?.output.isHiddenFooter.accept(true)
            },
            onError: { [weak self] error in
                self?.showErrorAlert.accept(error)
                self?.output.isHiddenFooter.accept(true)
            }
        )
        .disposed(by: self.disposeBag)
    }
    
    private func deleteReview(reviewId: Int) {
        self.showLoading.accept(true)
        self.reviewService.deleteReview(reviewId: reviewId)
            .subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else { return }
                    
                    if let targetIndex = self.output.reviews.firstIndex(
                        where: { $0.reviewId == reviewId }) {
                        self.output.reviews.remove(at: targetIndex)
                    }
                    self.showLoading.accept(false)
                },
                onError: { [weak self] error in
                    self?.showErrorAlert.accept(error)
                    self?.showLoading.accept(false)
                }
            ).disposed(by: self.disposeBag)
    }
    
    private func canLoadMore(reviews: [Review], index: Int) -> Bool {
        return reviews.count - 1 <= index && self.cursor != nil && self.cursor != -1
    }
}
