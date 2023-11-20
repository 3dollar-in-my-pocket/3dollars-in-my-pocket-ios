import RxSwift
import RxCocoa

class FAQViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tapCategory = PublishSubject<Int>()
  }
  
  struct Output {
    let faqCategories = PublishRelay<[FAQCategoryResponse]>()
    let refreshTableView = PublishRelay<Void>()
    let selectTag = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
  }
  
  let faqService: FAQServiceProtocol
  var currentCategory: FAQCategoryResponse?
  var categories: [FAQCategoryResponse] = []
  var faqs: [[FAQ]] = []
  var filteredfaqs: [[FAQ]] = []
  
  init(faqService: FAQServiceProtocol) {
    self.faqService = faqService
    super.init()
    
    self.input.viewDidLoad
      .bind(onNext: { [weak self] in
        self?.fetchFAQCategories()
      })
      .disposed(by: self.disposeBag)
    
    self.input.tapCategory
      .bind(onNext: self.filterTag(index:))
      .disposed(by: disposeBag)
  }
  
  private func fetchFAQCategories() {
    self.faqService.fetchFAQCategories()
      .map {
        let allCategory = FAQCategoryResponse(
          category: .all,
          description: "전체",
          displayOrder: 0
        )
        
        return [allCategory] + $0.sorted()
      }
      .do(onNext: { [weak self] response in
        self?.categories = response
        self?.fetchFAQs()
      })
      .bind(to: self.output.faqCategories)
      .disposed(by: self.disposeBag)
  }
  
  private func fetchFAQs() {
    self.faqService.fetchFAQs(category: nil)
      .map { $0.map(FAQ.init) }
      .subscribe(
        onNext: { [weak self] faqs in
          guard let self = self else { return }
          
          self.faqs = Array(repeating: [], count: self.categories.count)
          self.setupFaqs(faqs: faqs)
          self.filteredfaqs = self.faqs
          
          self.output.refreshTableView.accept(())
          self.output.selectTag.accept(0)
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
      )
      .disposed(by: self.disposeBag)
  }
  
  private func setupFaqs(faqs: [FAQ]) {
    for faq in faqs {
      let firstIndex = self.categories.firstIndex { $0.category == faq.category }
      if let first = firstIndex {
        Log.debug("index: \(first)")
        self.faqs[first].append(faq)
      }
      self.faqs[0].append(faq)
    }
  }
  
  private func filterTag(index: Int) {
    if index == 0 {
      self.filteredfaqs = Array(self.faqs[1..<self.faqs.count-1])
    } else {
      self.filteredfaqs = [self.faqs[index]]
    }
    self.output.refreshTableView.accept(())
  }
}
