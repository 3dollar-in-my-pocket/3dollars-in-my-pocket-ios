import Combine

import Common
import Model

final class RecentSearchAddressCellViewModel: BaseViewModel {
    struct Input {
        let didTapDeleteButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let placeName: String
        let addressName: String?
        let deleteRecentSearch = PassthroughSubject<String, Never>()
    }

    let input = Input()
    let output: Output
    
    private let data: PlaceResponse

    init(data: PlaceResponse) {
        self.data = data
        
        let addressName: String? = {
            return if let roadAddressName = data.roadAddressName, roadAddressName.isNotEmpty {
                roadAddressName
            } else {
                data.addressName
            }
        }()
        
        self.output = Output(
            placeName: data.placeName,
            addressName: addressName
        )
        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapDeleteButton
            .withUnretained(self)
            .sink { owner, _ in
                owner.output.deleteRecentSearch.send(owner.data.placeId)
            }
            .store(in: &cancellables)
    }
}

extension RecentSearchAddressCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension RecentSearchAddressCellViewModel: Hashable {
    static func == (lhs: RecentSearchAddressCellViewModel, rhs: RecentSearchAddressCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
