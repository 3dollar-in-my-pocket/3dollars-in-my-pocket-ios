import UIKit
import Combine

import Model
import Networking
import Log

public protocol StoreInterface {
    func getStoreDetailViewController(storeId: Int) -> UIViewController

    func getBossStoreDetailViewController(
        storeId: String,
        shouldPushReviewList: Bool
    ) -> UIViewController

    func getVisitViewController(storeId: Int, onSuccessVisit: @escaping (() -> Void)) -> UIViewController
    
    func getMapDetailViewController(location: LocationResponse, storeName: String) -> UIViewController
}


// MARK: StoreDetail
public protocol StoreDetailDependency {
    var storeDetailRepository: StoreDetailRepository { get }
    var reportRepository: ReportRepository { get }
    var logManager: LogManagerProtocol { get }
}

public final class StoreDetailDependencyImpl: StoreDetailDependency {
    public let storeDetailRepository: StoreDetailRepository
    public let reportRepository: ReportRepository
    public let logManager: LogManagerProtocol
    
    public init(
        storeDetailRepository: StoreDetailRepository = StoreDetailRepositoryImpl(),
        reportRepository: ReportRepository = ReportRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.storeDetailRepository = storeDetailRepository
        self.reportRepository = reportRepository
        self.logManager = logManager
    }
}

public struct StoreDetailConfig {
    public let storeId: String
}
