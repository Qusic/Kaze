#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CaptainHook/CaptainHook.h>

typedef void (^UIViewAnimationActionsBlock)(void);
typedef void (^UIViewAnimationCompletionBlock)(BOOL finished);

@protocol _UIBasicAnimationFactory <NSObject>
- (CABasicAnimation *)_basicAnimationForView:(UIView *)view withKeyPath:(NSString *)keyPath;
@optional
- (CAMediaTimingFunction *)_timingFunctionForAnimationInView:(UIView *)view withKeyPath:(NSString *)keyPath;
- (CAMediaTimingFunction *)_timingFunctionForAnimation;
@end

@interface UIWindow (Private)
- (void)_setRotatableViewOrientation:(UIInterfaceOrientation)orientation updateStatusBar:(BOOL)updateStatusBar duration:(NSTimeInterval)duration force:(BOOL)force;
@end

@interface UIView (Private)
+ (void)_setupAnimationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay view:(UIView *)view options:(UIViewAnimationOptions)options factory:(id<_UIBasicAnimationFactory>)factory animations:(UIViewAnimationActionsBlock)animations start:(id)start animationStateGenerator:(id)generator completion:(UIViewAnimationCompletionBlock)completion;
@end

@interface UIScrollView (Private)
- (void)handlePan:(UIPanGestureRecognizer *)gesture;
@end

@interface UIImage (Private)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale;
- (UIImage *)_imageScaledToProportion:(CGFloat)proportion interpolationQuality:(CGInterpolationQuality)quality;
@end

@interface _UIBackdropView : UIView
@property (copy, nonatomic) NSString *groupName;
@property (assign, nonatomic) NSTimeInterval appliesOutputSettingsAnimationDuration;
- (instancetype)initWithStyle:(NSInteger)style;
- (instancetype)initWithPrivateStyle:(NSInteger)style;
@end

@interface _UISettings : NSObject
@end

@interface CALayer (Private)
@property (assign) BOOL allowsGroupBlending;
@end

@interface BSEventQueueEvent : NSObject
@end

@interface BSEventQueue : NSObject
@property (retain, nonatomic) BSEventQueueEvent *executingEvent;
@property (copy, nonatomic, readonly) NSArray *pendingEvents;
@end

@interface BSUIAnimationFactory : NSObject
+ (instancetype)factoryWithMass:(CGFloat)mass stiffness:(CGFloat)stiffness damping:(CGFloat)damping;
+ (instancetype)factoryWithMass:(CGFloat)mass stiffness:(CGFloat)stiffness damping:(CGFloat)damping epsilon:(CGFloat)epsilon;
+ (void)animateWithFactory:(BSUIAnimationFactory *)factory options:(UIViewAnimationOptions)options actions:(UIViewAnimationActionsBlock)actions;
+ (void)animateWithFactory:(BSUIAnimationFactory *)factory options:(UIViewAnimationOptions)options actions:(UIViewAnimationActionsBlock)actions completion:(UIViewAnimationCompletionBlock)completion;
- (void)_animateWithAdditionalDelay:(NSTimeInterval)additionalDelay options:(UIViewAnimationOptions)options actions:(UIViewAnimationActionsBlock)actions completion:(UIViewAnimationCompletionBlock)completion;
@end

@interface FBWorkspaceEventQueue : BSEventQueue
+ (instancetype)sharedInstance;
@end

extern void BKSHIDServicesSetBacklightFactorWithFadeDuration(float factor, float duration, BOOL unknown);
extern void BKSHIDServicesSetBacklightFactorWithFadeDurationSilently(float factor, float duration, BOOL unknown);
// unknown = NO  in -[SBPowerDownView actionSlider:didUpdateSlideWithValue:], -[SBPowerDownView _resetScreenBrightness]
// unknown = YES in -[SBBacklightController _animateBacklightToFactor:duration:source:silently:completion:]

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBDisplayItem : NSObject
@property(copy, nonatomic, readonly) NSString *displayIdentifier;
@property(copy, nonatomic, readonly) NSString *type;
+ (instancetype)displayItemWithType:(NSString *)type displayIdentifier:(id)identifier;
+ (instancetype)homeScreenDisplayItem;
+ (instancetype)sideSwitcherDisplayItem;
@end

