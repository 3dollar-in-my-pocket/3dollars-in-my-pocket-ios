import UIKit

import KakaoSDKShare
import KakaoSDKTemplate

protocol BossStoreDetailCoordinator: AnyObject, BaseCoordinator {
    func pushFeedback(storeId: String)
    
    func pushURL(url: String?)
}

extension BossStoreDetailCoordinator {
    func pushFeedback(storeId: String) {
        let viewController = BossStoreFeedbackViewController.instacne(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    func pushURL(url: String?) {
        guard let urlString = url,
              let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func shareToKakao(store: BossStore) {
        let latitude = store.location?.latitude ?? 0
        let longitude = store.location?.longitude ?? 0
        let urlString
        = "https://map.kakao.com/link/map/\(store.name),\(latitude),\(longitude)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let imageUrl = URL(string: store.imageURL ?? "")!
      let webURL = URL(string: urlString)
      let link = Link(
        webUrl: webURL,
        mobileWebUrl: webURL,
        androidExecutionParams: ["storeId": String(store.id)],
        iosExecutionParams: ["storeId": String(store.id)]
      )
      let content = Content(
        title: "store_detail_share_title".localized,
        imageUrl: imageUrl,
        imageWidth: 500,
        imageHeight: 500,
        description: "store_detail_share_description".localized,
        link: link
      )
      let feedTemplate = FeedTemplate(
        content: content,
        social: nil,
        buttonTitle: nil,
        buttons: [Button(title: "store_detail_share_button".localized, link: link)]
      )
      
        ShareApi.shared.shareDefault(templatable: feedTemplate) { linkResult, error in
            if let error = error {
                self.showErrorAlert(error: error)
            } else {
                if let linkResult = linkResult {
                    UIApplication.shared.open(
                        linkResult.url,
                        options: [:],
                        completionHandler: nil
                    )
                }
            }
        }
    }
}
