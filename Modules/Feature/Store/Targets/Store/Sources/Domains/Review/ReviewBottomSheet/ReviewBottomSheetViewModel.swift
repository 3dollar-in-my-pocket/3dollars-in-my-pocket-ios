import Foundation
import Combine

import Common
import DesignSystem
import Model
import Networking
import Log

final class ReviewBottomSheetViewModel: BaseViewModel {
    enum Constant {
        static let maxPhotoCount = 10
        static let defaultImageLength = 500
    }
    
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didTapRating = PassthroughSubject<Int, Never>()
        let inputReview = PassthroughSubject<String, Never>()
        let didTapWrite = PassthroughSubject<Void, Never>()
        let didTapUploadPhoto = PassthroughSubject<Void, Never>()
        let removeImage = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .reviewBottomSheet
        let rating: CurrentValueSubject<Int?, Never>
        let contents: CurrentValueSubject<String?, Never>
        let isEnableWriteButton: CurrentValueSubject<Bool, Never>
        let images: CurrentValueSubject<[ImageResponse], Never>
        let onSuccessWriteReview = PassthroughSubject<StoreDetailReview, Never>()
        let onSuccessEditReview = PassthroughSubject<StoreReviewResponse, Never>()
        let errorAlert = PassthroughSubject<Error, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var rating: Int?
        var contents: String?
        var nonceToken: String?
    }
    
    enum Route {
        case dismiss
        case uploadPhoto(UploadPhotoViewModel)
    }
    
    struct Config {
        let storeId: Int
        let review: StoreDetailReview?
    }
    
    let input = Input()
    let output: Output
    private let storeService: StoreRepository
    private let commonRepository: CommonRepository
    private let logManager: LogManagerProtocol
    private let config: Config
    private var state: State
    
    init(
        config: Config,
        storeService: StoreRepository = StoreRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared,
        commonRepository: CommonRepository = CommonRepositoryImpl()
    ) {
        self.config = config
        self.storeService = storeService
        self.logManager = logManager
        self.commonRepository = commonRepository
        
        let isEnableWriteButton = (config.review?.contents != nil) && (config.review?.rating != nil)
        self.output = Output(
            rating: .init(config.review?.rating),
            contents: .init(config.review?.contents),
            isEnableWriteButton: .init(isEnableWriteButton),
            images: .init(config.review?.images ?? [])
        )
        self.state = State(rating: config.review?.rating, contents: config.review?.contents)
    }
    
    override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, _) in
                owner.createNonceToken()
            }
            .store(in: &cancellables)
        
        input.didTapRating
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, rating: Int) in
                owner.state.rating = rating
                owner.output.isEnableWriteButton.send(owner.isEnableWriteButton())
            }
            .store(in: &cancellables)
        
        input.inputReview
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, contents: String) in
                owner.state.contents = contents
                owner.output.isEnableWriteButton.send(owner.isEnableWriteButton())
            }
            .store(in: &cancellables)
        
        input.didTapWrite
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, _) in
                if let _ = owner.config.review?.reviewId {
                    owner.editReview()
                } else {
                    owner.writeReview()
                }
                owner.sendClickWriteReview()
            }
            .store(in: &cancellables)
        
        input.didTapUploadPhoto
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, _) in
                owner.presentUploadPhoto()
            }
            .store(in: &cancellables)
        
        input.removeImage
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, index: Int) in
                var images = owner.output.images.value
                guard images.indices.contains(index) else { return }
                images.remove(at: index)
                owner.output.images.send(images)
            }
            .store(in: &cancellables)
    }
    
    private func presentUploadPhoto() {
        let limitOfPhoto = Constant.maxPhotoCount - output.images.value.count
        guard limitOfPhoto > 0 else {
            output.showToast.send(Strings.ReviewBottomSheet.photoLimit)
            return
        }
        
        let viewModel = UploadPhotoViewModel(config: .init(uploadType: .reviewImage(limitOfPhoto: limitOfPhoto)))
        viewModel.output.onSuccessUploadImages
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, uploadedImages: [ImageUploadResponse]) in
                let images = uploadedImages.map {
                    ImageResponse(imageUrl: $0.imageUrl, width: $0.width, height: $0.height)
                }
                owner.output.images.send(owner.output.images.value + images)
            }
            .store(in: &viewModel.cancellables)
        output.route.send(.uploadPhoto(viewModel))
    }
    
    private var requestImages: [WriteReviewRequestInput.Image] {
        output.images.value.map {
            WriteReviewRequestInput.Image(
                url: $0.imageUrl,
                width: $0.width ?? Constant.defaultImageLength,
                height: $0.height ?? Constant.defaultImageLength
            )
        }
    }
    
    private func isEnableWriteButton() -> Bool {
        guard let _ = state.rating,
              let contents = state.contents else { return false }
        
        return contents.isNotEmpty
    }
    
    private func writeReview() {
        guard let rating = state.rating,
              let contents = state.contents else { return }
        
        Task {
            guard let nonceToken = await nonceToken() else { return }
            let input = WriteReviewRequestInput(
                storeId: config.storeId,
                contents: contents,
                rating: rating,
                nonceToken: nonceToken,
                images: requestImages,
                feedbacks: []
            )
            
            output.showLoading.send(true)
            let result = await storeService.writeReview(input: input)
            output.showLoading.send(false)
            
            switch result {
            case .success(let response):
                let storeDetailReview = StoreDetailReview(response: response)
                output.onSuccessWriteReview.send(storeDetailReview)
                output.route.send(.dismiss)
                
            case .failure(let error):
                output.errorAlert.send(error)
            }
        }
    }
    
    private func editReview() {
        guard let reviewId = config.review?.reviewId,
              let rating = state.rating,
              let contents = state.contents else { return }
        
        Task {
            guard let nonceToken = await nonceToken() else { return }
            let input = EditReviewRequestInput(
                contents: contents,
                rating: rating,
                nonceToken: nonceToken,
                images: requestImages
            )
            output.showLoading.send(true)
            let result = await storeService.editReview(reviewId: reviewId, input: input)
            output.showLoading.send(false)
            
            switch result {
            case .success(let response):
                output.onSuccessEditReview.send(response)
                output.route.send(.dismiss)
                
            case .failure(let error):
                output.errorAlert.send(error)
            }
        }
    }
    
    private func createNonceToken() {
        Task {
            _ = await nonceToken()
        }
    }
    
    private func nonceToken() async -> String? {
        if let nonceToken = state.nonceToken {
            return nonceToken
        }
        
        switch await commonRepository.createNonceToken() {
        case .success(let response):
            state.nonceToken = response.nonce
            return response.nonce
        case .failure(let error):
            output.errorAlert.send(error)
            return nil
        }
    }
}

// MARK: Log
extension ReviewBottomSheetViewModel {
    private func sendClickWriteReview() {
        guard let rating = state.rating else { return }
        
        logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .writeReview,
            extraParameters: [
                .value: rating
            ]
        ))
    }
}
