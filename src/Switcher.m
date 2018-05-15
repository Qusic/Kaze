#import "Headers.h"

static NSMutableArray<UIViewAnimationCompletionBlock> *animationCompletionBlocks;
static KazeCallback switcherWillAppearCallback;
static KazeCallback switcherDidAppearCallback;
static BOOL switcherContinuityLock;
static BOOL interceptAnimation;
static BOOL presentationWorkaround;

CHDeclareClass(SBMainSwitcherViewController)
CHDeclareClass(SBDeckSwitcherViewController)
CHDeclareClass(SBAppSwitcherSettings)
CHDeclareClass(UIView)

static inline void fireAndCleanupAnimationCompletionBlocks(void) {
    [animationCompletionBlocks enumerateObjectsUsingBlock:^(UIViewAnimationCompletionBlock completion, NSUInteger index, BOOL *stop) {
        completion(YES);
    }];
    [animationCompletionBlocks removeAllObjects];
}

void KazePresentInteractiveSwitcherBegin(Class switcherClass, KazeCallback willAppearCallback, KazeCallback didAppearCallback) {
    CHIvar(KazeSwitcherController(), _contentViewControllerClass, Class) = switcherClass ?: CHClass(SBDeckSwitcherViewController);
    switcherWillAppearCallback = willAppearCallback;
    switcherDidAppearCallback = didAppearCallback;
    switcherContinuityLock = YES;
    interceptAnimation = YES;
    presentationWorkaround = YES;
    [KazeSwitcherController() activateSwitcherNoninteractively];
    presentationWorkaround = NO;
    interceptAnimation = NO;
}

void KazePresentInteractiveSwitcherEnd(void) {
    switcherContinuityLock = NO;
    fireAndCleanupAnimationCompletionBlocks();
}

void KazeDismissInteractiveSwitcher(void) {
    interceptAnimation = YES;
    [KazeSwitcherController() dismissSwitcherNoninteractively];
    interceptAnimation = NO;
    fireAndCleanupAnimationCompletionBlocks();
    [KazeSwitcherController() _updateContentViewControllerClassFromSettings];
    switcherWillAppearCallback = NULL;
    switcherDidAppearCallback = NULL;
}

void KazeSwitcherSetTransitionProgress(CGFloat progress) {
    BOOL *inProgressRef = CHIvarRef(KazeSwitcherController()._contentViewController, _transitionInProgress, BOOL);
    if (inProgressRef) {
        BOOL inProgress = *inProgressRef;
        *inProgressRef = YES;
        [KazeSwitcherController() setTransitionParameters:(SBTransitionParameters){progress, MIN(progress * 4, 1), 0, 0}];
        *inProgressRef = inProgress;
    }
}

CHOptimizedMethod(1, self, void, SBMainSwitcherViewController, viewWillAppear, BOOL, animated) {
    CHSuper(1, SBMainSwitcherViewController, viewWillAppear, animated);
    if (switcherWillAppearCallback) {
        switcherWillAppearCallback();
        switcherWillAppearCallback = NULL;
    }
}

CHOptimizedMethod(1, self, void, SBMainSwitcherViewController, viewDidAppear, BOOL, animated) {
    CHSuper(1, SBMainSwitcherViewController, viewDidAppear, animated);
    if (switcherDidAppearCallback) {
        switcherDidAppearCallback();
        switcherDidAppearCallback = NULL;
    }
}

CHOptimizedMethod(1, self, void, SBMainSwitcherViewController, _continuityAppSuggestionChanged, NSNotification *, notification) {
    if (!switcherContinuityLock) {
        CHSuper(1, SBMainSwitcherViewController, _continuityAppSuggestionChanged, notification);
    }
}

CHOptimizedMethod(1, self, void, SBDeckSwitcherViewController, setTransitionParameters, SBTransitionParameters, parameters) {
    if (presentationWorkaround) {
        parameters.progress = 0;
    }
    CHSuper(1, SBDeckSwitcherViewController, setTransitionParameters, parameters);
}

CHOptimizedMethod(0, self, SBAppSwitcherStyle, SBAppSwitcherSettings, switcherStyle) {
    return KazeSystemVersion(10, 0, 0) ? SBAppSwitcherStyleDeck : (SBAppSwitcherStyle)1;
}

CHOptimizedClassMethod(9, self, void, UIView, _setupAnimationWithDuration, NSTimeInterval, duration, delay, NSTimeInterval, delay, view, UIView *, view, options, UIViewAnimationOptions, options, factory, id<_UIBasicAnimationFactory>, factory, animations, UIViewAnimationActionsBlock, animations, start, id, start, animationStateGenerator, id, generator, completion, UIViewAnimationCompletionBlock, completion) {
    if (interceptAnimation) {
        animations();
        if (completion) {
            [animationCompletionBlocks addObject:completion];
        }
    } else {
        CHSuper(9, UIView, _setupAnimationWithDuration, duration, delay, delay, view, view, options, options, factory, factory, animations, animations, start, start, animationStateGenerator, generator, completion, completion);
    }
}

CHOptimizedClassMethod(3, self, void, UIView, addKeyframeWithRelativeStartTime, double, frameStartTime, relativeDuration, double, frameDuration, animations, UIViewAnimationActionsBlock, animations) {
    if (interceptAnimation) {
        animations();
    } else {
        CHSuper(3, UIView, addKeyframeWithRelativeStartTime, frameStartTime, relativeDuration, frameDuration, animations, animations);
    }
}

CHConstructor {
    @autoreleasepool {
        animationCompletionBlocks = [NSMutableArray array];
        CHLoadLateClass(SBMainSwitcherViewController);
        CHLoadLateClass(SBDeckSwitcherViewController);
        CHLoadLateClass(SBAppSwitcherSettings);
        CHLoadClass(UIView);
        CHHook(1, SBMainSwitcherViewController, viewWillAppear);
        CHHook(1, SBMainSwitcherViewController, viewDidAppear);
        CHHook(1, SBMainSwitcherViewController, _continuityAppSuggestionChanged);
        CHHook(1, SBDeckSwitcherViewController, setTransitionParameters);
        CHHook(0, SBAppSwitcherSettings, switcherStyle);
        CHClassHook(9, UIView, _setupAnimationWithDuration, delay, view, options, factory, animations, start, animationStateGenerator, completion);
        CHClassHook(3, UIView, addKeyframeWithRelativeStartTime, relativeDuration, animations);
    }
}
