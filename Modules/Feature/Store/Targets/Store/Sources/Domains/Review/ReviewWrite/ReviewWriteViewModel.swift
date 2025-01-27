import UIKit
import Combine

import Common
import DesignSystem
import Model
import Networking
import Log

final class ReviewWriteViewModel: BaseViewModel {
    struct Input {
    }
    
    struct Output {
        let feedbackSelectionViewModel: ReviewFeedbackSelectionViewModel
    }
    
    enum Route {
        case dismiss
    }
    
    struct Config {
        let storeId: String
        let feedbackTypes: [FeedbackType]
    }
    
    let input = Input()
    let output: Output
    
    private let config: Config
    
    init(
        config: Config
    ) {
        self.config = config
        self.output = Output(feedbackSelectionViewModel: .init(storeId: config.storeId, feedbackTypes: config.feedbackTypes))
    }
    
    override func bind() {
        
    }
}
