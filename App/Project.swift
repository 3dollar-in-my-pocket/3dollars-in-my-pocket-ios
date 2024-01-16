import ProjectDescription
import ProjectDescriptionHelpers

struct BuildSetting {
    struct Project {
        static let base: SettingsDictionary = [
            "ALWAYS_SEARCH_USER_PATHS": "NO",
            "CLANG_ANALYZER_NONNULL": "YES",
            "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
            "CLANG_CXX_LANGUAGE_STANDARD": "gnu++14",
            "CLANG_CXX_LIBRARY": "libc++",
            "CLANG_ENABLE_MODULES": "YES",
            "CLANG_ENABLE_OBJC_ARC": "YES",
            "CLANG_ENABLE_OBJC_WEAK": "YES",
            "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
            "CLANG_WARN_BOOL_CONVERSION": "YES",
            "CLANG_WARN_COMMA": "YES",
            "CLANG_WARN_CONSTANT_CONVERSION": "YES",
            "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": "YES",
            "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
            "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
            "CLANG_WARN_EMPTY_BODY": "YES",
            "CLANG_WARN_ENUM_CONVERSION": "YES",
            "CLANG_WARN_INFINITE_RECURSION": "YES",
            "CLANG_WARN_INT_CONVERSION": "YES",
            "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
            "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": "YES",
            "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
            "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
            "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
            "CLANG_WARN_STRICT_PROTOTYPES": "YES",
            "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
            "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
            "CLANG_WARN_UNREACHABLE_CODE": "YES",
            "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
            "COPY_PHASE_STRIP": "NO",
            "ENABLE_STRICT_OBJC_MSGSEND": "YES",
            "GCC_C_LANGUAGE_STANDARD": "gnu11",
            "GCC_NO_COMMON_BLOCKS": "YES",
            "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
            "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
            "GCC_WARN_UNDECLARED_SELECTOR": "YES",
            "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
            "GCC_WARN_UNUSED_FUNCTION": "YES",
            "GCC_WARN_UNUSED_VARIABLE": "YES",
            "IPHONEOS_DEPLOYMENT_TARGET": "14.0",
            "MTL_FAST_MATH": "YES",
            "SDKROOT": "iphoneos",
        ]
        
        static let debug: SettingsDictionary = [
            "DEBUG_INFORMATION_FORMAT": "dwarf",
            "ENABLE_TESTABILITY": "YES",
            "GCC_DYNAMIC_NO_PIC" :"NO",
            "GCC_OPTIMIZATION_LEVEL": "0",
            "GCC_PREPROCESSOR_DEFINITIONS": "DEBUG=1 $(inherited)",
            "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
            "ONLY_ACTIVE_ARCH": "YES",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
            "SWIFT_OPTIMIZATION_LEVEL": "-Onone"
        ]
        
        static let release: SettingsDictionary = [
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "ENABLE_NS_ASSERTIONS": "NO",
            "MTL_ENABLE_DEBUG_INFO": "NO",
            "SWIFT_COMPILATION_MODE": "wholemodule",
            "SWIFT_OPTIMIZATION_LEVEL": "-O",
            "VALIDATE_PRODUCT": "YES"
        ]
    }
    
    struct App {
        static let base: SettingsDictionary = [
            "MARKETING_VERSION": DefaultSetting.appVersion,
            "CURRENT_PROJECT_VERSION": DefaultSetting.buildNumber,
            "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES": "YES",
            "APPSTORE_ID": "1496099467",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "CODE_SIGN_IDENTITY[sdk=iphoneos*]": "iPhone Developer",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "",
            "DEVELOPMENT_TEAM[sdk=iphoneos*]": "X975A2HM62",
            "DYNAMICLINK_HOST": "https://link.threedollars.co.kr",
            "ENABLE_BITCODE": "NO",
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1",
            "URL_MARKETING": "https://massive-iguana-121.notion.site/3-91156528267e426b9609d3ed57acb27d",
            "URL_POLICY": "https://massive-iguana-121.notion.site/3-37f521af4ac842ccba75a4fb590c506d",
            "URL_PRIVACY": "https://www.notion.so/3-3d0a9c55ddd74086b63582c308ca285e",
            "FRAMEWORK_SEARCH_PATHS": "$(inherited) $(PROJECT_DIR)",
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks",
            "OTHER_LDFLAGS": "$(inherited) -framework 'Accelerate' -framework 'CFNetwork'",
        ]
        
