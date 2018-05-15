#import "Headers.h"

@interface KazeHomeScreenDeckViewController : SBDeckSwitcherViewController
@end

CHDeclareClass(SBDeckSwitcherViewController)
CHDeclareClass(KazeHomeScreenDeckViewController)
CHDeclareClass(SBSwitcherMetahostingHomePageContentView)

static void gestureBegan(void) {
    KazePresentInteractiveSwitcherBegin(CHClass(KazeHomeScreenDeckViewController), NULL, NULL);
}

static void gestureChanged(CGPoint position) {
    CGFloat height = KazeContainerView().bounds.size.height;
    CGFloat step = (height - position.y) / height;
    KazeSwitcherSetTransitionProgress(step);
}

static void gestureEnded(CGPoint position, CGPoint velocity) {
    KazePresentInteractiveSwitcherEnd();
    CGFloat forward = velocity.y <= 0;
    CGFloat height = KazeContainerView().bounds.size.height;
    CGFloat distance = forward ? position.y : height - position.y;
    CGFloat springVelocity = ABS(velocity.y) / distance;
    KazeSpring(0.4, 1.0, springVelocity, ^{
        KazeSwitcherSetTransitionProgress(forward ? 1 : 0);
        KazeSwitcherController()._returnToDisplayItem = CHIvar(KazeSwitcherController(), _displayItems, NSArray * const)[forward ? 0 : 1];
    }, ^(BOOL finished) {
        KazeDismissInteractiveSwitcher();
    });
}

static void gestureCancelled(void) {
    KazePresentInteractiveSwitcherEnd();
    KazeSpring(0.4, 1.0, 1.0, ^{
        KazeSwitcherSetTransitionProgress(0);
        KazeSwitcherController()._returnToDisplayItem = CHIvar(KazeSwitcherController(), _displayItems, NSArray * const)[1];
    }, ^(BOOL finished) {
        KazeDismissInteractiveSwitcher();
    });
}

KazeGestureConditionBlock KazeHomeScreenCondition = ^BOOL(KazeGestureRegion region) {
    return [KazePreferencesValue(kHotCornersEnabledKey()) boolValue]
        && region == ([KazePreferencesValue(kInvertHotCornersKey()) boolValue] ? KazeGestureRegionLeft : KazeGestureRegionRight)
        && !KazeDeviceLocked()
        && !KazeSwitcherShowing()
        && KazeSwitcherAllowed()
        && KazeHasFrontmostApplication();
};

KazeGestureHandlerBlock KazeHomeScreenHandler = ^void(UIGestureRecognizerState state, CGPoint position, CGPoint velocity) {
    switch (state) {
        case UIGestureRecognizerStateBegan:
            gestureBegan();
            KazeSBAnimate(^{ gestureChanged(position); }, NULL);
            break;
        case UIGestureRecognizerStateChanged:
            gestureChanged(position);
            break;
        case UIGestureRecognizerStateEnded:
            gestureEnded(position, velocity);
            break;
        default:
            gestureCancelled();
            break;
    }
};

static CGFloat const transitionFraction = 0.75;
static CGFloat const minScale = 0.9;
static CGFloat const scaleFactor = 0.2;

CHOptimizedMethod(1, super, CGSize, KazeHomeScreenDeckViewController, _scrollViewContentSizeForDisplayItemCount, NSUInteger, displayItemCount) {
    return self.view.bounds.size;
}

CHOptimizedMethod(7, super, CGRect, KazeHomeScreenDeckViewController, _frameForIndex, NSUInteger, index, displayItemsCount, NSUInteger, count, transitionParameters, SBTransitionParameters, parameters, scrollProgress, double, progress, ignoringScrollOffset, BOOL, ignoring1, ignoringKillingAdjustments, BOOL, ignoring2, ignoringPinning, BOOL, ignoring3) {
    return self.view.bounds;
}

CHOptimizedMethod(4, super, double, KazeHomeScreenDeckViewController, _depthForIndex, NSUInteger, index, displayItemsCount, NSUInteger, count, scrollProgress, double, scrollProgress, ignoringKillOffset, BOOL, ignoringKillOffset) {
    return 0;
}

CHOptimizedMethod(1, super, double, KazeHomeScreenDeckViewController, _scaleForPresentedProgress, CGFloat, presentedProgress) {
    CGFloat step;
    if (presentedProgress < transitionFraction) {
        step = 1 - (transitionFraction - presentedProgress) / transitionFraction;
    } else {
        step = 1 - (presentedProgress - transitionFraction) / (1 - transitionFraction);
    }
    CGFloat scale = 1 * (1 - step) + minScale * step;
    return scale;
}

CHOptimizedMethod(3, super, CGAffineTransform, KazeHomeScreenDeckViewController, _transformForIndex, NSUInteger, index, progressPresented, CGFloat, presentProgress, scrollProgress, double, scrollProgress) {
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (index == 0) {
        CGFloat scale = 1 - (1 - [self _scaleForPresentedProgress:presentProgress]) * (1 + scaleFactor);
        transform = CGAffineTransformMakeScale(scale, scale);
    } else if (index == 1) {
        CGFloat scale = [self _scaleForPresentedProgress:presentProgress];
        CGFloat height = self.view.bounds.size.height;
        CGFloat translation = -height * presentProgress + height * (1 - scale) / 2;
        transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale), CGAffineTransformMakeTranslation(0, translation));
    }
    return transform;
}

