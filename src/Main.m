#import "Headers.h"

CHDeclareClass(SBUIController)

CHOptimizedMethod(0, self, id, SBUIController, init) {
    self = CHSuper(0, SBUIController, init);
    KazeRegisterGesture(KazeQuickSwitcherCondition, KazeQuickSwitcherHandler);
    KazeRegisterGesture(KazeHomeScreenCondition, KazeHomeScreenHandler);
    KazeRegisterGesture(KazeLockScreenCondition, KazeLockScreenHandler);
    return self;
}

CHConstructor {
    @autoreleasepool {
        CHLoadLateClass(SBUIController);
        CHHook(0, SBUIController, init);
    }
}
