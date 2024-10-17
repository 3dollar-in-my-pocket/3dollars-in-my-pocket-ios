import Combine

import Common
import Networking
import Model
import Log
import MembershipInterface

final class AccountInfoViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didTapBirthday = PassthroughSubject<Void, Never>()
        let didSelectYear = PassthroughSubject<Int, Never>()
        let didTapGender = PassthroughSubject<Void, Never>()
        let didTapSave = PassthroughSubject<Void, Never>()
        let didTapLater = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .accountInfo
        let showDescription = PassthroughSubject<Void, Never>()
        let nickname = PassthroughSubject<String, Never>()
        let birthdayYear = PassthroughSubject<Int?, Never>()
        let gender = PassthroughSubject<Gender?, Never>()
        let isEnableSaveButton = PassthroughSubject<Bool, Never>()
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var user: UserDetailResponse?
    }
    
    enum Route {
        case back
        case dismiss
        case showYearPicker(BirthdayYearBottomSheetViewModel)
        case presentNeedLoginAlert
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let userRepository: UserRepository
        var preference: Preference
        
        init(
            userRepository: UserRepository = UserRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.userRepository = userRepository
            self.preference = preference
        }
    }
    
    let input = Input()
    let output = Output()
    let config: AccountInfoViewModelConfig
    private var dependency: Dependency
    private var state = State()
    
    init(config: AccountInfoViewModelConfig, dependency: Dependency = Dependency()) {
        self.dependency = dependency
        self.config = config
        super.init()
    }
    
    override func bind() {
        input.firstLoad
            .withUnretained(self)
            .sink { (owner: AccountInfoViewModel, _) in
                if owner.dependency.preference.isAnonymousUser {
                    owner.output.route.send(.presentNeedLoginAlert)
                } else {
                    owner.loadUser()
                }
            }
            .store(in: &cancellables)
        
        input.didTapBirthday
            .withUnretained(self)
            .sink { (owner: AccountInfoViewModel, _) in
                owner.showYearPicker()
            }
            .store(in: &cancellables)
        
        input.didSelectYear
            .withUnretained(self)
            .sink { (owner: AccountInfoViewModel, year: Int) in
                owner.state.user?.birth = UserBirthResponse(year: year)
                owner.output.birthdayYear.send(year)
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.didTapGender
            .withUnretained(self)
            .sink { (owner: AccountInfoViewModel, _) in
                owner.toggleGender()
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.didTapSave
            .withUnretained(self)
            .sink { (owner: AccountInfoViewModel, _) in
                owner.updateUser()
            }
            .store(in: &cancellables)
        
        input.didTapLater
            .withUnretained(self)
            .sink { (owner: AccountInfoViewModel, _) in
                owner.output.route.send(.dismiss)
            }
            .store(in: &cancellables)
    }
    
    private func loadUser() {
        Task {
            let result = await dependency.userRepository.fetchUser()
            
            switch result {
            case .success(let user):
                state.user = user
                output.birthdayYear.send(user.birth?.year)
                output.gender.send(user.gender)
                output.nickname.send(user.name)
                
                if isValidInfo(user: user).isNot {
                    output.showDescription.send(())
                }
                updateSaveButtonEnable()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func showYearPicker() {
        let year = state.user?.birth?.year
        let config = BirthdayYearBottomSheetViewModel.Config(birthdayYear: year)
        let viewModel = BirthdayYearBottomSheetViewModel(config: config)
        
        viewModel.output.didSelectYear
            .subscribe(input.didSelectYear)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.showYearPicker(viewModel))
    }
    
    private func toggleGender() {
        if let gender = state.user?.gender {
            state.user?.gender = gender.toggled
        } else {
            state.user?.gender = .male
        }
        output.gender.send(state.user?.gender)
    }
    
    private func updateUser() {
        guard let user = state.user,
              let gender = user.gender,
              let year = user.birth?.year else { return }
        
        Task {
            let birthRequest = UserBirthRequest(year: year)
            let input = UserPatchRequestInput(gender: gender, birth: birthRequest)
            let result = await dependency.userRepository.editUser(input: input)
            
            switch result {
            case .success:
                if config.shouldPush {
                    output.route.send(.back)
                } else {
                    output.route.send(.dismiss)
                }
                output.toast.send(Strings.AccountInfo.SuccessToast.message)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func isValidInfo(user: UserDetailResponse) -> Bool {
        return user.gender.isNotNil && user.birth.isNotNil
    }
    
    private func updateSaveButtonEnable() {
        if let user = state.user {
            output.isEnableSaveButton.send(isValidInfo(user: user))
        } else {
            output.isEnableSaveButton.send(false)
        }
    }
}

extension Gender {
    var toggled: Gender {
        switch self {
        case .male:
            return .female
        case .female:
            return .male
        }
    }
}
