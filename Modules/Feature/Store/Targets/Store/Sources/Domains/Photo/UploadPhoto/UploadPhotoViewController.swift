import Foundation
import UIKit
import Photos

import Common
import DesignSystem

final class UploadPhotoViewController: BaseViewController {
    private let uploadPhotoView = UploadPhotoView()
    private let viewModel: UploadPhotoViewModel
    
    static func instance(viewModel: UploadPhotoViewModel) -> UploadPhotoViewController {
        return UploadPhotoViewController(viewModel: viewModel)
    }
    
    private var assets: [PHAsset] = []
    
    init(viewModel: UploadPhotoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = uploadPhotoView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()
        uploadPhotoView.photoCollectionView.delegate = self
        uploadPhotoView.photoCollectionView.dataSource = self
        viewModel.input.load.send(())
    }
    
    override func bindEvent() {
        uploadPhotoView.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink(receiveValue: { (owner: UploadPhotoViewController, _) in
                owner.dismiss(animated: true)
            })
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        uploadPhotoView.uploadButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapUpload)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.assets
            .main
            .withUnretained(self)
            .sink { (owner: UploadPhotoViewController, assets: [PHAsset]) in
                owner.assets = assets
                owner.uploadPhotoView.photoCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.output.uploadButtonTitle
            .main
            .withUnretained(self)
            .sink(receiveValue: { (owner: UploadPhotoViewController, title) in
                owner.uploadPhotoView.uploadButton.setTitle(title, for: .normal)
            })
            .store(in: &cancellables)
        
        viewModel.output.isEnableUploadButton
            .main
            .assign(to: \.isEnabled, on: uploadPhotoView.uploadButton)
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: UploadPhotoViewController, error) in
                if error is PhotoError {
                    owner.showAuthorizationError()
                } else {
                    owner.showErrorAlert(error: error)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.showToast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { isShow in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: UploadPhotoViewController, route) in
                
            }
            .store(in: &cancellables)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecome),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidBecome() {
        viewModel.input.load.send(())
    }
    
    private func showAuthorizationError() {
        AlertUtils.showWithCancel(viewController: self, message: Strings.UploadPhoto.AuthErrorAlert.message) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
}

extension UploadPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = assets[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: UploadPhotoCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        cell.bind(asset: asset)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.selectAsset.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return UploadPhotoViewModel.Constant.limitOfPhoto > viewModel.state.selectedAssets.count
    }
}