@interface SBBestAppSuggestion : NSObject
@property(copy, readonly) NSString *bundleIdentifier;
@end

@interface SBWorkspaceTransitionRequest : NSObject
@end

@interface SBMainWorkspaceTransitionRequest : SBWorkspaceTransitionRequest
@end

@interface SBWorkspaceTransaction : NSObject
@end

@interface SBMainWorkspaceTransaction : SBWorkspaceTransaction
@end

typedef BOOL (^SBValidator)(SBWorkspaceTransitionRequest *);
typedef void (^SBTransitionRequestBuilder)(SBWorkspaceTransitionRequest *);
typedef SBWorkspaceTransaction * (^SBTransactionProvider)(SBWorkspaceTransitionRequest *);

@interface SBWorkspaceEntity : NSObject
@end

@interface SBWorkspace : NSObject
+ (instancetype)mainWorkspace;
- (SBWorkspaceTransitionRequest *)createRequestForApplicationActivation:(SBWorkspaceEntity *)applicationActivation options:(NSUInteger)options;
- (SBWorkspaceTransitionRequest *)createRequestWithOptions:(NSUInteger)options;
- (BOOL)executeTransitionRequest:(SBWorkspaceTransitionRequest *)request;
- (BOOL)executeTransitionRequest:(SBWorkspaceTransitionRequest *)request withValidator:(SBValidator)validator;
- (BOOL)requestTransitionWithBuilder:(SBTransitionRequestBuilder)builder;
- (BOOL)requestTransitionWithOptions:(NSUInteger)options builder:(SBTransitionRequestBuilder)builder validator:(SBValidator)validator;
- (SBWorkspaceTransaction *)transactionForTransitionRequest:(SBWorkspaceTransitionRequest *)transitionRequest;
@end

typedef NS_ENUM(NSUInteger, SBSystemGestureType) {
    SBSystemGestureTypeNotificationCenter = 1,
    SBSystemGestureTypeDismissBanner = 2,
    SBSystemGestureTypeControlCenter = 3,
    SBSystemGestureTypeForcePressSwitcher = 13
};

@interface SBScreenEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer
@end

@interface SBSystemGestureManager : NSObject {
    NSMutableDictionary *_typeToGesture;
    NSMutableDictionary *_typeToState;
    NSMutableSet *_recognizingGestures;
}
@property(retain, nonatomic, readonly) id display;
@property(assign, nonatomic, readonly, getter=isAnyTouchGestureRunning) BOOL anyTouchGestureRunning;
@property(assign, nonatomic, getter=areSystemGesturesDisabledForAccessibility) BOOL systemGesturesDisabledForAccessibility;
+ (instancetype)mainDisplayManager;
- (instancetype)initWithDisplay:(id)display;
- (void)addGestureRecognizer:(UIGestureRecognizer *)recognizer withType:(SBSystemGestureType)type;
- (BOOL)isGestureWithTypeAllowed:(SBSystemGestureType)typeAllowed;
- (void)removeGestureRecognizer:(UIGestureRecognizer *)recognizer;
- (void)updateUserPreferences;
@end

@interface SBAppSwitcherScrollView : UIScrollView
@end

@class SBAppSwitcherPageView;

