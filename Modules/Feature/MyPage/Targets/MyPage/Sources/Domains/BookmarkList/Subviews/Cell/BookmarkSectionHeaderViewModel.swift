import Foundation
import Combine

import Common

final class BookmarkSectionHeaderViewModel: BaseViewModel {
    struct Input {
        let didTapDeleteMode = PassthroughSubject<Void, Never>()
        let didTapDeleteAll = PassthroughSubject<Void, Never>()
        let didTapFinish = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let totalCount: CurrentValueSubject<Int?, Never>
        let isDeleteMode: CurrentValueSubject<Bool, Never>
        
        // For Relay
        let didTapDeleteAll = PassthroughSubject<Void, Never>()
        let didTapFinish = PassthroughSubject<Void, Never>()
    }
    
    struct Config {
        let totalCount: Int
        let isDeleteMode: Bool
    }
    
    let input = Input()
    let output: Output
    
    init(config: Config) {
        output = Output(
            totalCount: .init(config.totalCount),
            isDeleteMode: .init(config.isDeleteMode)
        )
        
        super.init()
    }
    
    override func bind() {
        input.didTapDeleteMode
            .withUnretained(self)
            .sink { (owner: BookmarkSectionHeaderViewModel, _) in
                owner.output.isDeleteMode.send(true)
            }
            .store(in: &cancellables)
        
        input.didTapDeleteAll
            .subscribe(output.didTapDeleteAll)
            .store(in: &cancellables)
        
        input.didTapFinish
            .withUnretained(self)
            .sink(receiveValue: { (owner: BookmarkSectionHeaderViewModel, _) in
                owner.output.isDeleteMode.send(false)
            })
            .store(in: &cancellables)
    }
}

extension BookmarkSectionHeaderViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BookmarkSectionHeaderViewModel: Hashable {
    static func == (lhs: BookmarkSectionHeaderViewModel, rhs: BookmarkSectionHeaderViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
