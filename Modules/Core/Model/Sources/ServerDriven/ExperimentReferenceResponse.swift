public struct ExperimentReferenceResponse: Decodable, Hashable {
    public let type: String
    public let experimentKey: String
    public let variant: String
}
