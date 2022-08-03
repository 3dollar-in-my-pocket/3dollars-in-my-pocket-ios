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
        return .empty()
    }
}
