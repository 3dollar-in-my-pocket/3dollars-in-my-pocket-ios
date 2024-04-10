import Combine

import Common
import Model

final class RecentSearchAddressCellViewModel: BaseViewModel {
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
