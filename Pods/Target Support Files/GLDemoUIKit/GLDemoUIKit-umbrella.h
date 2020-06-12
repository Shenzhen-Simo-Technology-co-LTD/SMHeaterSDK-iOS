#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GLDemoUIKit-Bridging-Header.h"
#import "GLDependencyHeader.h"

FOUNDATION_EXPORT double GLDemoUIKitVersionNumber;
FOUNDATION_EXPORT const unsigned char GLDemoUIKitVersionString[];

