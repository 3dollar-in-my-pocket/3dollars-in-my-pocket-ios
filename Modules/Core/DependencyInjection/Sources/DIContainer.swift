import Swinject

public final class DIContainer {
    public static let shared = DIContainer()

    public let container = Container()
    public let resolver: Resolver

    private init() {
        resolver = container.synchronize()
    }
}
