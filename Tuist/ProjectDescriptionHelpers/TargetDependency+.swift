import ProjectDescription

public extension TargetDependency {
    class Core {
        public static let dependencyInjection = TargetDependency.project(
            target: "DependencyInjection",
            path: .relativeToRoot("./Modules/DependencyInjection")
        )
        
        public static let networking = TargetDependency.project(
            target: "Networking",
            path: .relativeToRoot("./Modules/Network")
        )
        
        public static let designSystem = TargetDependency.project(
            target: "DesignSystem",
            path: .relativeToRoot("./Modules/DesignSystem")
        )
        
        public static let common = TargetDependency.project(
            target: "Common",
            path: .relativeToRoot("./Modules/Core/Common")
        )
        
        public static let model = TargetDependency.project(
            target: "Model",
            path: .relativeToRoot("./Modules/Core/Model")
        )
        
        public static let log = TargetDependency.project(
            target: "Log",
            path: .relativeToRoot("./Modules/Log")
        )
        
        public static let resource = TargetDependency.project(
            target: "Resource",
            path: .relativeToRoot("./Modules/Core/Resource")
        )
    }
    
    class Feature {
        public static let home = TargetDependency.project(
            target: "Home",
            path: .relativeToRoot("./Modules/Feature/Home")
        )
    }
    
    class Interface {
        public static let appInterface = TargetDependency.project(
            target: "AppInterface",
            path: .relativeToRoot("./App")
        )
        
        public static let storeInterface = TargetDependency.project(
            target: "StoreInterface",
            path: .relativeToRoot("./Modules/Feature/Store")
        )
        
        public static let membershipInterface = TargetDependency.project(
            target: "MembershipInterface",
            path: .relativeToRoot("./Modules/Feature/Membership")
        )
        
        public static let writeInterface = TargetDependency.project(
            target: "WriteInterface",
            path: .relativeToRoot("./Modules/Feature/Write")
        )
    }
    
    class SPM {
        public static let lottie = TargetDependency.external(name: "Lottie")
        public static let swinject = TargetDependency.external(name: "Swinject")
        public static let kingfisher = TargetDependency.external(name: "Kingfisher")
    }
}
