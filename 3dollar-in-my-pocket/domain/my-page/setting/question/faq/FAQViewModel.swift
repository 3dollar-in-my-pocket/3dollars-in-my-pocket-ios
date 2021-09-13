import RxSwift
import RxCocoa

class FAQViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  struct Input {
    let tapCategory = PublishSubject<Int>()
  }
  
  struct Output {
    let faqCategories = PublishRelay<[FAQCategoryResponse]>()
    let faqs = PublishRelay<[FAQ]>()
    let refreshTableView = PublishRelay<Void>()
    let selectTag = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
  }
  
  let faqService: FAQServiceProtocol
  var currentCategory: FAQCategory? = nil
  var faqs: [[FAQ]] = []
  var filteredfaqs: [[FAQ]] = []
  
  init(faqService: FAQServiceProtocol) {
    self.faqService = faqService
    super.init()
    
    self.input.tapCategory
      .bind(onNext: self.filterTag(index:))
      .disposed(by: disposeBag)
  }
  
  func fetchFAQCategories() {
    self.faqService.fetchFAQCategories()
      .bind(to: self.output.faqCategories)
      .disposed(by: self.disposeBag)
  }
  
  func fetchFAQs() {
    self.faqService.fetchFAQs(category: self.currentCategory)
      .map { $0.map(FAQ.init) }
      .bind(to: self.output.faqs)
      .disposed(by: self.disposeBag)
  }
  
  private func setupFaqs(faqs: [FAQ]) {
    for faq in faqs {
      for tag in faq.tags {
        self.faqs[tag.displayOrder].append(faq)
      }
    }
  }
  
  private func filterTag(index: Int) {
    if index == 0 {
      self.filteredfaqs = self.faqs
    } else {
      self.filteredfaqs = [self.faqs[index - 1]]
    }
    self.output.refreshTableView.accept(())
  }
}
