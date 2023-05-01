enum OpenStatus {
    case open
    case closed
    
    init(response: OpenStatusResponse) {
        switch response {
        case .closed:
            self = .closed
            
        case .open:
            self = .open
        }
    }
}
