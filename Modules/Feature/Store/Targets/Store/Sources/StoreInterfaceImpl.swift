import UIKit
import Combine

import DependencyInjection
import StoreInterface
import Model
import Common
import DesignSystem
import ObjectiveC
import SnapKit

public final class StoreInterfaceImpl: StoreInterface {
    public func getStoreDetailFullScreenViewController(storeId: Int) -> UIViewController {
        let location = Preference.shared.userCurrentLocation.coordinate
        return StoreDetailFullScreenViewController(
            storeId: storeId,
            latitude: location.latitude,
            longitude: location.longitude
        )
    }

    public func getStoreDetailSectionsViewController(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        onScrollOffsetChanged: @escaping (CGFloat) -> Void,
        onSectionsLoaded: @escaping () -> Void
    ) -> UIViewController {
        let viewController = StoreSectionsViewController(
            storeId: storeId,
            latitude: latitude,
            longitude: longitude
        )
        viewController.onScrollOffsetChanged = onScrollOffsetChanged
        viewController.onSectionsLoaded = onSectionsLoaded
        return viewController
    }

    public func getVisitViewController(storeId: Int, onSuccessVisit: @escaping (() -> Void)) -> UIViewController {
        let config = VisitViewModel.Config(storeId: String(storeId))
        let viewModel = VisitViewModel(config: config)

        viewModel.output.onSuccessVisit
            .sink { _ in
                onSuccessVisit()
            }
            .store(in: &viewModel.cancellables)

        return VisitViewController(viewModel: viewModel)
    }

    public func getReviewBottomSheetViewController(
        storeId: Int,
        onSuccessWriteReview: @escaping (() -> Void)
    ) -> UIViewController {
        let config = ReviewBottomSheetViewModel.Config(storeId: storeId, review: nil)
        let viewModel = ReviewBottomSheetViewModel(config: config)

        viewModel.output.onSuccessWriteReview
            .sink { _ in
                onSuccessWriteReview()
            }
            .store(in: &viewModel.cancellables)

        return ReviewBottomSheetViewController.instance(viewModel: viewModel)
    }

    public func getMapDetailViewController(location: LocationResponse, storeName: String) -> UIViewController {
        let config = MapDetailViewModel.Config(location: location, storeName: storeName)
        let viewModel = MapDetailViewModel(config: config)
        let viewController = MapDetailViewController(viewModel: viewModel)

        return viewController
    }

    public func getCouponListViewController(onReload: @escaping (() -> Void)) -> UIViewController {
        let viewModel = CouponTabViewModel()
        viewModel.output.onReload
            .sink { _ in
                onReload()
            }
            .store(in: &viewModel.cancellables)
        return CouponTabViewController(viewModel: viewModel)
    }

    public func getUploadPhotoViewController(config: UploadPhotoConfig) -> UIViewController {
        let vmConfig = UploadPhotoViewModel.Config(
            uploadType: .storeImage(storeId: config.storeId),
            shouldDeferUpload: config.shouldDeferUpload
        )
        let viewModel = UploadPhotoViewModel(config: vmConfig)

        if let onSelectedPhotos = config.onSelectedPhotos {
            viewModel.output.onSelectedPhotos
                .sink { photoDatas in
                    onSelectedPhotos(photoDatas)
                }
                .store(in: &viewModel.cancellables)
        }

        if let onSuccessUpload = config.onSuccessUpload {
            viewModel.output.onSuccessUploadPhotos
                .sink { _ in
                    onSuccessUpload()
                }
                .store(in: &viewModel.cancellables)
        }

        return UploadPhotoViewController.instance(viewModel: viewModel)
    }

    public func getPhotoListViewController(storeId: Int) -> UIViewController {
        let viewModel = PhotoListViewModel(config: .init(storeId: storeId))
        return PhotoListViewController.instance(viewModel: viewModel)
    }

    public func presentStoreDisplayItemModal(
        from viewController: UIViewController,
        storeId: Int,
        itemType: StoreDisplayItemType,
        trigger: StoreDisplayTrigger?,
        onDisplayed: @escaping () -> Void
    ) {
        StoreDisplayItemModalPresenter(
            viewController: viewController,
            storeId: storeId,
            itemType: itemType,
            trigger: trigger,
            onDisplayed: onDisplayed
        ).present()
    }
}

private final class StoreDisplayItemModalPresenter: NSObject {
    private static var associationKey: UInt8 = 0

    private weak var viewController: UIViewController?
    private let storeId: Int
    private let itemType: StoreDisplayItemType
    private let trigger: StoreDisplayTrigger?
    private let onDisplayed: () -> Void
    private var dismissWorkItem: DispatchWorkItem?

