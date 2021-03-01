import RxSwift
import RxCocoa

class MyReviewViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let reviewService: ReviewServiceProtocol
  
  var reviews: [Review] = []
  var totalCount = 0
  var totalPage = 0
  var currentPage = 1
  
  struct Input {
    let tapReview = PublishSubject<Int>()
    let tapMore = PublishSubject<Int>()
    let loadMore = PublishSubject<Int>()
    let deleteReview = PublishSubject<Int>()
  }
  
  struct Output {
    let reviews = PublishRelay<[Review]>()
    let isHiddenFooter = PublishRelay<Bool>()
    let goToStoreDetail = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
  }
  
  
  init(reviewService: ReviewServiceProtocol) {
    self.reviewService = reviewService
    super.init()
    
    self.input.tapReview
      .map { self.reviews[$0].storeId }
      .bind(to: self.output.goToStoreDetail)
      .disposed(by: disposeBag)
    
    self.input.loadMore
      .filter { self.reviews.count - 1 == $0 && self.currentPage < self.totalPage }
      .do { [weak self] _ in
        guard let self = self else { return }
        self.currentPage = self.currentPage + 1
      }
      .map { _ in Void() }
      .bind(onNext: self.fetchMyReviews)
      .disposed(by: disposeBag)
    
    self.input.deleteReview
      .map { self.reviews[$0].id }
      .bind(onNext: self.deleteReview(reviewId:))
      .disposed(by: disposeBag)
  }
  
  func fetchMyReviews() {
    self.output.isHiddenFooter.accept(false)
    self.reviewService.getMyReview(page: self.currentPage)
      .subscribe(
        onNext: { [weak self] pageRevies in
          guard let self = self else { return }
          self.totalCount = pageRevies.totalElements
          self.totalPage = pageRevies.totalPages
          self.reviews = self.reviews + pageRevies.content
          self.output.reviews.accept(self.reviews)
          self.output.isHiddenFooter.accept(true)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          }
          self.output.isHiddenFooter.accept(true)
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func deleteReview(reviewId: Int) {
    self.output.showLoading.accept(true)
    self.reviewService.deleteRevie(reviewId: reviewId)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          
          self.revmoveReview(reviewId: reviewId)
          self.totalCount = self.totalCount - 1
          self.output.reviews.accept(self.reviews)
          self.output.showLoading.accept(false)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          } else if let error = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: error.description)
            
            self.showSystemAlert.accept(alertContent)
          }
          self.output.showLoading.accept(false)
        }
      ).disposed(by: self.disposeBag)
  }
  
  private func revmoveReview(reviewId: Int) {
    for index in self.reviews.indices {
      if self.reviews[index].id == reviewId {
        self.reviews.remove(at: index)
        break
      }
    }
  }
}
