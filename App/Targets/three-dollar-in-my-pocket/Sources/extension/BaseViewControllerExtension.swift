import Common
import Networking

extension Common.BaseViewController {
    func showErrorAlert(error: Error) {
        // TODO: 에러 종류에 따라 다르게 노출시켜야하는 로직 필요
        AlertUtils.showWithAction(
            viewController: self,
            title: error.localizedDescription,
            onTapOk: nil
        )
    }
}
