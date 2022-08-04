import Alamofire
import RxSwift

protocol FeedbackServiceProtocol {
    func fetchFeedbackTypes() -> Observable<[BossStoreFeedbackMeta]>
    
    func sendFeedbacks(
        bossStoreId: String,
        feedbackTypes: [BossStoreFeedbackType]
    ) -> Observable<Void>
}

struct FeedbackService: FeedbackServiceProtocol {
    private let networkManager = NetworkManager()
    
    func fetchFeedbackTypes() -> Observable<[BossStoreFeedbackMeta]> {
        let urlString = HTTPUtils.url + "/api/v1/boss/store/feedback/types"
        
        return self.networkManager.createGetObservable(
            class: [BossStoreFeedbackTypeResponse].self,
            urlString: urlString,
            headers: HTTPUtils.jsonHeader()
        )
        .map { $0.map(BossStoreFeedbackMeta.init(response:))}
    }
    
    func sendFeedbacks(
        bossStoreId: String,
        feedbackTypes: [BossStoreFeedbackType]
    ) -> Observable<Void> {
        let urlString = HTTPUtils.url + "/api/v1/boss/store/\(bossStoreId)/feedback"
        let parameters = ["feedbackTypes": feedbackTypes.map { $0.rawValue }]
        
        return .create { observer in
            HTTPUtils.defaultSession.request(
                urlString,
                method: .post,
                parameters: parameters,
                encoder: JSONParameterEncoder.default,
                headers: HTTPUtils.defaultHeader()
            ).responseData { response in
                if response.isSuccess() {
                    observer.processValue(class: String.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            }
            
            return Disposables.create()
        }
        .map { () }
    }
}
