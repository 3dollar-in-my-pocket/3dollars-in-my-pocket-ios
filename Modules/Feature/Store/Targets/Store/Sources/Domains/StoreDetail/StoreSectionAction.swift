import Model

enum StoreSectionAction {
    case custom(SDCustomAction, clickLog: SDClickLog?, cardId: String? = nil)
    case link(SDLink, clickLog: SDClickLog?)
}