@protocol SBAppSwitcherPageContentView <NSObject>
- (CGFloat)cornerRadius;
- (void)setCornerRadius:(CGFloat)radius;
- (void)invalidate;
@optional
- (void)prepareToBecomeVisibleIfNecessary;
- (void)respondToBecomingInvisibleIfNecessary;
- (void)viewPresenting:(SBAppSwitcherPageView *)view withInteraction:(BOOL)interaction andInitialProgress:(CGFloat)initialProgress forTransitionRequest:(SBWorkspaceTransitionRequest *)transitionRequest;
- (void)viewDismissing:(SBAppSwitcherPageView *)view withInteraction:(BOOL)interaction andInitialProgress:(CGFloat)initialProgress forTransitionRequest:(SBWorkspaceTransitionRequest *)transitionRequest;
- (void)updateTransitionProgress:(CGFloat)progress;
- (void)interactionDidEnd:(BOOL)interaction;
- (void)transitionDidEnd:(BOOL)transition forPresentation:(BOOL)presentation;
@end

@protocol SBMainAppSwitcherPageContentView <SBAppSwitcherPageContentView>
- (UIInterfaceOrientation)orientation;
- (void)setOrientation:(UIInterfaceOrientation)orientation;
@optional
- (void)simplifyForMotion;
- (void)unsimplifyAfterMotion;
@end

@interface SBSwitcherWallpaperPageContentView : UIView <SBMainAppSwitcherPageContentView>
@end

@interface SBSwitcherMetahostingHomePageContentView : SBSwitcherWallpaperPageContentView
- (NSInteger)_targetWallpaperStyle;
@end

@interface SBAppSwitcherPageView : UIView {
    UIView *_hitTestBlocker;
}
@property(retain, nonatomic) UIView<SBAppSwitcherPageContentView> *view;
- (void)setBlocksTouches:(BOOL)touches;
- (void)updateTransitionProgress:(CGFloat)progress;
@end

@interface SBDeckSwitcherPageView : SBAppSwitcherPageView
@property(retain, nonatomic) UIView<SBMainAppSwitcherPageContentView> *view;
@end

@class SBDeckSwitcherItemContainer;

@protocol SBDeckSwitcherItemContainerDelegate <NSObject>
- (CGRect)frameForPageViewOfContainer:(SBDeckSwitcherItemContainer *)container fullyPresented:(BOOL)fullyPresented;
- (BOOL)shouldShowIconAndLabelOfContainer:(SBDeckSwitcherItemContainer *)container;
- (BOOL)canSelectDisplayItemOfContainer:(SBDeckSwitcherItemContainer *)container numberOfTaps:(NSInteger)taps;
- (BOOL)isDisplayItemOfContainerRemovable:(SBDeckSwitcherItemContainer *)container;
- (CGFloat)minimumVerticalTranslationForKillingOfContainer:(SBDeckSwitcherItemContainer *)container;
- (void)scrollViewKillingProgressUpdated:(CGFloat)killingProgress ofContainer:(SBDeckSwitcherItemContainer *)container;
- (void)selectedDisplayItemOfContainer:(SBDeckSwitcherItemContainer *)container;
- (void)killDisplayItemOfContainer:(SBDeckSwitcherItemContainer *)container withVelocity:(CGFloat)velocity;
@end

@interface SBDeckSwitcherItemContainer : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIScrollView *_verticalScrollView;
}
@property(assign, nonatomic, readonly) id<SBDeckSwitcherItemContainerDelegate> delegate;
@property(retain, nonatomic, readonly) SBDisplayItem *displayItem;
@property(retain, nonatomic) SBDeckSwitcherPageView *pageView;
@property(assign, nonatomic, readonly) CGFloat killingProgress;
@property(assign, nonatomic) CGFloat unobscuredMargin;
- (UIScrollView *)_createScrollView;
- (void)updateTransitionProgress:(CGFloat)progress;
@end

@interface SBDeckSwitcherPageViewProvider : NSObject
- (SBDeckSwitcherPageView *)pageViewForDisplayItem:(SBDisplayItem *)displayItem synchronously:(BOOL)synchronously;
- (void)purgePageViewForDisplayItem:(SBDisplayItem *)displayItem;
- (void)updateCachedPageViewsWithVisibleItemRange:(NSRange)visibleItemRange scrollDirection:(BOOL)direction allItems:(NSArray *)items;
- (CGSize)_pageViewSizeForDisplayItem:(SBDisplayItem *)displayItem;
- (CGSize)_contentSizeForDisplayItem:(SBDisplayItem *)displayItem;
@end

