import Combine

import Common
import Model
import Networking
import Log

public final class FaqViewModel: BaseViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let filterCategory = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .faq
        let faqCategory = CurrentValueSubject<[FaqCategoryResponse], Never>([])
        let faqSections = CurrentValueSubject<[[FaqResponse]], Never>([])
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    let input = Input()
    let output = Output()
    private let faqService: FaqServiceProtocol
    
    public init(faqService: FaqServiceProtocol = FaqService()) {
        self.faqService = faqService
    }
    
    public override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: FaqViewModel, _) in
                owner.fetchFaqCategory()
                owner.fetchFaq()
            }
            .store(in: &cancellables)
        
        input.filterCategory
            .removeDuplicates()
            .withUnretained(self)
            .sink { (owner: FaqViewModel, index: Int) in
                guard let category = owner.output.faqCategory.value[safe: index]?.category else { return }
                
                owner.fetchFaq(category: category)
            }
            .store(in: &cancellables)
    }
    
    private func fetchFaqCategory() {
        Task { [weak self] in
            guard let self else { return }
            
            let result = await faqService.fetchFaqCategory()
            
            switch result {
            case .success(let categories):
                let allCategory = FaqCategoryResponse(category: "ALL", description: "전체")
                
                output.faqCategory.send([allCategory] + categories)
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
        .store(in: taskBag)
    }
    
    private func fetchFaq(category: String? = nil) {
        Task { [weak self] in
            guard let self else { return }
            let category = category == "ALL" ? nil : category
            let result = await faqService.fetchFaq(category: category)
            
            switch result {
            case .success(let faqs):
                output.faqSections.send(getSortedFaqByCategory(faqs: faqs))
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
        .store(in: taskBag)
    }
    
    private func getSortedFaqByCategory(faqs: [FaqResponse]) -> [[FaqResponse]] {
        var faqSections: [[FaqResponse]] = []
        
        for faq in faqs {
            let categories = faqSections.compactMap { $0.first?.categoryInfo }
            if let targetIndex = categories.firstIndex(of: faq.categoryInfo) {
                faqSections[targetIndex].append(faq)
            } else {
                faqSections.append([faq])
            }
        }
        
        return faqSections
    }
}
