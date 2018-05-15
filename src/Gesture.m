#import "Headers.h"

static NSMutableArray<NSArray *> *gestureRegistry;
static KazeGestureHandlerBlock currentHandler;

CHDeclareClass(SBControlCenterController)
CHDeclareClass(SBOrientationLockManager)
CHDeclareClass(SBBacklightController)

void KazeRegisterGesture(KazeGestureConditionBlock condition, KazeGestureHandlerBlock handler) {
    [gestureRegistry addObject:@[condition, handler]];
}

CHOptimizedMethod(1, self, void, SBControlCenterController, _handleShowControlCenterGesture, SBScreenEdgePanGestureRecognizer *, recognizer) {
    UIGestureRecognizerState state = recognizer.state;
    UIInterfaceOrientation orientation = KazeSpringBoard().activeInterfaceOrientation;
    UIWindow *window = recognizer.view.window;
    CGSize size = window.bounds.size;
    CGPoint position = [recognizer locationInView:window];
    CGPoint velocity = [recognizer velocityInView:window];
    switch (orientation) {
        case 1:
            break;
        case 2:
            position = CGPointMake(size.width - position.x, size.height - position.y);
            velocity = CGPointMake(-velocity.x, -velocity.y);
            break;
        case 3:
            size = CGSizeMake(size.height, size.width);
            position = CGPointMake(position.y, size.height - position.x);
            velocity = CGPointMake(velocity.y, -velocity.x);
            break;
        case 4:
            size = CGSizeMake(size.height, size.width);
            position = CGPointMake(size.width - position.y, position.x);
            velocity = CGPointMake(-velocity.y, velocity.x);
            break;
        default:
            break;
    }
    if (state == UIGestureRecognizerStateBegan) {
        currentHandler = nil;
        if (![KazePreferencesValue(kDisableInAppsKey(KazeSpringBoard()._accessibilityFrontMostApplication.bundleIdentifier)) boolValue]) {
            KazeGestureRegion region = ({
                CGFloat x = position.x;
                CGFloat width = size.width;
                KazeGestureRegion region = KazeGestureRegionCenter;
                if (x < width * 0.25) {
                    region = KazeGestureRegionLeft;
                } else if (x > width * 0.75) {
                    region = KazeGestureRegionRight;
                } else {
                    region = KazeGestureRegionCenter;
                }
                region;
            });
            [gestureRegistry enumerateObjectsUsingBlock:^(NSArray *gestureArray, NSUInteger index, BOOL *stop) {
                KazeGestureConditionBlock condition = gestureArray[0];
                KazeGestureHandlerBlock handler = gestureArray[1];
                if (condition(region)) {
                    currentHandler = handler;
                    *stop = YES;
                }
            }];
        }
    }
    if (currentHandler) {
        NSString *reason = KazeIdentifier();
        switch (state) {
            case UIGestureRecognizerStateBegan:
                [CHSharedInstance(SBOrientationLockManager) setLockOverrideEnabled:YES forReason:reason];
                [CHSharedInstance(SBBacklightController) setIdleTimerDisabled:YES forReason:reason];
                currentHandler(state, position, velocity);
                break;
            case UIGestureRecognizerStateChanged:
                currentHandler(state, position, velocity);
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
                currentHandler(state, position, velocity);
                [CHSharedInstance(SBOrientationLockManager) setLockOverrideEnabled:NO forReason:reason];
                [CHSharedInstance(SBBacklightController) setIdleTimerDisabled:NO forReason:reason];
            default:
                currentHandler = nil;
                break;
        }
    } else {
        CHSuper(1, SBControlCenterController, _handleShowControlCenterGesture, recognizer);
    }
}

CHConstructor {
    @autoreleasepool {
        gestureRegistry = [NSMutableArray array];
        CHLoadLateClass(SBControlCenterController);
        CHLoadLateClass(SBOrientationLockManager);
        CHLoadLateClass(SBBacklightController);
        CHHook(1, SBControlCenterController, _handleShowControlCenterGesture);
    }
}