typedef struct {
    CGFloat progress;
    CGFloat cornerRadiusProgress;
    CGFloat initialItemTranslation;
    CGFloat dimming;
} SBTransitionParameters;

@protocol SBMainAppSwitcherContentViewControlling <NSObject>
@property(retain, nonatomic) NSArray *displayItems;
@property(copy, nonatomic, setter=_setInitialDisplayItem:) SBDisplayItem *_initialDisplayItem;
@property(copy, nonatomic, setter=_setReturnToDisplayItem:) SBDisplayItem *_returnToDisplayItem;
- (SBDisplayItem *)nextDisplayItem;
- (void)animatePresentationForTransitionRequest:(SBMainWorkspaceTransitionRequest *)transitionRequest withCompletion:(UIViewAnimationCompletionBlock)completion;
- (void)animateDismissalToDisplayItem:(SBDisplayItem *)displayItem forTransitionRequest:(SBMainWorkspaceTransitionRequest *)transitionRequest withCompletion:(UIViewAnimationCompletionBlock)completion;
- (void)setTransitionParameters:(SBTransitionParameters)parameters;
@end

@protocol SBMainAppSwitcherContentViewControllerDelegate <NSObject>
- (void)switcherContentController:(UIViewController<SBMainAppSwitcherContentViewControlling> *)controller selectedItem:(SBDisplayItem *)item;
- (BOOL)switcherContentController:(UIViewController<SBMainAppSwitcherContentViewControlling> *)controller canDeleteItem:(SBDisplayItem *)item;
- (void)switcherContentController:(UIViewController<SBMainAppSwitcherContentViewControlling> *)controller deletedItem:(SBDisplayItem *)item;
- (void)switcherContentController:(UIViewController<SBMainAppSwitcherContentViewControlling> *)controller activatedBestAppSuggestion:(SBBestAppSuggestion *)suggestion;
@end