        static let debug: SettingsDictionary = [
            "ADMOB_UNIT_ID": "ca-app-pub-3940256099942544/2934735716",
            "ANDROID_PACKAGE_NAME": "com.zion830.threedollars.dev",
            "API_URL": "https://dev.threedollars.co.kr",
            "APP_DISPLAY_NAME": "가슴속3천원-Dev",
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "DEEP_LINK_SCHEME": "dollars-dev",
            "DYNAMIC_LINK_URL": "https://3dollarsdev.page.link",
            "KAKAO_APP_KEY": "95f91f9656806e132796f0071ab99aaa",
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket-debug",
            "PRODUCT_MODULE_NAME": "dollar_in_my_pocket",
            "PRODUCT_NAME": "dollar-in-my-pocket-debug",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-dev",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon-Dev"
        ]
        
        static let release: SettingsDictionary = [
            "ADMOB_UNIT_ID": "ca-app-pub-1527951560812478/3327283605",
            "ANDROID_PACKAGE_NAME": "com.zion830.threedollars",
            "API_URL": "https://threedollars.co.kr",
            "APP_DISPLAY_NAME": "가슴속3천원",
            "DEEP_LINK_SCHEME": "dollars",
            "DYNAMIC_LINK_URL": "https://3dollars.page.link",
            "KAKAO_APP_KEY": "a0ce3cecac62e2dedf50751d5abc5740",
            "ONLY_ACTIVE_ARCH": "YES",
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket",
            "PRODUCT_NAME": "dollar-in-my-pocket",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-prod",
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon"
        ]
    }
    
    struct AppTest {
        static let base: SettingsDictionary = [
            "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES": "YES",
            "BUNDLE_LOADER": "$(TEST_HOST)",
            "CODE_SIGN_STYLE": "Automatic",
            "DEVELOPMENT_TEAM": "X975A2HM62",
            "PRODUCT_NAME": "$(TARGET_NAME)",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1,2",
            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/dollar-in-my-pocket-debug.app/dollar-in-my-pocket-debug"
        ]
        
        static let debug: SettingsDictionary = [
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
        ]
        
        static let release: SettingsDictionary = [
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"
        ]
    }
    
    struct ServiceExtension {
        static let base: SettingsDictionary = [
            "MARKETING_VERSION": DefaultSetting.appVersion,
            "CURRENT_PROJECT_VERSION": DefaultSetting.buildNumber,
            "CLANG_CXX_LANGUAGE_STANDARD": "gnu++17",
            "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "CODE_SIGN_IDENTITY[sdk=iphoneos*]": "iPhone Developer",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "",
            "DEVELOPMENT_TEAM[sdk=iphoneos*]": "X975A2HM62",
            "GENERATE_INFOPLIST_FILE": "YES",
            "INFOPLIST_KEY_CFBundleDisplayName": "service-extension",
            "INFOPLIST_KEY_NSHumanReadableCopyright": "Copyright © 2022 Macgongmon. All rights reserved.",
            "PRODUCT_NAME": "$(TARGET_NAME)",
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "SKIP_INSTALL": "YES",
            "SWIFT_EMIT_LOC_STRINGS": "YES",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1",
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks"
        ]
        
        static let debug: SettingsDictionary = [
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket-debug.service-extension",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-service-extension-dev"
        ]
        
        static let release: SettingsDictionary = [
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket.service-extension",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-service-extension-prod"
        ]
    }
    
