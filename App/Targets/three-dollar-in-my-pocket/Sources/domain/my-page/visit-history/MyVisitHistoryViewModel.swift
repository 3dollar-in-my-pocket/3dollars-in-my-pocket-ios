import RxSwift
import RxCocoa
import RxDataSources

final class MyVisitHistoryViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
        let tapVisitHistory = PublishSubject<Int>()
        let willDisplayCell = PublishSubject<Int>()
    }
    
    struct Output {
        let isHiddenFooter = PublishRelay<Bool>()
        let goToStoreDetail = PublishRelay<Int>()
        let visitHistoriesPublisher = PublishRelay<[VisitHistory]>()
        
        var visitHistories: [VisitHistory] = [] {
            didSet {
                self.visitHistoriesPublisher.accept(visitHistories)
            }
        }
    }
    
    let input = Input()
    var output = Output()
    let historyService: VisitHistoryServiceProtocol
    
    var cursor: Int?
    
    init(historyService: VisitHistoryServiceProtocol) {
        self.historyService = historyService
        
        super.init()
    }
    
    override func bind() {
        self.input.viewDidLoad
            .map { [weak self] in self?.cursor }
            .bind(onNext: { [weak self] cursor in
                self?.fetchVisitHistories(cursor: cursor)
            })
            .disposed(by: self.disposeBag)
        
        self.input.tapVisitHistory
            .compactMap { [weak self] index in self?.output.visitHistories[index].store }
            .filter { !$0.isDeleted }
            .map { $0.storeId }
            .bind(to: self.output.goToStoreDetail)
            .disposed(by: self.disposeBag)

        self.input.willDisplayCell
            .filter { self.canLoadMore(visitHistories: self.output.visitHistories, index: $0) }
            .map { [weak self] _ in self?.cursor }
            .bind(onNext: { [weak self] cursor in
                self?.fetchVisitHistories(cursor: cursor)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func fetchVisitHistories(cursor: Int?) {
        self.output.isHiddenFooter.accept(false)
        self.historyService.fetchVisitHistory(cursor: cursor, size: 20)
            .do(onNext: { [weak self] pagination in
                self?.cursor = pagination.nextCursor
            })
            .map { $0.contents.map(VisitHistory.init) }
            .map { [weak self] newVisitHistories -> [VisitHistory] in
                guard let self = self else { return [] }
                
                return self.output.visitHistories + newVisitHistories
            }
            .subscribe(
                onNext: { [weak self] visitHistories in
                    self?.output.visitHistories = visitHistories
                    self?.output.isHiddenFooter.accept(true)
                },
                onError: { [weak self] error in
                    self?.showErrorAlert.accept(error)
                    self?.output.isHiddenFooter.accept(true)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    private func canLoadMore(visitHistories: [VisitHistory], index: Int) -> Bool {
        return visitHistories.count - 1 <= index && self.cursor != nil && self.cursor != -1
    }
    
    // TODO: 그룹핑 예정
//    private func groupingByDate(visitHistories: [VisitHistory]) -> [SectionModel<String, VisitHistory>] {
//        var sectionModels: [SectionModel<String, VisitHistory>] = []
//        var baseDate = ""
//        var itemVisitHistories: [VisitHistory] = []
//
//        for visitHistory in visitHistories {
//            let visitDate = DateUtils.toString(
//                dateString: visitHistory.createdAt,
//                format: "yyyy년 MM월 dd일"
//            )
//
//            if baseDate != visitDate {
//                if baseDate != "" {
//                    sectionModels.append(SectionModel(model: baseDate, items: itemVisitHistories))
//                    itemVisitHistories.removeAll()
//                }
//
//                baseDate = visitDate
//            }
//            itemVisitHistories.append(visitHistory)
//        }
//
//        return sectionModels
//    }
}
