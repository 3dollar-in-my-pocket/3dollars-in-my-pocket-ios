import RxSwift
import RxCocoa
import RxDataSources

final class MyMedalViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
        let tapMedal = PublishSubject<Int>()
    }
    
    struct Output {
        var medals: [SectionModel<String, Medal>] = [] {
            didSet {
                self.medalsPublisher.accept(medals)
            }
        }
        
        let medalsPublisher = PublishRelay<[SectionModel<String, Medal>]>()
    }
    
    let input = Input()
    var output = Output()
    let medalService: MedalServiceProtocol
    let medalContext: MedalContext
    let medal: Medal
    
    init(
        medal: Medal,
        medalContext: MedalContext,
        medalService: MedalServiceProtocol
    ) {
        self.medal = medal
        self.medalContext = medalContext
        self.medalService = medalService
        
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .bind { [weak self] in
                self?.fetchMyMedals()
            }
            .disposed(by: self.disposeBag)
    }
    
    private func fetchMyMedals() {
        self.medalService.fetchMyMedals()
            .map { $0.map(Medal.init) }
            .subscribe(
                onNext: { [weak self] medals in
                    guard let self = self else { return }
                    let myMedalSection = SectionModel(model: "", items: [self.medal])
                    let medalsSection = SectionModel(
                        model: "내 칭호",
                        items: self.medalContext.medals
                    )
                    
                    self.output.medals = [myMedalSection, medalsSection]
                },
                onError: { [weak self] error in
                    self?.showErrorAlert.accept(error)
                }
            )
            .disposed(by: self.disposeBag)
            
    }
}
