#import "FLEX/FLEXManager.h"
#import <libactivator/libactivator.h>
#import <CoreFoundation/CoreFoundation.h>

@interface UIApplication (Private)
-(id)displayIdentifier;
+(id)displayIdentifier; // iOS 10
@end

@interface SBApplication
- (NSString *)bundleIdentifier;
@end

@interface SpringBoard : UIApplication
- (SBApplication *)_accessibilityFrontMostApplication;
@end

@interface ReFLEXActivatorListener : NSObject <LAListener>
@end

@implementation ReFLEXActivatorListener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName{

    NSString *frontmostAppID = [[(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication] bundleIdentifier];
    HBLogInfo(@"frontmostAppID: %@", frontmostAppID);

    if([listenerName isEqualToString:@"com.leftyfl1p.reflex.show"] ){
        if(frontmostAppID) {
            NSString *reFLEXShowNotificationName = [NSString stringWithFormat:@"%@reFLEXShow", frontmostAppID];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)reFLEXShowNotificationName, NULL, NULL, YES);
            [event setHandled:YES];

        } else {
            [[FLEXManager sharedManager] showExplorer];
            [event setHandled:YES];
        }
        
    }

    else { 
        [event setHandled:NO];
    }
}

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Show FLEX";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Show the FLEX toolbar.";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"reFLEX";
}

@end

void reFLEXShow(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[FLEXManager sharedManager] showExplorer];
}

%hook UIApplication

-(id)init {
    NSString *displayID = nil;
    if([[UIApplication sharedApplication] respondsToSelector:@selector(displayIdentifier)]) {
        displayID = [[UIApplication sharedApplication] displayIdentifier];
    } else {
        // iOS 10... .2?
        displayID = [UIApplication displayIdentifier];
    }

    // Register Activator handlers in SpringBoard
    if ([displayID isEqualToString:@"com.apple.springboard"]) {
        ReFLEXActivatorListener *listener = [[ReFLEXActivatorListener alloc] init];
        [[LAActivator sharedInstance] registerListener:listener forName:@"com.leftyfl1p.reflex.show"];
    } else {
        NSString *reFLEXShowNotificationName = [NSString stringWithFormat:@"%@reFLEXShow", displayID];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), (CFNotificationCallback)reFLEXShow, (CFStringRef)reFLEXShowNotificationName, NULL, CFNotificationSuspensionBehaviorDrop);
    }

    return %orig;
}



%end