    init(
        viewController: UIViewController,
        storeId: Int,
        itemType: StoreDisplayItemType,
        trigger: StoreDisplayTrigger?,
        onDisplayed: @escaping () -> Void
    ) {
        self.viewController = viewController
        self.storeId = storeId
        self.itemType = itemType
        self.trigger = trigger
        self.onDisplayed = onDisplayed
    }

    func present() {
        guard let viewController else { return }

        switch itemType {
        case .disappearanceInquiryModal:
            let viewModel = StoreDetailDisappearanceInquiryModalViewModel(config: .init(storeId: storeId))
            let view = StoreDetailDisappearanceInquiryModalView()
            view.bind(viewModel: viewModel)
            viewModel.output.onReportSucceed
                .main
                .sink { [weak self, weak view] in
                    guard let self, let view else { return }
                    self.animateOut(view)
                    let icon = Icons.heartFill.image.withTintColor(Colors.mainRed.color, renderingMode: .alwaysOriginal)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        ToastManager.shared.show(message: Strings.DisplayItemModal.thanksToast, icon: icon)
                    }
                }
                .store(in: &viewModel.cancellables)
            viewModel.output.showErrorAlert
                .main
                .sink { [weak viewController] error in
                    (viewController as? BaseViewController)?.showErrorAlert(error: error)
                }
                .store(in: &viewModel.cancellables)
            viewModel.input.didTapReport
                .main
                .sink { [weak self] in self?.cancelAutoDismiss() }
                .store(in: &viewModel.cancellables)
            if let duration = trigger?.displayDurationSeconds {
                viewModel.output.selectedIndex
                    .compactMap { $0 }
                    .main
                    .sink { [weak self, weak view] _ in
                        guard let self, let view else { return }
                        self.scheduleAutoDismiss(view, duration: duration)
                    }
                    .store(in: &viewModel.cancellables)
            }
            attachAndAnimateIn(view, to: viewController.view)
        case .visitCertificationInducementModal:
            let viewModel = StoreDetailVisitInducementModalViewModel(config: .init(storeId: storeId))
            let view = StoreDetailVisitInducementModalView()
            view.bind(viewModel: viewModel)
            viewModel.output.onSuccessVisit
                .main
                .sink { [weak self, weak view] _ in
                    guard let self, let view else { return }
                    self.animateOut(view)
                }
                .store(in: &viewModel.cancellables)
            viewModel.output.showErrorAlert
                .main
                .sink { [weak viewController] error in
                    (viewController as? BaseViewController)?.showErrorAlert(error: error)
                }
                .store(in: &viewModel.cancellables)
            attachAndAnimateIn(view, to: viewController.view)
        case .unknown:
            break
        }
    }

    private func attachAndAnimateIn(_ modal: UIView, to container: UIView) {
        container.addSubview(modal)
        modal.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        objc_setAssociatedObject(modal, &Self.associationKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        container.layoutIfNeeded()
        let translationY = max(modal.bounds.height + 40, 240)
        modal.transform = .init(translationX: 0, y: translationY)
        modal.alpha = 0
        let delay = trigger?.displayAfterSeconds ?? 0
        if delay > 0 {
            modal.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak modal] in
                modal?.isUserInteractionEnabled = true
            }
        }
        UIView.animate(withDuration: 0.5, delay: delay, options: [.curveEaseInOut]) { [weak modal] in
            modal?.transform = .identity
            modal?.alpha = 1
        } completion: { [weak self, weak modal] _ in
            guard let self, let modal, modal.superview != nil else { return }
            self.onDisplayed()
            if let duration = self.trigger?.displayDurationSeconds {
                self.scheduleAutoDismiss(modal, duration: duration)
            }
        }
    }

    private func scheduleAutoDismiss(_ modal: UIView, duration: Double) {
        cancelAutoDismiss()
        let workItem = DispatchWorkItem { [weak self, weak modal] in
            guard let self, let modal, modal.superview != nil else { return }
            self.dismissWorkItem = nil
            self.animateOut(modal)
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    private func cancelAutoDismiss() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil
    }

    private func animateOut(_ modal: UIView) {
        cancelAutoDismiss()
        let translationY = max(modal.bounds.height + 40, 240)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
            modal.transform = .init(translationX: 0, y: translationY)
            modal.alpha = 0
        } completion: { _ in
            modal.removeFromSuperview()
        }
    }
}

public extension StoreInterfaceImpl {
    static func registerStoreInterface() {
        DIContainer.shared.container.register(StoreInterface.self) { _ in
            return StoreInterfaceImpl()
        }
    }
}
