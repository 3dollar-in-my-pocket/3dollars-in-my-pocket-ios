import RxSwift
import RxCocoa

class FAQViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  struct Input {
    let tapCategory = PublishSubject<Int>()
  }
  
  struct Output {
    let faqTags = PublishRelay<[FAQTag]>()
    let refreshTableView = PublishRelay<Void>()
    let selectTag = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
    let showSystemAlert = PublishRelay<AlertContent>()
  }
  
  let faqService: FAQServiceProtocol
  var faqs: [[FAQ]] = []
  var filteredfaqs: [[FAQ]] = []
  
  init(faqService: FAQServiceProtocol) {
    self.faqService = faqService
    super.init()
    
    self.input.tapCategory
      .bind(onNext: self.filterTag(index:))
      .disposed(by: disposeBag)
  }
  
  func fetchFAQs() {
    self.output.showLoading.accept(true)
    self.faqService.getFAQs()
      .subscribe { faqs in
        let tags = Array(Set(faqs.map { $0.tags }.reduce([], +))).sorted { (tag1, tag2) -> Bool in
          return tag1.displayOrder < tag2.displayOrder
        }
        let totalTag = FAQTag(id: -1, name: "전체", displayOrder: -1)
        
        self.faqs = Array(repeating: [], count: tags.count)
        self.setupFaqs(faqs: faqs)
        self.filteredfaqs = self.faqs
        
        self.output.refreshTableView.accept(())
        self.output.faqTags.accept([totalTag] + tags)
        self.output.selectTag.accept(0)
        self.output.showLoading.accept(false)
      } onError: { error in
        if let error = error as? CommonError {
          let alertContent = AlertContent(
            title: "Error in getFAQs",
            message: error.description
          )
          
          self.output.showLoading.accept(false)
          self.output.showSystemAlert.accept(alertContent)
        }
      }
      .disposed(by: disposeBag)
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