@interface SBDeckSwitcherViewController : UIViewController <SBMainAppSwitcherContentViewControlling, SBDeckSwitcherItemContainerDelegate> {
    SBAppSwitcherScrollView *_scrollView;
    SBTransitionParameters _transitionParameters;
    NSMutableDictionary *_visibleItemContainers;
    NSRange _visibleItemRange;
    BOOL _transitionInProgress;
    BOOL _transitionPresenting;
    BOOL _transitionInteractive;
}
@property(assign, nonatomic) id<SBMainAppSwitcherContentViewControllerDelegate> delegate;
- (SBDeckSwitcherItemContainer *)_itemContainerForDisplayItem:(SBDisplayItem *)displayItem;
- (void)_beginInsertionOrRemovalOfDisplayItem:(SBDisplayItem *)displayItem direction:(NSUInteger)direction style:(NSUInteger)style progress:(CGFloat)progress;
- (void)_endInsertionOrRemovalOfDisplayItem:(SBDisplayItem *)displayItem;
- (CGSize)_scrollViewContentSizeForDisplayItemCount:(NSUInteger)displayItemCount;
- (CGRect)_frameForIndex:(NSUInteger)index displayItemsCount:(NSUInteger)count transitionParameters:(SBTransitionParameters)parameters scrollProgress:(double)progress ignoringScrollOffset:(BOOL)ignoring1 ignoringKillingAdjustments:(BOOL)ignoring2 ignoringPinning:(BOOL)ignoring3;
- (double)_depthForIndex:(NSUInteger)index displayItemsCount:(NSUInteger)count scrollProgress:(double)progress ignoringKillOffset:(BOOL)ignoringKillOffset;
- (double)_scaleForPresentedProgress:(CGFloat)presentedProgress;
- (double)_scaleForTransformForIndex:(NSUInteger)index progressPresented:(CGFloat)presented scrollProgress:(double)progress;
- (CGAffineTransform)_transformForIndex:(NSUInteger)index progressPresented:(CGFloat)presented scrollProgress:(double)progress;
- (CGFloat)_opacityForIndex:(NSUInteger)index scrollProgress:(double)progress;
- (CGFloat)_blurForIndex:(NSUInteger)index scrollProgress:(double)progress;
- (CGFloat)_titleAndIconOpacityForIndex:(NSUInteger)index;
- (CGFloat)_titleOpacityForIndex:(NSUInteger)index scrollProgress:(double)scrollProgress;
- (double)_scrollProgressForIndex:(NSUInteger)index displayItemsCount:(NSUInteger)count depth:(double)depth ignoringKillOffset:(BOOL)ignoringKillOffset;
- (double)_normalizedScrollProgress;
- (NSUInteger)_indexForPresentationOrDismissalIsPresenting:(BOOL)isPresenting;
- (BOOL)_isAboveTransitioningItemDuringPresentation:(SBDisplayItem *)displayItem;
- (BOOL)_isIndexVisible:(NSUInteger)index;
- (BOOL)_isItemVisible:(SBDisplayItem *)displayItem;
- (BOOL)_displayItemWantsToBeKeptInViewHierarchy:(SBDisplayItem *)displayItem;
- (void)_applyStyleToItemContainer:(SBDeckSwitcherItemContainer *)itemContainer;
- (void)_applyStyleToItemContainer:(SBDeckSwitcherItemContainer *)itemContainer forceRealBlur:(BOOL)blur;
- (void)_applyStyleToVisibleItemContainers;
- (void)_applyVisibleMarginToItemContainer:(SBDeckSwitcherItemContainer *)itemContainer;
- (void)_updateScrollViewFrameAndContentSize;
- (void)_updateScrollViewContentOffsetToCenterIndex:(NSUInteger)centerIndex animated:(BOOL)animated completion:(UIViewAnimationCompletionBlock)completion;
- (void)_updateVisibleItems;
- (void)_ensureCardSubviewOrdering;
- (void)_setContentOffset:(CGPoint)offset animated:(BOOL)animated completion:(UIViewAnimationCompletionBlock)completion;
@end

@interface SBLayoutElementContainerView : UIView
@property(retain, nonatomic) UIView *contentView;
@end

@interface SBLayoutElementViewController : UIViewController
@end

@interface SBMainSwitcherViewController : SBLayoutElementViewController <SBMainAppSwitcherContentViewControllerDelegate> {
    NSMutableArray *_displayItems;
    Class _contentViewControllerClass;
}
@property(copy, nonatomic, setter=_setInitialDisplayItem:) SBDisplayItem *_initialDisplayItem;
@property(copy, nonatomic, setter=_setReturnToDisplayItem:) SBDisplayItem *_returnToDisplayItem;
+ (instancetype)sharedInstance;
- (UIViewController<SBMainAppSwitcherContentViewControlling> *)_contentViewController;
- (BOOL)isVisible;
- (BOOL)activateSwitcherNoninteractively;
- (BOOL)dismissSwitcherNoninteractively;
- (BOOL)toggleSwitcherNoninteractively;
- (SBValidator)_activateSwitcherValidatorWithEventLabel:(NSString *)eventLabel transactionProvider:(SBTransactionProvider)transactionProvider;
- (SBValidator)_dismissSwitcherValidatorWithEventLabel:(NSString *)eventLabel transactionProvider:(SBTransactionProvider)transactionProvider;
- (SBValidator)_toggleSwitcherTransitionValidator;
- (void)setTransitionParameters:(SBTransitionParameters)parameters;
- (void)_continuityAppSuggestionChanged:(NSNotification *)notification;
- (void)_updateContentViewControllerClassFromSettings;
- (void)_cacheAppList;
- (void)_destroyAppListCache;
- (void)_rebuildAppListCache;
@end

