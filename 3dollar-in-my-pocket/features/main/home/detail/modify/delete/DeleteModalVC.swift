import UIKit

protocol DeleteModalDelegate: class {
    func onTapClose()
    
    func onRequest()
}

class DeleteModalVC: BaseVC {
    
    weak var deleagete: DeleteModalDelegate?
    var storeId: Int!
    
    private lazy var deleteModalView = DeleteModalView(frame: self.view.frame).then {
        $0.delegate = self
    }
    
    static func instance(storeId: Int) -> DeleteModalVC {
        return DeleteModalVC(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.storeId = storeId
        }
    }
    
    override func viewDidLoad() {
        view = deleteModalView
    }
    
    override func bindViewModel() {
    }
    
    private func requestDelete() {
        StoreService.deleteStore(storeId: self.storeId, deleteReasonType: DeleteReason.init(rawValue: deleteModalView.deleteReason)!) { [weak self] (response) in
            switch response.result {
            case .success(_):
                self?.deleagete?.onRequest()
            case .failure(_):
                if let vc = self {
                    AlertUtils.show(controller: vc, message: "이미 삭제요청을 했습니다.")
                }
            }
        }
    }
}

extension DeleteModalVC: DeleteModalViewDelegate {
    func onTapRequest() {
        self.requestDelete()
    }
    
    func onTapClose() {
        self.deleagete?.onTapClose()
    }
}

public enum DeleteReason: String {
    case NOSTORE = "NOSTORE"
    case WRONGNOPOSITION = "WRONGNOPOSITION"
    case OVERLAPSTORE = "OVERLAPSTORE"
    
    func getValue() -> String {
        return self.rawValue
    }
}