CHOptimizedMethod(2, super, CGFloat, KazeHomeScreenDeckViewController, _blurForIndex, NSUInteger, index, scrollProgress, double, progress) {
    return 0;
}

CHOptimizedMethod(1, super, CGFloat, KazeHomeScreenDeckViewController, _titleAndIconOpacityForIndex, NSUInteger, index) {
    return 0;
}

CHOptimizedMethod(2, super, CGFloat, KazeHomeScreenDeckViewController, _titleOpacityForIndex, NSUInteger, index, scrollProgress, double, scrollProgress) {
    return 0;
}

CHOptimizedMethod(4, super, double, KazeHomeScreenDeckViewController, _scrollProgressForIndex, NSUInteger, index, displayItemsCount, NSUInteger, count, depth, double, depth, ignoringKillOffset, BOOL, ignoringKillOffset) {
    return 0;
}

CHOptimizedMethod(0, super, double, KazeHomeScreenDeckViewController, _normalizedScrollProgress) {
    return 0;
}

CHOptimizedMethod(3, super, void, KazeHomeScreenDeckViewController, _updateScrollViewContentOffsetToCenterIndex, NSUInteger, centerIndex, animated, BOOL, animated, completion, UIViewAnimationCompletionBlock, completion) {
    [self _setContentOffset:CGPointZero animated:animated completion:completion];
}

CHOptimizedMethod(1, super, NSUInteger, KazeHomeScreenDeckViewController, _indexForPresentationOrDismissalIsPresenting, BOOL, isPresenting) {
    return CHSuper(1, KazeHomeScreenDeckViewController, _indexForPresentationOrDismissalIsPresenting, NO);
}

CHOptimizedMethod(1, super, BOOL, KazeHomeScreenDeckViewController, _isAboveTransitioningItemDuringPresentation, SBDisplayItem *, displayItem) {
    return NO;
}

CHOptimizedMethod(1, super, BOOL, KazeHomeScreenDeckViewController, _isIndexVisible, NSUInteger, index) {
    return index <= 1;
}

CHOptimizedMethod(1, super, BOOL, KazeHomeScreenDeckViewController, _isItemVisible, SBDisplayItem *, displayItem) {
    return [self.displayItems indexOfObject:displayItem] <= 1;
}

CHOptimizedMethod(0, super, void, KazeHomeScreenDeckViewController, _ensureCardSubviewOrdering) {
    SBAppSwitcherScrollView *scrollView = CHIvar(self, _scrollView, SBAppSwitcherScrollView * const);
    NSDictionary *visibleItemContainers = CHIvar(self, _visibleItemContainers, NSDictionary * const);
    NSArray *displayItems = self.displayItems;
    [scrollView bringSubviewToFront:visibleItemContainers[displayItems[0]]];
    [scrollView bringSubviewToFront:visibleItemContainers[displayItems[1]]];
}

CHOptimizedMethod(0, self, NSInteger, SBSwitcherMetahostingHomePageContentView, _targetWallpaperStyle) {
    if ([KazeSwitcherController()._contentViewController isKindOfClass:CHClass(KazeHomeScreenDeckViewController)]) {
        return 0;
    }
    return CHSuper(0, SBSwitcherMetahostingHomePageContentView, _targetWallpaperStyle);
}

CHConstructor {
    @autoreleasepool {
        CHLoadLateClass(SBDeckSwitcherViewController);
        CHRegisterClass(KazeHomeScreenDeckViewController, SBDeckSwitcherViewController) {
            CHHook(1, KazeHomeScreenDeckViewController, _scrollViewContentSizeForDisplayItemCount);
            CHHook(7, KazeHomeScreenDeckViewController, _frameForIndex, displayItemsCount, transitionParameters, scrollProgress, ignoringScrollOffset, ignoringKillingAdjustments, ignoringPinning);
            CHHook(4, KazeHomeScreenDeckViewController, _depthForIndex, displayItemsCount, scrollProgress, ignoringKillOffset);
            CHHook(1, KazeHomeScreenDeckViewController, _scaleForPresentedProgress);
            CHHook(3, KazeHomeScreenDeckViewController, _transformForIndex, progressPresented, scrollProgress);
            CHHook(2, KazeHomeScreenDeckViewController, _blurForIndex, scrollProgress);
            CHHook(1, KazeHomeScreenDeckViewController, _titleAndIconOpacityForIndex);
            CHHook(2, KazeHomeScreenDeckViewController, _titleOpacityForIndex, scrollProgress);
            CHHook(4, KazeHomeScreenDeckViewController, _scrollProgressForIndex, displayItemsCount, depth, ignoringKillOffset);
            CHHook(0, KazeHomeScreenDeckViewController, _normalizedScrollProgress);
            CHHook(3, KazeHomeScreenDeckViewController, _updateScrollViewContentOffsetToCenterIndex, animated, completion);
            CHHook(1, KazeHomeScreenDeckViewController, _indexForPresentationOrDismissalIsPresenting);
            CHHook(1, KazeHomeScreenDeckViewController, _isAboveTransitioningItemDuringPresentation);
            CHHook(1, KazeHomeScreenDeckViewController, _isIndexVisible);
            CHHook(1, KazeHomeScreenDeckViewController, _isItemVisible);
            CHHook(0, KazeHomeScreenDeckViewController, _ensureCardSubviewOrdering);
        }
        CHLoadLateClass(SBSwitcherMetahostingHomePageContentView);
        CHHook(0, SBSwitcherMetahostingHomePageContentView, _targetWallpaperStyle);
    }
}
