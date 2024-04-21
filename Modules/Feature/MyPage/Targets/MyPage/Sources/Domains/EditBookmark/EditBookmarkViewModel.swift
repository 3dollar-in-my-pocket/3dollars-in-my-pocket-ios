import Foundation
import Combine

import Common
import Model
import Networking
import Log

final class EditBookmarkViewModel: BaseViewModel {
    struct Input {
        let inputTitle = PassthroughSubject<String, Never>()
        let inputDescription = PassthroughSubject<String, Never>()
        let didTapSave = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .editBookmarkList
        let isEnableSaveButton = CurrentValueSubject<Bool, Never>(true)
        let title: CurrentValueSubject<String, Never>
        let description: CurrentValueSubject<String, Never>
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let isLoading = PassthroughSubject<Bool, Never>()
    }
    
    struct State {
        var title: String
        var description: String
    }
    
    struct Relay {
        let onUpdateFolder = PassthroughSubject<(title: String, description: String), Never>()
    }
    
    enum Route {
        case pop
    }
    
    struct Config {
        let title: String
        let description: String
    }
    
    let input = Input()
    let output: Output
    let relay = Relay()
    private var state: State
    private let bookmarkService: BookmarkServiceProtocol
    
    init(
        config: Config,
        bookmarkService: BookmarkServiceProtocol = BookmarkService()
    ) {
        self.output = Output(
            title: .init(config.title),
            description: .init(config.description)
        )
        self.state = State(title: config.title, description: config.description)
        self.bookmarkService = bookmarkService
    }
    
    override func bind() {
        input.inputTitle
            .withUnretained(self)
            .sink { (owner: EditBookmarkViewModel, title: String) in
                let isEnableSaveButton = owner.isSaveButtonEnable(title: title)
                
                owner.output.isEnableSaveButton.send(isEnableSaveButton)
                owner.state.title = title
            }
            .store(in: &cancellables)
        
        input.inputDescription
            .withUnretained(self)
            .sink(receiveValue: { (owner: EditBookmarkViewModel, description: String) in
                owner.state.description = description
            })
            .store(in: &cancellables)
        
        input.didTapSave
            .withUnretained(self)
            .sink { (owner: EditBookmarkViewModel, _) in
                owner.editBookmark()
            }
            .store(in: &cancellables)
    }
    
    private func isSaveButtonEnable(title: String) -> Bool {
        return title.isNotEmpty
    }
    
    private func editBookmark() {
        output.isLoading.send(true)
        let title = state.title
        let description = state.description
        let input = EditBookmarkFolderInput(name: title, introduction: description)
        
        Task { [weak self] in
            guard let self else { return }
            let result = await bookmarkService.editBookmarkFolder(input: input)
            
            switch result {
            case .success(_):
                relay.onUpdateFolder.send((title: title, description: description))
                output.toast.send("즐겨찾기가 수정되었습니다.")
                output.route.send(.pop)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
            output.isLoading.send(false)
        }
    }
}
