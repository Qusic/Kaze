#import "Headers.h"

@interface KazeHomeScreenIcon : SBLeafIcon
+ (instancetype)defaultIcon;
@end

CHDeclareClass(SBLeafIcon)
CHDeclareClass(KazeHomeScreenIcon)
CHDeclareClass(SBIconModel)

CHOptimizedClassMethod(0, new, id, KazeHomeScreenIcon, defaultIcon) {
    static KazeHomeScreenIcon *icon;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static NSString * const springboardIdentifier = @"com.apple.springboard";
        icon = [[self alloc]initWithLeafIdentifier:springboardIdentifier applicationBundleID:nil];
    });
    return icon;
}

CHOptimizedMethod(1, super, UIImage *, KazeHomeScreenIcon, getGenericIconImage, int, format) {
    return KazeImage(@"Home");
}

CHOptimizedMethod(1, super, UIImage *, KazeHomeScreenIcon, generateIconImage, int, format) {
    return KazeImage(@"Home");
}

CHOptimizedMethod(0, super, BOOL, KazeHomeScreenIcon, launchEnabled) {
    return YES;
}

CHOptimizedMethod(0, self, void, SBIconModel, loadAllIcons) {
    CHSuper(0, SBIconModel, loadAllIcons);
    [self addIcon:[CHClass(KazeHomeScreenIcon) defaultIcon]];
}

CHOptimizedMethod(1, self, BOOL, SBIconModel, isIconVisible, SBIcon *, icon) {
    return [icon isKindOfClass:CHClass(KazeHomeScreenIcon)] ? NO : CHSuper(1, SBIconModel, isIconVisible, icon);
}

CHConstructor {
    @autoreleasepool {
        CHLoadLateClass(SBLeafIcon);
        CHRegisterClass(KazeHomeScreenIcon, SBLeafIcon) {
            CHClassHook(0, KazeHomeScreenIcon, defaultIcon);
            CHHook(1, KazeHomeScreenIcon, getGenericIconImage);
            CHHook(1, KazeHomeScreenIcon, generateIconImage);
            CHHook(0, KazeHomeScreenIcon, launchEnabled);
        }
        CHLoadLateClass(SBIconModel);
        CHHook(0, SBIconModel, loadAllIcons);
        CHHook(1, SBIconModel, isIconVisible);
    }
}