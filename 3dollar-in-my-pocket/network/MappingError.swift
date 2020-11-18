struct MappingError: Error, CustomStringConvertible {

    let description: String

    init(from: Any?, to: Any.Type) {
        self.description = "Failed to map \(from) to \(to)"
    }

    init(from: Any?, to: [Any.Type]) {
        self.description = "Failed to map \(from) to \(to)"
    }
    
    init(desc: String) {
        self.description = desc
    }
}
