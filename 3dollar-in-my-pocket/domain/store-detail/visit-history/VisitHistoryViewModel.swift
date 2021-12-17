import RxSwift
import RxCocoa

final class VisitHistoryViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
    }
    
    struct Output {
        let visitHistories = PublishRelay<[VisitHistory]>()
    }
    
    struct Model {
        let visitHistories: [VisitHistory]
    }
    
    let input = Input()
    let output = Output()
    let model: Model
    
    init(visitHistories: [VisitHistory]) {
        self.model = Model(visitHistories: visitHistories)
        
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .compactMap { [weak self] in self?.model.visitHistories }
            .bind(to: self.output.visitHistories)
            .disposed(by: self.disposeBag)
        
        self.input.viewDidLoad
            .compactMap { [weak self] in self?.model.visitHistories }
            .bind(to: self.output.visitHistories)
            .disposed(by: self.disposeBag)
    }

}
