#import <Foundation/Foundation.h>

#import "NMFTypes.h"

NS_ASSUME_NONNULL_BEGIN

// Strings in the SDK targets must be retrieved from the framework bundle rather
// than the main bundle, which is usually the application bundle. Redefining
// these macros ensures that the framework bundle’s string tables are used at
// runtime yet tools like genstrings and Xcode can still find the localizable
// string identifiers. (genstrings has an -s option that would allow us to
// define our own macros, but Xcode’s Export Localization feature lacks support
// for it.)
//
// As a consequence of this approach, this header must be included in all SDK
// files that include localizable strings.


@interface NSBundle (NMFAdditions)

/// Returns the bundle containing the SDK’s classes and Info.plist file.
+ (instancetype)naverMapFrameworkBundle;

+ (nonnull NSString *)naverMapFrameworkVersion;

+ (nullable NSString *)naverMapFrameworkBundleIdentifier;

+ (nullable NSDictionary<NSString *, id> *)naverMapFrameworkInfoDictionary;

+ (nullable NSString *)naverMapApplicationBundleIdentifier;

@property (readonly, copy, nullable) NSString *naverMapFrameworkResourcesDirectory;

@end

static inline NSString* NMFLocalizedString(NSString *key, NSString * _Nullable comment) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [[NSBundle naverMapFrameworkBundle] localizedStringForKey:(key) value:@"" table:nil];
}

static inline NSString* NMFLocalizedStringFromTable(NSString *key, NSString *tbl, NSString * _Nullable comment) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [[NSBundle naverMapFrameworkBundle] localizedStringForKey:(key) value:@"" table:(tbl)];
}

static inline NSString* NMFLocalizedStringWithDefaultValue(NSString *key, NSString * _Nullable tbl, NSBundle * _Nullable bundle, NSString *val, NSString * _Nullable comment) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [[NSBundle naverMapFrameworkBundle] localizedStringForKey:(key) value:(val) table:(tbl)];
}

NS_ASSUME_NONNULL_END
