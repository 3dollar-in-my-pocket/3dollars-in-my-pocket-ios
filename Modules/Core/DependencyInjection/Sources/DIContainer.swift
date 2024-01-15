import Swinject

public final class DIContainer {
    public static let shared = DIContainer()
    
    public var container = Container()
}
