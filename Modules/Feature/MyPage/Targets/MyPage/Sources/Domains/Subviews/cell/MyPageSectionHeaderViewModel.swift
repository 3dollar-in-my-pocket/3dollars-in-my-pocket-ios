import Combine

import Common
import Model
import Networking
import Log

final class MyPageSectionHeaderViewModel: BaseViewModel {
    struct Input {
        let count = CurrentValueSubject<String?, Never>(nil)
        let didTapCountButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let item: MyPageSectionType
        let count = CurrentValueSubject<String?, Never>(nil)
        let didTapCountButton = PassthroughSubject<MyPageSectionType, Never>()
    }
    
    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output

    init(item: MyPageSectionType) {
        self.output = Output(item: item)

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapCountButton
            .withUnretained(self)
            .map { owner, _ in owner.output.item }
            .subscribe(output.didTapCountButton)
            .store(in: &cancellables)
        
        input.count
            .subscribe(output.count)
            .store(in: &cancellables)
    }
}

extension MyPageSectionHeaderViewModel: Hashable {
    static func == (lhs: MyPageSectionHeaderViewModel, rhs: MyPageSectionHeaderViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
