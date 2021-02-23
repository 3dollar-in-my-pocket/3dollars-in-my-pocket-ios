import RxSwift
import RxCocoa

class CategoryListViewModel: BaseViewModel {
  
  let input = Input()
  let ouput = Output()
  let categoryService: CategoryServiceProtocol
  
  struct Input {
    
  }
  
  struct Output {
    
  }
  
  init(categoryService: CategoryServiceProtocol) {
    self.categoryService = categoryService
    super.init()
  }
}
