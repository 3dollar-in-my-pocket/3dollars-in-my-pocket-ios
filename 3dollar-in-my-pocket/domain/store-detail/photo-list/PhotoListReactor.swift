import RxSwift
import RxCocoa
import ReactorKit

final class PhotoListReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapPhoto(index: Int)
    }
    
    enum Mutation {
        case showLoading(isShow: Bool)
        case showPhotoDetail(storeId: Int, index: Int, photos: [Image])
        case showErrorAlert(Error)
    }
    
    struct State {
        var photos: [Image]
    }
    
    let presentPhotoDetailPublisher = PublishRelay<(Int, Int, [Image])>()
    private let storeId: Int
    private let storeService: StoreServiceProtocol
    
    struct Input {
        let tapPhoto = PublishSubject<Int>()
    }
    
    struct Output {
        let photos = PublishRelay<[Image]>()
        let showPhotoDetail = PublishRelay<(Int, Int, [Image])>()
        let showLoading = PublishRelay<Bool>()
    }
    
    init(storeId: Int, storeService: StoreServiceProtocol) {
        self.storeId = storeId
        self.storeService = storeService
        super.init()
        
        self.input.tapPhoto
            .withLatestFrom(self.output.photos) { (self.storeId, $0, $1)}
            .bind(to: self.output.showPhotoDetail)
            .disposed(by: disposeBag)
    }
    
    
    
    func fetchPhotos(){
        self.output.showLoading.accept(true)
        self.storeService.getPhotos(storeId: self.storeId)
            .subscribe { [weak self] photoResponse in
                guard let self = self else { return }
                let photos = photoResponse.map { Image(response: $0) }
                
                self.output.photos.accept(photos)
                self.output.showLoading.accept(false)
            } onError: { [weak self] error in
                guard let self = self else { return }
                if let httpError = error as? HTTPError {
                    self.httpErrorAlert.accept(httpError)
                }
                if let commonError = error as? CommonError {
                    let alertContent = AlertContent(title: nil, message: commonError.description)
                    
                    self.showSystemAlert.accept(alertContent)
                }
                self.output.showLoading.accept(false)
            }
            .disposed(by: disposeBag)
    }
}