@interface SBUIController : NSObject
+ (instancetype)sharedInstance;
- (BOOL)clickedMenuButton;
- (BOOL)handleMenuDoubleTap;
@end

typedef NS_ENUM(int, SBIconLocation) {
    SBIconLocationHomeScreen = 1,
    SBIconLocationCarPlay = 2,
    SBIconLocationDock = 3,
    SBIconLocationFolder = 6
};

@interface SBIcon : NSObject
- (NSString *)applicationBundleID;
- (NSString *)displayNameForLocation:(SBIconLocation)location;
- (UIImage *)getGenericIconImage:(int)format;
- (UIImage *)generateIconImage:(int)format;
- (void)launchFromLocation:(int)location context:(id)context;
- (BOOL)launchEnabled;
- (BOOL)isLeafIcon;
- (BOOL)isApplicationIcon;
@end

@interface SBLeafIcon : SBIcon
- (instancetype)initWithLeafIdentifier:(NSString *)leafIdentifier applicationBundleID:(NSString *)applicationIdentifier;
@end

@interface SBApplicationIcon : SBLeafIcon
@end

@interface SBFolder : NSObject
@end

@interface SBIconImageView : UIView {
    UIImageView *_overlayView;
}
@property(assign, nonatomic) CGFloat overlayAlpha;
@end

@protocol SBIconViewDelegate;

@interface SBIconView : UIView
@property(retain, nonatomic) SBIcon *icon;
@property(assign, nonatomic) id<SBIconViewDelegate> delegate;
@property(assign, nonatomic) CGFloat iconImageAlpha;
@property(assign, nonatomic) CGFloat iconAccessoryAlpha;
@property(assign, nonatomic) CGFloat iconLabelAlpha;
@property(assign, nonatomic, getter=isHighlighted) BOOL highlighted;
+ (CGSize)defaultIconSize;
- (instancetype)initWithContentType:(NSUInteger)contentType;
- (SBIconImageView *)_iconImageView;
@end

@protocol SBIconViewDelegate <NSObject>
@optional
- (CGFloat)scale;
- (CGFloat)iconLabelWidth;
- (BOOL)iconShouldAllowTap:(SBIconView *)iconView;
- (BOOL)iconViewDisplaysCloseBox:(SBIconView *)iconView;
- (BOOL)iconViewDisplaysBadges:(SBIconView *)iconView;
- (BOOL)icon:(SBIconView *)iconView canReceiveGrabbedIcon:(SBIconView *)grabbedIcon;
- (void)iconTapped:(SBIconView *)iconView;
- (void)iconCloseBoxTapped:(SBIconView *)iconView;
- (void)iconHandleLongPress:(SBIconView *)iconView;
- (void)icon:(SBIconView *)iconView openFolder:(SBFolder *)folder animated:(BOOL)animated;
- (void)iconTouchBegan:(SBIconView *)iconView;
- (void)icon:(SBIconView *)iconView touchMoved:(UITouch *)touch;
- (void)icon:(SBIconView *)iconView touchEnded:(BOOL)flag;
@end

@interface SBAppSwitcherIconView : SBIconView
@end

@interface SBIconModel : NSObject
@property(retain, nonatomic) NSDictionary *leafIconsByIdentifier;
- (SBLeafIcon *)leafIconForIdentifier:(NSString *)identifier;
- (SBApplicationIcon *)applicationIconForBundleIdentifier:(NSString *)identifier;
- (void)addIcon:(SBIcon *)icon;
- (void)addIconForApplication:(SBApplication *)application;
- (void)removeIcon:(SBIcon *)icon;
- (void)removeIconForIdentifier:(NSString *)identifier;
- (void)loadAllIcons;
- (BOOL)isIconVisible:(SBIcon *)icon;
@end

