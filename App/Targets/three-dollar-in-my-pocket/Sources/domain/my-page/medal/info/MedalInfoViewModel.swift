import RxSwift
import RxCocoa

final class MedalInfoViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
    }
    
    struct Output {
        let medals = PublishRelay<[Medal]>()
    }
    
    let input = Input()
    let output = Output()
    let metaContext: MetaContext
    
    init(metaContext: MetaContext) {
        self.metaContext = metaContext
        
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .compactMap { [weak self] in self?.metaContext.medals }
            .bind(to: self.output.medals)
            .disposed(by: self.disposeBag)
    }
}
