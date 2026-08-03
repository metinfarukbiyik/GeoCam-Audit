#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"dev.biyik.geocam.audit";

/// The "SplashBackground" asset catalog color resource.
static NSString * const ACColorNameSplashBackground AC_SWIFT_PRIVATE = @"SplashBackground";

/// The "SplashLogo" asset catalog image resource.
static NSString * const ACImageNameSplashLogo AC_SWIFT_PRIVATE = @"SplashLogo";

#undef AC_SWIFT_PRIVATE
