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
        let updateMyPageMedalPublisher = PublishRelay<Medal>()
        let selectMedalPublisher = PublishRelay<Int>()
        let showMedalInfoPublisher = PublishRelay<Void>()
    }
    
    let input = Input()
    var output = Output()
    let medalService: MedalServiceProtocol
    let metaContext: MetaContext
    var medal: Medal
    
    init(
        medal: Medal,
        metaContext: MetaContext,
        medalService: MedalServiceProtocol
    ) {
        self.medal = medal
        self.metaContext = metaContext
        self.medalService = medalService
        
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .bind { [weak self] in
                self?.fetchMyMedals()
            }
            .disposed(by: self.disposeBag)
        
        self.input.tapMedal
            .bind(onNext: { [weak self] index in
                guard let self = self else { return }
                let selectedMedal = self.output.medals[1].items[index]
                if selectedMedal.isOwned {
                    self.changeMyMedal(medalId: selectedMedal.medalId)
                } else {
                    self.selectMyMedal()
                    self.output.showMedalInfoPublisher.accept(())
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func fetchMyMedals() {
        self.medalService.fetchMyMedals()
            .map { $0.map(Medal.init) }
            .subscribe(
                onNext: { [weak self] myMedals in
                    guard let self = self else { return }
                    var medals = self.metaContext.medals
                    
                    for index in medals.indices {
                        medals[index].isOwned = myMedals.contains(medals[index])
                    }
                    
                    let myMedalSection = SectionModel(model: "", items: [self.medal])
                    let medalsSection = SectionModel(
                        model: "내 칭호",
                        items: medals
                    )
                    
                    self.output.medals = [myMedalSection, medalsSection]
                    self.selectMyMedal()
                },
                onError: { [weak self] error in
                    self?.showErrorAlert.accept(error)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    private func changeMyMedal(medalId: Int) {
        self.medalService.changeMyMdal(medalId: medalId)
            .map(User.init)
            .subscribe(
                onNext: { [weak self] user in
                    self?.output.updateMyPageMedalPublisher.accept(user.medal)
                    self?.output.medals[0].items = [user.medal]
                    self?.medal = user.medal
                    self?.selectMyMedal()
                },
                onError: { [weak self] error in
                    self?.selectMyMedal()
                    self?.showErrorAlert.accept(error)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    private func selectMyMedal() {
        if let myMedalIndex = self.output.medals[1].items.firstIndex(of: self.medal) {
            self.output.selectMedalPublisher.accept(myMedalIndex)
        }
    }
}
