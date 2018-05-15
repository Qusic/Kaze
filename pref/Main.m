#import "Headers.h"
#import <Social/Social.h>

@interface KazePreferencesController : QSPSListController
@end

@implementation KazePreferencesController

+ (void)initialize {
    [[NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/AppList.bundle"]load];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *heartButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [heartButton setImage:KazeImage(@"Heart") forState:UIControlStateNormal];
    [heartButton sizeToFit];
    [heartButton addTarget:self action:@selector(heartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:heartButton];
}

- (NSArray *)newAllSpecifiers {
    return @[
        [self newGroupSpecifierForIdentifier:nil name:nil footer:KazeString(@"INSTRUCTION") updateBlock:NULL],
        [self newSpecifierForIdentifier:kQuickSwitcherEnabledKey() name:KazeString(@"QUICKSWITCHER") image:KazeImage(@"QuickSwitcher") cell:PSSwitchCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:NULL],
        [self newSpecifierForIdentifier:kHotCornersEnabledKey() name:KazeString(@"HOTCORNERS") image:KazeImage(@"HotCorners") cell:PSSwitchCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:NULL],

        [self newGroupSpecifierForIdentifier:nil name:nil footer:nil updateBlock:NULL],
        [self newSpecifierForIdentifier:kAccessAppSwitcherKey() name:KazeString(@"ACCESS_APP_SWITCHER") image:nil cell:PSSwitchCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:^BOOL(PSSpecifier *specifier) {
            return [self.preferences boolForKey:kQuickSwitcherEnabledKey()];
        }],
        [self newSpecifierForIdentifier:kDisableLockGestureKey() name:KazeString(@"DISABLE_LOCK_GESTURE") image:nil cell:PSSwitchCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:^BOOL(PSSpecifier *specifier) {
            return [self.preferences boolForKey:kHotCornersEnabledKey()];
        }],
        [self newSpecifierForIdentifier:kInvertHotCornersKey() name:KazeString(@"INVERT_HOT_CORNERS") image:nil cell:PSSwitchCell setupBlock:NULL updateBlock:NULL isShowingBlock:NULL isEnabledBlock:^BOOL(PSSpecifier *specifier) {
            return [self.preferences boolForKey:kQuickSwitcherEnabledKey()] || [self.preferences boolForKey:kHotCornersEnabledKey()];
        }],
        [self newSpecifierForIdentifier:nil name:KazeString(@"DISABLE_IN_APPS") image:nil cell:PSLinkCell setupBlock:^(PSSpecifier *specifier) {
            specifier->detailControllerClass = NSClassFromString(@"ALApplicationPreferenceViewController");
            [specifier setProperty:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", KazeIdentifier()] forKey:@"ALSettingsPath"];
            [specifier setProperty:kDisableInAppsKey(nil) forKey:@"ALSettingsKeyPrefix"];
        } updateBlock:NULL isShowingBlock:NULL isEnabledBlock:^BOOL(PSSpecifier *specifier) {
            return [self.preferences boolForKey:kQuickSwitcherEnabledKey()] || [self.preferences boolForKey:kHotCornersEnabledKey()];
        }],

        [self newGroupSpecifierForIdentifier:nil name:nil footer:KazeString(@"CREDIT") updateBlock:NULL],
    ];
}

- (void)heartButtonAction:(UIButton *)sender {
    SLComposeViewController *composeSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeSheet setInitialText:KazeString(@"SHARE_TEXT")];
    [(UIViewController *)self presentViewController:composeSheet animated:YES completion:nil];
}

@end
