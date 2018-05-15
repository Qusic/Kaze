#import "Headers.h"

#define StaticValue(type, code) ({ \
    static type value; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        value = ({ code; }); \
    }); \
    value; \
})

static BOOL switcherLock;

CHDeclareClass(SBWorkspace)
CHDeclareClass(SBUIController)
CHDeclareClass(SBMainSwitcherViewController)
CHDeclareClass(SBReachabilityManager)
CHDeclareClass(SBPrototypeController)

SpringBoard *KazeSpringBoard(void) { return StaticValue(SpringBoard *, (SpringBoard *)[UIApplication sharedApplication]); }
SBWorkspace *KazeWorkspace(void) { return StaticValue(SBWorkspace *, [CHClass(SBWorkspace) mainWorkspace]); }
SBUIController *KazeUIController(void) { return StaticValue(SBUIController *, CHSharedInstance(SBUIController)); }
SBMainSwitcherViewController *KazeSwitcherController(void) { return StaticValue(SBMainSwitcherViewController *, CHSharedInstance(SBMainSwitcherViewController)); }
UIView *KazeContainerView(void) { return StaticValue(UIView *, ((SBLayoutElementContainerView *)KazeSwitcherController().view).contentView); }
BOOL KazeInterfaceIdiomPhone(void) { return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone; }
BOOL KazeSystemVersion(NSInteger major, NSInteger minor, NSInteger patch) { return [[NSProcessInfo processInfo]isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){major, minor, patch}]; }

BOOL KazeDeviceLocked(void) {
    return KazeSpringBoard().isLocked;
}

BOOL KazeSwitcherShowing(void) {
    return KazeSwitcherController().isVisible;
}

BOOL KazeSwitcherAllowed(void) {
    return !switcherLock
    && [KazeSwitcherController() _activateSwitcherValidatorWithEventLabel:nil transactionProvider:nil](nil)
    && !CHSharedInstance(SBReachabilityManager).reachabilityModeActive
    && [FBWorkspaceEventQueue sharedInstance].executingEvent == nil
    && [FBWorkspaceEventQueue sharedInstance].pendingEvents.count == 0;
}

BOOL KazeHasFrontmostApplication(void) {
    return KazeSpringBoard()._accessibilityFrontMostApplication != nil;
}

void KazeSwitcherLock(BOOL enabled) {
    switcherLock = enabled;
}

void KazeSBAnimate(UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion) {
    [StaticValue(BSUIAnimationFactory *, ({
        SBAppSwitcherSettings *settings = CHSharedInstance(SBPrototypeController).rootSettings.appSwitcherSettings;
        [BSUIAnimationFactory factoryWithMass:settings.presentAnimationMass stiffness:settings.presentAnimationStiffness damping:settings.presentAnimationDamping];
    })) _animateWithAdditionalDelay:0 options:UIViewAnimationOptionBeginFromCurrentState actions:actions completion:completion];
}

void KazeAnimate(NSTimeInterval duration, UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion) {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:actions completion:completion];
}

void KazeSpring(NSTimeInterval duration, CGFloat damping, CGFloat velocity, UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion) {
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionBeginFromCurrentState animations:actions completion:completion];
}

void KazeTransit(UIView *view, NSTimeInterval duration, UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion) {
    [UIView transitionWithView:view duration:duration options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve animations:actions completion:completion];
}

CGFloat KazeRubberbandValue(CGFloat value, CGFloat max) {
    static CGFloat const constant = 0.55;
    static CGFloat const ratio = 0.2;
    CGFloat dimension = ratio * max;
    if (value < 0) {
        value = 0 - dimension * (1.0 - (1.0 / (((0 - value) * constant / dimension) + 1.0)));
    } else if (value > max) {
        value = max + dimension * (1.0 - (1.0 / (((value - max) * constant / dimension) + 1.0)));
    }
    return value;
}

id KazePreferencesValue(NSString *key) {
    return [StaticValue(NSUserDefaults *, KazePreferences()) objectForKey:key];
}

CHConstructor {
    @autoreleasepool {
        CHLoadLateClass(SBWorkspace);
        CHLoadLateClass(SBUIController);
        CHLoadLateClass(SBMainSwitcherViewController);
        CHLoadLateClass(SBReachabilityManager);
        CHLoadLateClass(SBPrototypeController);
    }
}