@interface SBIconController : NSObject
+ (SBIconController *)sharedInstance;
- (SBIconModel *)model;
@end

@interface SBControlCenterController : UIViewController
+ (instancetype)sharedInstance;
- (void)_handleShowControlCenterGesture:(SBScreenEdgePanGestureRecognizer *)gesture;
@end

@interface SBMediaController : NSObject
@property(assign, nonatomic, readonly) SBApplication *nowPlayingApplication;
+ (instancetype)sharedInstance;
@end

@interface SBReachabilityManager : NSObject
@property(assign, nonatomic, readonly) BOOL reachabilityModeActive;
+ (instancetype)sharedInstance;
- (void)deactivateReachabilityModeForObserver:(id)observer;
@end

@interface SBOrientationLockManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isLocked;
- (BOOL)lockOverrideEnabled;
- (UIInterfaceOrientation)userLockOrientation;
- (void)lock;
- (void)lock:(UIInterfaceOrientation)lock;
- (void)unlock;
- (void)setLockOverrideEnabled:(BOOL)enabled forReason:(NSString *)reason;
- (void)enableLockOverrideForReason:(NSString *)reason suggestOrientation:(UIInterfaceOrientation)orientation;
- (void)enableLockOverrideForReason:(NSString *)reason forceOrientation:(UIInterfaceOrientation)orientation;
- (void)updateLockOverrideForCurrentDeviceOrientation;
@end

typedef NS_ENUM(int, SBLockSource) {
    SBLockSourceLockButton = 0,
    SBLockSourceKeyboard = 1,
    SBLockSourceSmartCover = 2,
    SBLockSourceNotificationCenter = 3,
    SBLockSourceIdleTimer = 4,
    SBLockSourcePlugin = 5
};

@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
- (void)lockUIFromSource:(SBLockSource)source withOptions:(NSDictionary *)options;
- (void)unlockUIFromSource:(SBLockSource)source withOptions:(NSDictionary *)options;
@end

@interface SBBacklightController : NSObject
+ (instancetype)sharedInstance;
- (void)setBacklightFactor:(float)factor source:(SBLockSource)source;
- (void)animateBacklightToFactor:(float)factor duration:(NSTimeInterval)duration source:(SBLockSource)source completion:(UIViewAnimationCompletionBlock)completion;
- (NSSet *)idleTimerDisabledReasons;
- (void)setIdleTimerDisabled:(BOOL)disabled forReason:(NSString *)reason;
@end

@interface SpringBoard : UIApplication
- (SBApplication *)_accessibilityFrontMostApplication;
- (UIInterfaceOrientation)activeInterfaceOrientation;
- (BOOL)isLocked;
- (BOOL)isMenuDoubleTapAllowed;
@end

typedef NS_ENUM(NSInteger, SBAppSwitcherStyle) {
    SBAppSwitcherStyleDeck,
    SBAppSwitcherStyleMinimal
};

@interface SBAppSwitcherSettings : _UISettings
@property(assign) SBAppSwitcherStyle switcherStyle;
@property(assign) CGFloat presentAnimationMass;
@property(assign) CGFloat presentAnimationStiffness;
@property(assign) CGFloat presentAnimationDamping;
@property(assign) CGFloat dismissAnimationMass;
@property(assign) CGFloat dismissAnimationStiffness;
@property(assign) CGFloat dismissAnimationDamping;
@property(assign) CGFloat dismissAnimationEpsilon;
@end

@interface SBRootSettings : _UISettings
- (SBAppSwitcherSettings *)appSwitcherSettings;
@end

@interface SBPrototypeController : NSObject
+ (instancetype)sharedInstance;
- (SBRootSettings *)rootSettings;
@end

