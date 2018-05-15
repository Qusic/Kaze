#import "Headers.h"

CHDeclareClass(SBReachabilityManager)
CHDeclareClass(SBBacklightController)
CHDeclareClass(SBLockScreenManager)

static void gestureBegan(void) {
    [CHSharedInstance(SBReachabilityManager) deactivateReachabilityModeForObserver:nil];
}

static void gestureChanged(CGPoint position) {
    CGFloat height = KazeSpringBoard().keyWindow.bounds.size.height;
    CGFloat step = MIN((height - position.y) / (height / 2), 1);
    float factor = MIN(MAX(1 - step, 0.01), 1.0);
    BKSHIDServicesSetBacklightFactorWithFadeDuration(factor, 0, NO);
}

static void gestureEnded(CGPoint velocity) {
    BOOL forward = velocity.y <= 0;
    float factor = forward ? 0 : 1;
    static NSTimeInterval const duration = 0.4;
    if (forward) {
        [CHSharedInstance(SBBacklightController) animateBacklightToFactor:factor duration:duration source:SBLockSourcePlugin completion:^(BOOL finished) {
            if (forward) {
                [CHSharedInstance(SBLockScreenManager) lockUIFromSource:SBLockSourcePlugin withOptions:nil];
            }
        }];
    } else {
        BKSHIDServicesSetBacklightFactorWithFadeDuration(factor, duration, NO);
    }
}

static void gestureCancelled(void) {
    BKSHIDServicesSetBacklightFactorWithFadeDuration(1, 0, NO);
}

KazeGestureConditionBlock KazeLockScreenCondition = ^BOOL(KazeGestureRegion region) {
    return [KazePreferencesValue(kHotCornersEnabledKey()) boolValue]
        && ![KazePreferencesValue(kDisableLockGestureKey()) boolValue]
        && region == ([KazePreferencesValue(kInvertHotCornersKey()) boolValue] ? KazeGestureRegionLeft : KazeGestureRegionRight)
        && !KazeDeviceLocked()
        && !KazeSwitcherShowing()
        && !KazeHasFrontmostApplication();
};

KazeGestureHandlerBlock KazeLockScreenHandler = ^void(UIGestureRecognizerState state, CGPoint position, CGPoint velocity) {
    switch (state) {
        case UIGestureRecognizerStateBegan:
            gestureBegan();
            gestureChanged(position);
            break;
        case UIGestureRecognizerStateChanged:
            gestureChanged(position);
            break;
        case UIGestureRecognizerStateEnded:
            gestureEnded(velocity);
            break;
        default:
            gestureCancelled();
            break;
    }
};

CHConstructor {
    @autoreleasepool {
        CHLoadLateClass(SBReachabilityManager);
        CHLoadLateClass(SBBacklightController);
        CHLoadLateClass(SBLockScreenManager);
    }
}