    struct ContentExtension {
        static let base: SettingsDictionary = [
            "MARKETING_VERSION": DefaultSetting.appVersion,
            "CURRENT_PROJECT_VERSION": DefaultSetting.buildNumber,
            "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "CODE_SIGN_IDENTITY[sdk=iphoneos*]": "iPhone Developer",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "",
            "DEVELOPMENT_TEAM[sdk=iphoneos*]": "X975A2HM62",
            "PRODUCT_NAME": "$(TARGET_NAME)",
            "PROVISIONING_PROFILE_SPECIFIER": "",
            "SKIP_INSTALL": "YES",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1,2",
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks"
        ]
        
        static let debug: SettingsDictionary = [
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket-debug.content-extension",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-content-extension-dev"
        ]
        
        static let release: SettingsDictionary = [
            "PRODUCT_BUNDLE_IDENTIFIER": "com.macgongmon.-dollar-in-my-pocket.content-extension",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "development-user-content-extension-prod"
        ]
    }
}

struct Script {
    static let googleService = """
    # Type a script or drag a script file from your workspace to insert its path.
    case "${CONFIGURATION}" in
        "Debug" )
    cp -r "$SRCROOT/Targets/three-dollar-in-my-pocket/Config/firebase/GoogleService-Info-Dev.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" ;;
          "Release" )
    cp -r "$SRCROOT/Targets/three-dollar-in-my-pocket/Config/firebase/GoogleService-Info-Prod.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" ;;
    *)
    ;;
    esac
    """
    
    static let firebaseCrashlytics = "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
}