extern SpringBoard *KazeSpringBoard(void);
extern SBWorkspace *KazeWorkspace(void);
extern SBUIController *KazeUIController(void);
extern SBMainSwitcherViewController *KazeSwitcherController(void);
extern UIView *KazeContainerView(void);
extern BOOL KazeInterfaceIdiomPhone(void);
extern BOOL KazeSystemVersion(NSInteger major, NSInteger minor, NSInteger patch);

extern BOOL KazeDeviceLocked(void);
extern BOOL KazeSwitcherShowing(void);
extern BOOL KazeSwitcherAllowed(void);
extern BOOL KazeHasFrontmostApplication(void);

extern void KazeSwitcherLock(BOOL enabled);
extern void KazeSBAnimate(UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion);
extern void KazeAnimate(NSTimeInterval duration, UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion);
extern void KazeSpring(NSTimeInterval duration, CGFloat damping, CGFloat velocity, UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion);
extern void KazeTransit(UIView *view, NSTimeInterval duration, UIViewAnimationActionsBlock actions, UIViewAnimationCompletionBlock completion);
extern CGFloat KazeRubberbandValue(CGFloat value, CGFloat max);
extern id KazePreferencesValue(NSString *key);

typedef NS_ENUM(NSUInteger, KazeGestureRegion) {
    KazeGestureRegionCenter,
    KazeGestureRegionLeft,
    KazeGestureRegionRight,
};

typedef void (^KazeCallback)(void);
typedef BOOL (^KazeGestureConditionBlock)(KazeGestureRegion region);
typedef void (^KazeGestureHandlerBlock)(UIGestureRecognizerState state, CGPoint position, CGPoint velocity);

extern void KazeRegisterGesture(KazeGestureConditionBlock condition, KazeGestureHandlerBlock handler);
extern void KazePresentInteractiveSwitcherBegin(Class switcherClass, KazeCallback willAppearCallback, KazeCallback didAppearCallback);
extern void KazePresentInteractiveSwitcherEnd(void);
extern void KazeDismissInteractiveSwitcher(void);
extern void KazeSwitcherSetTransitionProgress(CGFloat progress);

extern KazeGestureConditionBlock KazeQuickSwitcherCondition;
extern KazeGestureHandlerBlock KazeQuickSwitcherHandler;
extern KazeGestureConditionBlock KazeHomeScreenCondition;
extern KazeGestureHandlerBlock KazeHomeScreenHandler;
extern KazeGestureConditionBlock KazeLockScreenCondition;
extern KazeGestureHandlerBlock KazeLockScreenHandler;

CHInline static NSString *KazeIdentifier(void) { return @"me.qusic.kaze"; }
CHInline static NSBundle *KazeBundle(void) { return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/KazePreferences.bundle"]; }
CHInline static NSString *KazeString(NSString *key) { return [KazeBundle() localizedStringForKey:key value:nil table:nil]; }
CHInline static UIImage *KazeImage(NSString *name) { return [UIImage imageNamed:name inBundle:KazeBundle()]; }

#define KazePreferencesKey(name) CHInline static NSString *k ## name ## Key(void) { return @#name; }
KazePreferencesKey(QuickSwitcherEnabled)
KazePreferencesKey(HotCornersEnabled)
KazePreferencesKey(AccessAppSwitcher)
KazePreferencesKey(DisableLockGesture)
KazePreferencesKey(InvertHotCorners)
#undef KazePreferencesKey

#define KazePreferencesKeyPrefix(name) CHInline static NSString *k ## name ## Key(NSString *subkey) { return [@#name"-" stringByAppendingString:subkey ?: @""]; }
KazePreferencesKeyPrefix(DisableInApps)
#undef KazePreferencesKeyPrefix

CHInline static NSUserDefaults *KazePreferences(void) {
    NSUserDefaults *preferences = [[NSUserDefaults alloc]initWithSuiteName:KazeIdentifier()];
    [preferences registerDefaults:@{
        kQuickSwitcherEnabledKey(): @YES,
        kHotCornersEnabledKey(): @YES,
    }];
    return preferences;
}