// MARK: - Project
let project = Project(
    name: "3dollar-in-my-pocket",
    organizationName: "macgongmon",
    packages: [
        .reactorKit,
        .kakaoSDK,
        .rxSwift,
        .rxDataSources,
        .swiftyBeaver,
        .deviceKit,
        .permissionsKit,
        .firebaseSDK
    ],
    settings: .settings(
        base: BuildSetting.Project.base,
        configurations: [
            .debug(name: .debug, settings: BuildSetting.Project.debug),
            .release(name: .release, settings: BuildSetting.Project.release)
        ]),
    targets: [
        Target(
            name: "three-dollar-in-my-pocket",
            platform: .iOS,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: .iphone),
            infoPlist: "Targets/three-dollar-in-my-pocket/Info.plist",
            sources: ["Targets/three-dollar-in-my-pocket/Sources/**"],
            resources: ["Targets/three-dollar-in-my-pocket/Resources/**"],
            entitlements: .relativeToManifest("Targets/three-dollar-in-my-pocket/three-dollar-in-my-pocket.entitlements"),
            scripts: [
                .pre(script: Script.googleService, name: "GoogleService Info"),
                .post(script: Script.firebaseCrashlytics, name: "FirebaseCrashlytics", inputPaths: [
                    .relativeToManifest("${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}"),
                    .relativeToManifest("$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)")
                ])
            ],
            dependencies: [
                .Core.networking,
                .Core.common,
                .Core.dependencyInjection,
                .Core.designSystem,
                .Interface.appInterface,
                .Interface.storeInterface,
                .Interface.writeInterface,
                .Interface.communityInterface,
                .Feature.home,
                .Feature.community,
                .Feature.membership,
                .Feature.store,
                .Feature.write,
                .Feature.myPage,
                .SPM.snapKit,
                .SPM.then,
                .SPM.kingfisher,
                .SPM.lottie,
                .Package.cameraPermission,
                .Package.deviceKit,
                .Package.firebaseAnalytics,
                .Package.firebaseCrashlytics,
                .Package.firebaseDynamicLinks,
                .Package.firebaseFirestore,
                .Package.firebaseMessaging,
                .Package.firebaseRemoteConfig,
                .Package.kakaoSDK,
                .Package.kakaoSDKAuth,
                .Package.kakaoSDKCommon,
                .Package.kakaoSDKShare,
                .Package.kakaoSDKTalk,
                .Package.kakaoSDKTemplate,
                .Package.kakaoSDKUser,
                .Package.locationAlwaysPermission,
                .Package.locationWhenInUsePermission,
                .Package.photoLibraryPermission,
                .Package.reactorKit,
                .Package.rxCocoa,
                .Package.rxDataSources,
                .Package.rxRelay,
                .Package.rxSwift,
                .Package.swiftyBeaver,
                .target(name: "service-extension"),
                .target(name: "content-extension"),
            ],
            settings: .settings(
                base: BuildSetting.App.base,
                configurations: [
                    .debug(name: .debug, settings: BuildSetting.App.debug),
                    .release(name: .release, settings: BuildSetting.App.release)
                ])
        ),
        Target(
            name: "three-dollar-in-my-pocketTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.macgongmon.-dollar-in-my-pocketTests",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: .iphone),
            infoPlist: "Targets/three-dollar-in-my-pocketTests/Info.plist",
            sources: ["Targets/three-dollar-in-my-pocketTests/Sources/**"],
            resources: ["Targets/three-dollar-in-my-pocketTests/Resources/**"],
            dependencies: [
                .target(name: "three-dollar-in-my-pocket"),
                .Package.rxRelay,
                .Package.rxTest,
                .Package.rxBlocking,
                .Package.rxCocoa,
                .Package.rxSwift
            ],
            settings: .settings(
                base: BuildSetting.AppTest.base,
                configurations: [
                    .debug(name: .debug, settings: BuildSetting.AppTest.debug),
                    .release(name: .release, settings: BuildSetting.AppTest.release)
                ])
        ),
        Target(
            name: "service-extension",
            platform: .iOS,
            product: .appExtension,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: .iphone),
            infoPlist: "Targets/service-extension/Info.plist",
            sources: ["Targets/service-extension/Sources/**"],
            dependencies: [],
            settings: .settings(
                base: BuildSetting.ServiceExtension.base,
                configurations: [
                    .debug(name: .debug, settings: BuildSetting.ServiceExtension.debug),
                    .release(name: .release, settings: BuildSetting.ServiceExtension.release)
                ])
        ),
        Target(
            name: "content-extension",
            platform: .iOS,
            product: .appExtension,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            infoPlist: "Targets/content-extension/Info.plist",
            sources: ["Targets/content-extension/Sources/**"],
            resources: ["Targets/content-extension/Resources/**"],
            dependencies: [
                .sdk(name: "UserNotifications", type: .framework, status: .optional),
                .sdk(name: "UserNotificationsUI", type: .framework, status: .optional)
            ],
            settings: .settings(
                base: BuildSetting.ContentExtension.base,
                configurations: [
                    .debug(name: .debug, settings: BuildSetting.ContentExtension.debug),
                    .release(name: .release, settings: BuildSetting.ContentExtension.release)
                ])
        ),
        Target(
            name: "AppInterface",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.app-interface",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/AppInterface/Sources/**"],
            dependencies: [
                .Core.dependencyInjection
            ]
        )
    ],
    schemes: [
        Scheme(
            name: "three-dollar-in-my-pocket-debug",
            buildAction: BuildAction(targets: ["three-dollar-in-my-pocket"]),
            runAction: .runAction(
                configuration: .debug,
                attachDebugger: true,
                arguments: Arguments(launchArguments: [LaunchArgument(name: "-FIRDebugEnabled", isEnabled: true)])
            ),
            archiveAction: .archiveAction(configuration: .debug)
        ),
        Scheme(
            name: "three-dollar-in-my-pocket",
            buildAction: BuildAction(targets: ["three-dollar-in-my-pocket"]),
            runAction: .runAction(
                configuration: .release,
                attachDebugger: true
            )
        ),
        Scheme(
            name: "three-dollar-in-my-pocketTests",
            buildAction: BuildAction(targets: ["three-dollar-in-my-pocketTests"]),
            testAction: .targets(["three-dollar-in-my-pocketTests"]),
            runAction: .runAction(
                configuration: .debug,
                attachDebugger: false
            )
        ),
        Scheme(
            name: "content-extension",
            buildAction: BuildAction(targets: ["content-extension", "three-dollar-in-my-pocket"])
        ),
        Scheme(
            name: "service-extension",
            buildAction: BuildAction(targets: ["service-extension", "three-dollar-in-my-pocket"])
        )
    ]
)
