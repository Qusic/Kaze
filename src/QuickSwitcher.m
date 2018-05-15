#import "Headers.h"

@interface KazeQuickSwitcherDeckViewController : SBDeckSwitcherViewController
@property(assign, nonatomic) CGFloat normalizedOffset;
- (void)setNormalizedOffset:(CGFloat)normalizedOffset animated:(BOOL)animated completion:(UIViewAnimationCompletionBlock)completion;
@end

@interface KazeQuickSwitcherIconListView : UIView
- (void)loadApplications:(NSArray *)applications startingIndex:(NSUInteger)startingIndex isReversed:(BOOL)isReversed;
- (void)setHighlightPoint:(CGPoint)highlightPoint;
- (void)setHintShowing:(BOOL)hintShowing;
- (NSUInteger)highlightIndex;
- (CGFloat)normalizedHighlightOffset;
- (void)setScrollingHandler:(void (^)(void))handler;
- (void)stopScrolling;
@end

static KazeQuickSwitcherIconListView *iconListView;

CHDeclareClass(SBDeckSwitcherViewController)
CHDeclareClass(KazeQuickSwitcherDeckViewController)
CHDeclareClass(SBIconController)
CHDeclareClass(SBIconView)

static void gestureBegan(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iconListView = [[KazeQuickSwitcherIconListView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [iconListView setScrollingHandler:^{
            if ([KazeSwitcherController()._contentViewController isKindOfClass:CHClass(KazeQuickSwitcherDeckViewController)]) {
                ((KazeQuickSwitcherDeckViewController *)KazeSwitcherController()._contentViewController).normalizedOffset = iconListView.normalizedHighlightOffset;
            }
        }];
    });
    KazePresentInteractiveSwitcherBegin(CHClass(KazeQuickSwitcherDeckViewController), ^{
        NSArray *displayItems = CHIvar(KazeSwitcherController(), _displayItems, NSArray * const);
        NSMutableArray *applications = [NSMutableArray array];
        [displayItems enumerateObjectsUsingBlock:^(SBDisplayItem *item, NSUInteger index, BOOL *stop) {
            [applications addObject:item.displayIdentifier];
        }];
        NSUInteger startingIndex = [displayItems indexOfObject:KazeSwitcherController()._initialDisplayItem];
        [iconListView loadApplications:applications startingIndex:startingIndex isReversed:[KazePreferencesValue(kInvertHotCornersKey()) boolValue]];
    }, ^{
        CGSize size = KazeContainerView().bounds.size;
        iconListView.frame = CGRectMake(0, size.height, size.width, size.height);
        [KazeContainerView() addSubview:iconListView];
        dispatch_async(dispatch_get_main_queue(), ^{
            KazeSBAnimate(^{
                iconListView.frame = CGRectMake(0, 0, size.width, size.height);
            }, NULL);
        });
    });
}

static void gestureChanged(CGPoint position) {
    CGFloat viewHeight = KazeContainerView().bounds.size.height;
    CGFloat maxTouchHeight = viewHeight / 3;
    CGFloat touchHeight = viewHeight - position.y;
    CGFloat highlightHeight = KazeRubberbandValue(touchHeight, maxTouchHeight);
    CGFloat step = highlightHeight / maxTouchHeight;
    KazeSwitcherSetTransitionProgress(step);
    CGPoint highlightPoint = CGPointMake(position.x, iconListView.bounds.size.height - highlightHeight);
    [iconListView setHighlightPoint:highlightPoint];
    [iconListView setHintShowing:step > 1.0];
    if ([KazeSwitcherController()._contentViewController isKindOfClass:CHClass(KazeQuickSwitcherDeckViewController)]) {
        ((KazeQuickSwitcherDeckViewController *)KazeSwitcherController()._contentViewController).normalizedOffset = iconListView.normalizedHighlightOffset;
    }
}

static void gestureEnded(CGPoint velocity) {
    KazePresentInteractiveSwitcherEnd();
    [iconListView stopScrolling];
    BOOL forward = [KazePreferencesValue(kAccessAppSwitcherKey()) boolValue] && velocity.y <= 0;
    KazeSBAnimate(^{
        CGSize size = KazeContainerView().bounds.size;
        iconListView.frame = CGRectMake(0, size.height, size.width, size.height);
        if (forward) {
            KazeSwitcherSetTransitionProgress(0);
            [KazeSwitcherController() _updateContentViewControllerClassFromSettings];
            object_setClass(KazeSwitcherController()._contentViewController, CHIvar(KazeSwitcherController(), _contentViewControllerClass, Class));
            [KazeSwitcherController() _rebuildAppListCache];
            SBDeckSwitcherViewController *deckController = (SBDeckSwitcherViewController *)KazeSwitcherController()._contentViewController;
            deckController.displayItems = CHIvar(KazeSwitcherController(), _displayItems, NSArray * const);
            KazeSwitcherSetTransitionProgress(1);
            [deckController _updateScrollViewFrameAndContentSize];
            [deckController _updateScrollViewContentOffsetToCenterIndex:iconListView.highlightIndex animated:NO completion:NULL];
        } else {
            KazeSwitcherSetTransitionProgress(0);
            NSUInteger highlightIndex = iconListView.highlightIndex;
            KazeSwitcherController()._returnToDisplayItem = CHIvar(KazeSwitcherController(), _displayItems, NSArray * const)[highlightIndex];
            [(KazeQuickSwitcherDeckViewController *)KazeSwitcherController()._contentViewController _updateScrollViewContentOffsetToCenterIndex:highlightIndex animated:NO completion:NULL];
        }
    }, ^(BOOL finished) {
        if (!forward) {
            KazeDismissInteractiveSwitcher();
        }
        [iconListView removeFromSuperview];
    });
}

static void gestureCancelled(void) {
    KazePresentInteractiveSwitcherEnd();
    [iconListView stopScrolling];
    KazeSBAnimate(^{
        CGSize size = KazeContainerView().bounds.size;
        iconListView.frame = CGRectMake(0, size.height, size.width, size.height);
        KazeSwitcherSetTransitionProgress(0);
        NSUInteger highlightIndex = [CHIvar(KazeSwitcherController(), _displayItems, NSArray * const)indexOfObject:KazeSwitcherController()._returnToDisplayItem];
        [(KazeQuickSwitcherDeckViewController *)KazeSwitcherController()._contentViewController _updateScrollViewContentOffsetToCenterIndex:highlightIndex animated:NO completion:NULL];
    }, ^(BOOL finished) {
        KazeDismissInteractiveSwitcher();
        [iconListView removeFromSuperview];
    });
}

KazeGestureConditionBlock KazeQuickSwitcherCondition = ^BOOL(KazeGestureRegion region) {
    return [KazePreferencesValue(kQuickSwitcherEnabledKey()) boolValue]
        && region == ([KazePreferencesValue(kInvertHotCornersKey()) boolValue] ? KazeGestureRegionRight : KazeGestureRegionLeft)
        && !KazeDeviceLocked()
        && !KazeSwitcherShowing()
        && KazeSwitcherAllowed();
};

KazeGestureHandlerBlock KazeQuickSwitcherHandler = ^void(UIGestureRecognizerState state, CGPoint position, CGPoint velocity) {
    switch (state) {
        case UIGestureRecognizerStateBegan:
            gestureBegan();
            KazeSBAnimate(^{ gestureChanged(position); }, NULL);
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

CHPropertyGetter(KazeQuickSwitcherDeckViewController, normalizedOffset, CGFloat) {
    SBAppSwitcherScrollView *scrollView = CHIvar(self, _scrollView, SBAppSwitcherScrollView * const);
    CGFloat normalizationFactor = scrollView.contentSize.width - scrollView.bounds.size.width;
    CGFloat offset = scrollView.contentOffset.x;
    return normalizationFactor > 0 ? offset / normalizationFactor : 0;
}

CHPropertySetter(KazeQuickSwitcherDeckViewController, setNormalizedOffset, CGFloat, normalizedOffset) {
    [self setNormalizedOffset:normalizedOffset animated:NO completion:NULL];
}

CHOptimizedMethod(3, new, void, KazeQuickSwitcherDeckViewController, setNormalizedOffset, CGFloat, normalizedOffset, animated, BOOL, animated, completion, UIViewAnimationCompletionBlock, completion) {
    SBAppSwitcherScrollView *scrollView = CHIvar(self, _scrollView, SBAppSwitcherScrollView * const);
    CGFloat normalizationFactor = scrollView.contentSize.width - scrollView.bounds.size.width;
    CGFloat offset = normalizedOffset * normalizationFactor;
    [self _setContentOffset:CGPointMake(offset, 0) animated:animated completion:completion];
}

static CGFloat const cardMargin = 16;
static CGFloat const minScale = 0.5;
static CGFloat const minDepth = -0.4;

CHOptimizedMethod(1, super, CGSize, KazeQuickSwitcherDeckViewController, _scrollViewContentSizeForDisplayItemCount, NSUInteger, displayItemCount) {
    CGSize size = self.view.bounds.size;
    size.width = MAX((size.width + cardMargin) * displayItemCount - cardMargin, 0);
    return size;
}

CHOptimizedMethod(7, super, CGRect, KazeQuickSwitcherDeckViewController, _frameForIndex, NSUInteger, index, displayItemsCount, NSUInteger, count, transitionParameters, SBTransitionParameters, parameters, scrollProgress, double, progress, ignoringScrollOffset, BOOL, ignoring1, ignoringKillingAdjustments, BOOL, ignoring2, ignoringPinning, BOOL, ignoring3) {
    CGSize size = self.view.bounds.size;
    CGFloat x = (size.width + cardMargin) * index;
    CGRect frame = (CGRect){{x, 0}, size};
    return frame;
}

CHOptimizedMethod(4, super, double, KazeQuickSwitcherDeckViewController, _depthForIndex, NSUInteger, index, displayItemsCount, NSUInteger, count, scrollProgress, double, scrollProgress, ignoringKillOffset, BOOL, ignoringKillOffset) {
    CGFloat effectiveIndex = index;
    CGFloat effectiveHighlightIndex = scrollProgress * (count - 1);
    CGFloat distance = ABS(effectiveIndex - effectiveHighlightIndex);
    CGFloat depth = distance > 1 ? minDepth : (-0.5 * (cos(distance * M_PI) - 1)) * minDepth;
    return depth;
}

CHOptimizedMethod(1, super, double, KazeQuickSwitcherDeckViewController, _scaleForPresentedProgress, CGFloat, presentedProgress) {
    return 1;
}

CHOptimizedMethod(2, super, CGFloat, KazeQuickSwitcherDeckViewController, _blurForIndex, NSUInteger, index, scrollProgress, double, progress) {
    return 0;
}

CHOptimizedMethod(1, super, CGFloat, KazeQuickSwitcherDeckViewController, _titleAndIconOpacityForIndex, NSUInteger, index) {
    return 0;
}

CHOptimizedMethod(2, super, CGFloat, KazeQuickSwitcherDeckViewController, _titleOpacityForIndex, NSUInteger, index, scrollProgress, double, scrollProgress) {
    return 0;
}

CHOptimizedMethod(4, super, double, KazeQuickSwitcherDeckViewController, _scrollProgressForIndex, NSUInteger, index, displayItemsCount, NSUInteger, count, depth, double, depth, ignoringKillOffset, BOOL, ignoringKillOffset) {
    return count > 1 ? ((CGFloat)index) / (count - 1) : 0;
}

CHOptimizedMethod(0, super, double, KazeQuickSwitcherDeckViewController, _normalizedScrollProgress) {
    return self.normalizedOffset;
}

CHOptimizedMethod(3, super, void, KazeQuickSwitcherDeckViewController, _updateScrollViewContentOffsetToCenterIndex, NSUInteger, centerIndex, animated, BOOL, animated, completion, UIViewAnimationCompletionBlock, completion) {
    [self setNormalizedOffset:[self _scrollProgressForIndex:centerIndex displayItemsCount:self.displayItems.count depth:0 ignoringKillOffset:YES] animated:animated completion:completion];
}

CHOptimizedMethod(1, super, NSUInteger, KazeQuickSwitcherDeckViewController, _indexForPresentationOrDismissalIsPresenting, BOOL, isPresenting) {
    return CHSuper(1, KazeQuickSwitcherDeckViewController, _indexForPresentationOrDismissalIsPresenting, NO);
}

CHOptimizedMethod(1, super, BOOL, KazeQuickSwitcherDeckViewController, _isAboveTransitioningItemDuringPresentation, SBDisplayItem *, displayItem) {
    return NO;
}

CHOptimizedMethod(1, super, BOOL, KazeQuickSwitcherDeckViewController, _displayItemWantsToBeKeptInViewHierarchy, SBDisplayItem *, displayItem) {
    if (ABS([self.displayItems indexOfObject:displayItem] - iconListView.highlightIndex) <= 2) {
        return YES;
    }
    return CHSuper(1, KazeQuickSwitcherDeckViewController, _displayItemWantsToBeKeptInViewHierarchy, displayItem);
}

CHOptimizedMethod(1, super, void, KazeQuickSwitcherDeckViewController, setTransitionParameters, SBTransitionParameters, parameters) {
    CHSuper(1, KazeQuickSwitcherDeckViewController, setTransitionParameters, parameters);
    parameters = CHIvar(self, _transitionParameters, SBTransitionParameters);
    CGSize size = self.view.bounds.size;
    CGFloat scale = 1 * (1 - parameters.progress) + minScale * parameters.progress;
    CGFloat translation = - size.height * (1 - scale) * 0.5;
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale), CGAffineTransformMakeTranslation(0, translation));
    CHIvar(self, _scrollView, SBAppSwitcherScrollView * const).transform = transform;
}

@interface KazeQuickSwitcherIconListView () <UICollectionViewDataSource, UICollectionViewDelegate>
- (SBLeafIcon *)iconAtIndex:(NSUInteger)index;
@end

@interface KazeQuickSwitcherIconListViewLayout : UICollectionViewLayout
- (void)prepareForPresentation;
- (void)setReversedLayout:(BOOL)isReversed;
- (void)setHighlightPoint:(CGPoint)highlightPoint;
- (void)setHintShowing:(BOOL)hintShowing;
- (CGFloat)xPositionForIndex:(NSUInteger)index;
- (NSUInteger)indexForXPosition:(CGFloat)x;
- (CGPoint)contentOffsetForStartingIndex:(NSUInteger)index;
- (NSUInteger)highlightIndex;
- (CGFloat)normalizedHighlightOffset;
- (void)setScrollingHandler:(void (^)(void))handler;
- (void)startScrolling:(NSInteger)direction;
- (void)stopScrolling;
@end

@interface KazeQuickSwitcherIconView : UICollectionViewCell
- (void)loadIcon:(SBIcon *)icon;
@end

@interface KazeQuickSwitcherHighlightView : UICollectionReusableView
@end

@interface KazeQuickSwitcherHighlightViewLayoutAttributes : UICollectionViewLayoutAttributes
@property(copy, nonatomic) NSString *titleText;
@property(assign, nonatomic) BOOL hintShowing;
@end

@implementation KazeQuickSwitcherIconListView {
    NSArray *_applications;
    UICollectionView *_collectionView;
    KazeQuickSwitcherIconListViewLayout *_collectionViewLayout;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bounds = {CGPointZero, frame.size};
        self.userInteractionEnabled = NO;
        _collectionViewLayout = [[KazeQuickSwitcherIconListViewLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:bounds collectionViewLayout:_collectionViewLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = nil;
        _collectionView.clipsToBounds = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:KazeQuickSwitcherIconView.class forCellWithReuseIdentifier:NSStringFromClass(KazeQuickSwitcherIconView.class)];
        [_collectionView registerClass:KazeQuickSwitcherHighlightView.class forSupplementaryViewOfKind:NSStringFromClass(KazeQuickSwitcherHighlightView.class) withReuseIdentifier:NSStringFromClass(KazeQuickSwitcherHighlightView.class)];
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    _collectionView.frame = self.bounds;
}

- (void)loadApplications:(NSArray *)applications startingIndex:(NSUInteger)startingIndex isReversed:(BOOL)isReversed {
    _applications = applications;
    [_collectionView reloadData];
    [self setContentOffsetToStartingIndex:startingIndex isReversed:isReversed];
    [_collectionViewLayout prepareForPresentation];
}

- (SBLeafIcon *)iconAtIndex:(NSUInteger)index {
    return [CHSharedInstance(SBIconController).model leafIconForIdentifier:_applications[index]];
}

- (void)setHighlightPoint:(CGPoint)highlightPoint {
    _collectionViewLayout.highlightPoint = [self convertPoint:highlightPoint toView:_collectionView];
}

- (void)setHintShowing:(BOOL)hintShowing {
    _collectionViewLayout.hintShowing = hintShowing;
}

- (void)setContentOffsetToStartingIndex:(NSUInteger)index isReversed:(BOOL)isReversed {
    [_collectionViewLayout setReversedLayout:isReversed];
    _collectionView.contentOffset = [_collectionViewLayout contentOffsetForStartingIndex:index];
}

- (NSUInteger)highlightIndex {
    return _collectionViewLayout.highlightIndex;
}

- (CGFloat)normalizedHighlightOffset {
    return _collectionViewLayout.normalizedHighlightOffset;
}

- (void)setScrollingHandler:(void (^)(void))handler {
    [_collectionViewLayout setScrollingHandler:handler];
}

- (void)stopScrolling {
    [_collectionViewLayout stopScrolling];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _applications.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KazeQuickSwitcherIconView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(KazeQuickSwitcherIconView.class) forIndexPath:indexPath];
    [cell loadIcon:[self iconAtIndex:indexPath.item]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    KazeQuickSwitcherHighlightView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(KazeQuickSwitcherHighlightView.class) forIndexPath:indexPath];
    return view;
}

@end

@implementation KazeQuickSwitcherIconListViewLayout {
    CGSize _viewMargin;
    CGFloat _iconMargin;
    CGSize _largeIconSize;
    CGSize _smallIconSize;
    CGFloat _iconSpacing;
    CGFloat _iconOffset;
    CGFloat _normalizedZeroBound;
    CGFloat _scrollingArea;
    BOOL _reversedLayout;
    CGPoint _highlightPoint;
    BOOL _hintShowing;
    BOOL _scrollingAreaAccessed;
    NSTimer *_scrollingTimer;
    void (^_scrollingHandler)(void);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _viewMargin = CGSizeMake(23.0, 11.0);
        _iconMargin = 9.0;
        _largeIconSize = [CHClass(SBIconView) defaultIconSize];
        _smallIconSize = CGSizeMake(_largeIconSize.width * 0.45, _largeIconSize.height * 0.45);
        _iconSpacing = _smallIconSize.width + _iconMargin * 2;
        _iconOffset = 20.0;
        _normalizedZeroBound = _viewMargin.width + _iconSpacing * 0.5;
        _scrollingArea = _viewMargin.width + _iconMargin + _largeIconSize.width * 0.5;
    }
    return self;
}

- (void)prepareForPresentation {
    _scrollingAreaAccessed = NO;
}

- (void)setReversedLayout:(BOOL)isReversed {
    _reversedLayout = isReversed;
    self.collectionView.transform = CGAffineTransformMakeScale(_reversedLayout ? -1 : 1, 1);
}

- (void)setHighlightPoint:(CGPoint)highlightPoint {
    CGFloat x = MIN(MAX(highlightPoint.x, _normalizedZeroBound), self.collectionViewContentSize.width - _normalizedZeroBound);
    CGFloat settledX = [self xPositionForIndex:[self indexForXPosition:x]];
    x = settledX + pow(x - settledX, 3) / pow(_iconSpacing * 0.5, 2);
    _highlightPoint = CGPointMake(x, highlightPoint.y);
    [self invalidateLayout];
    [self updateScrollingState];
}

- (void)setHintShowing:(BOOL)hintShowing {
    _hintShowing = hintShowing;
    [self invalidateLayout];
}

- (CGSize)collectionViewContentSize {
    UICollectionView *collectionView = self.collectionView;
    NSInteger count = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:0];
    CGFloat width = _viewMargin.width * 2 + _iconSpacing * count;
    CGFloat height = collectionView.bounds.size.height;
    return CGSizeMake(width, height);
}

- (CGFloat)xPositionForIndex:(NSUInteger)index {
    return _viewMargin.width + _iconSpacing * ((CGFloat)index + 0.5);
}

- (NSUInteger)indexForXPosition:(CGFloat)x {
    return floor((x - _viewMargin.width) / _iconSpacing);
}

- (CGFloat)xOffsetWithLeftmostIndex:(NSUInteger)index {
    return _iconSpacing * index;
}

- (CGFloat)xOffsetWithRightmostIndex:(NSUInteger)index {
    return _iconSpacing * (index + 1) + _viewMargin.width * 2 - self.collectionView.bounds.size.width;
}

- (CGPoint)contentOffsetForStartingIndex:(NSUInteger)index {
    return CGPointMake([self xOffsetWithLeftmostIndex:index], 0);
}

- (NSUInteger)highlightIndex {
    return [self indexForXPosition:_highlightPoint.x];
}

- (CGFloat)normalizedHighlightOffset {
    return (_highlightPoint.x - _normalizedZeroBound) / (self.collectionViewContentSize.width - _normalizedZeroBound * 2);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.item;
    CGFloat modelX = [self xPositionForIndex:index];
    CGFloat distance = modelX - _highlightPoint.x;
    CGSize size = _smallIconSize;
    if (ABS(distance) < _iconSpacing) {
        CGFloat upScaleStep = (cos(ABS(distance) / _iconSpacing * M_PI) + 1.0) * 0.5;
        size.width += (_largeIconSize.width - _smallIconSize.width) * upScaleStep;
        size.height += (_largeIconSize.height - _smallIconSize.height) * upScaleStep;
    }
    CGFloat offsetX = 0;
    if (distance < -_iconSpacing) {
        offsetX = -_iconOffset;
    } else if (distance > _iconSpacing) {
        offsetX = _iconOffset;
    } else {
        offsetX = _iconOffset * sin(distance / _iconSpacing * M_PI_2);
    }
    CGFloat x = modelX + offsetX;
    static CGFloat const constant = 2;
    CGFloat lowestY = self.collectionView.bounds.size.height - _viewMargin.height - _iconMargin - _smallIconSize.height * 0.5;
    CGFloat highestY = _highlightPoint.y - _largeIconSize.height - _iconOffset;
    CGFloat y = highestY + (lowestY - highestY) * (1.0 - 1.0 / (ABS(distance) * constant / (lowestY - highestY) + 1.0));
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.center = CGPointMake(x, y);
    attributes.size = size;
    attributes.transform = CGAffineTransformMakeScale(_reversedLayout ? -1 : 1, 1);
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = _largeIconSize.width + _iconMargin * 2;
    CGFloat height = self.collectionView.bounds.size.height;
    CGFloat x = _highlightPoint.x - width / 2;
    CGFloat y = _highlightPoint.y - _largeIconSize.height - _iconOffset - _largeIconSize.height * 0.5 - _iconMargin - _viewMargin.height;
    KazeQuickSwitcherHighlightViewLayoutAttributes *attributes = [KazeQuickSwitcherHighlightViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    attributes.frame = CGRectMake(x, y, width, height);
    attributes.zIndex = -1;
    attributes.transform = CGAffineTransformMakeScale(_reversedLayout ? -1 : 1, 1);
    attributes.titleText = [[(KazeQuickSwitcherIconListView *)self.collectionView.dataSource iconAtIndex:self.highlightIndex]displayNameForLocation:SBIconLocationHomeScreen];
    attributes.hintShowing = _hintShowing;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    return [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    return [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
    UICollectionView *collectionView = self.collectionView;
    NSInteger count = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:0];
    NSInteger minIndex = MAX([self indexForXPosition:CGRectGetMinX(rect)], 0);
    NSInteger maxIndex = MIN([self indexForXPosition:CGRectGetMaxX(rect)], count - 1);
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger index = minIndex; index <= maxIndex; index++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    }
    return indexPaths;
}

- (NSIndexPath *)indexPathForHighlightViewInRect:(CGRect)rect {
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    [[self indexPathsForItemsInRect:rect]enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger index, BOOL *stop) {
        [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }];
    [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:NSStringFromClass(KazeQuickSwitcherHighlightView.class) atIndexPath:[self indexPathForHighlightViewInRect:rect]]];
    return layoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)updateScrollingState {
    CGRect bounds = self.collectionView.bounds;
    CGFloat leftBoundDistance = _highlightPoint.x - CGRectGetMinX(bounds);
    CGFloat rightBoundDistance = CGRectGetMaxX(bounds) - _highlightPoint.x;
    if (leftBoundDistance < _scrollingArea) {
        if (_scrollingAreaAccessed) {
            [self startScrolling:-1];
        }
    } else if (rightBoundDistance < _scrollingArea) {
        if (_scrollingAreaAccessed) {
            [self startScrolling:+1];
        }
    } else {
        [self stopScrolling];
        _scrollingAreaAccessed = YES;
    }
}

- (void)startScrolling:(NSInteger)direction {
    if (_scrollingTimer.valid && [_scrollingTimer.userInfo integerValue] == direction) {
        return;
    }
    [self stopScrolling];
    _scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(scrollingTimerFired) userInfo:@(direction) repeats:YES];
    _scrollingTimer.tolerance = 0.1;
}

- (void)stopScrolling {
    if (_scrollingTimer == nil) {
        return;
    }
    [_scrollingTimer invalidate];
    _scrollingTimer = nil;
}

- (void)scrollingTimerFired {
    UICollectionView *collectionView = self.collectionView;
    NSInteger direction = [_scrollingTimer.userInfo integerValue];
    CGRect bounds = collectionView.bounds;
    NSInteger count = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:0];
    CGFloat oldXOffset = collectionView.contentOffset.x;
    CGFloat newXOffset = oldXOffset;
    if (direction == -1) {
        NSInteger nextHighlightIndex = MIN(MAX([self indexForXPosition:CGRectGetMinX(bounds) - 1], 0), count - 1);
        newXOffset = [self xOffsetWithLeftmostIndex:nextHighlightIndex];
    } else if (direction == 1) {
        NSInteger nextHighlightIndex = MIN(MAX([self indexForXPosition:CGRectGetMaxX(bounds) + 1], 0), count - 1);
        newXOffset = [self xOffsetWithRightmostIndex:nextHighlightIndex];
    }
    if (oldXOffset == newXOffset) {
        [self stopScrolling];
        return;
    }
    KazeAnimate(0.25, ^{
        [self setHighlightPoint:CGPointMake(_highlightPoint.x + (newXOffset - oldXOffset), _highlightPoint.y)];
        collectionView.contentOffset = CGPointMake(newXOffset, 0);
        if (_scrollingHandler) {
            _scrollingHandler();
        }
    }, NULL);
}

- (void)setScrollingHandler:(void (^)(void))handler {
    _scrollingHandler = handler;
}

@end

@implementation KazeQuickSwitcherIconView {
    SBIconView *_iconView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iconView = [CHAlloc(SBIconView) initWithContentType:0];
        [self.contentView addSubview:_iconView];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint scale = CGPointMake(bounds.size.width / _iconView.bounds.size.width, bounds.size.height / _iconView.bounds.size.height);
    _iconView.center = center;
    _iconView.transform = CGAffineTransformMakeScale(scale.x, scale.y);
}

- (void)loadIcon:(SBIcon *)icon {
    if (![_iconView.icon.applicationBundleID isEqualToString:icon.applicationBundleID]) {
        _iconView.icon = icon;
        _iconView.iconLabelAlpha = 0;
    }
}

@end

@implementation KazeQuickSwitcherHighlightView {
    _UIBackdropView *_backgroundView;
    UILabel *_titleView;
    UILabel *_hintLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 7;
        self.layer.masksToBounds = YES;
        self.layer.allowsGroupBlending = NO;
        _backgroundView = [[_UIBackdropView alloc]initWithStyle:0x80c];
        _backgroundView.groupName = KazeIdentifier();
        _backgroundView.appliesOutputSettingsAnimationDuration = 1;
        _titleView = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleView.font = [UIFont systemFontOfSize:12];
        _titleView.textColor = [UIColor whiteColor];
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.adjustsFontSizeToFitWidth = YES;
        _titleView.minimumScaleFactor = 0.6;
        _titleView.layer.shadowOpacity = 0.6;
        _titleView.layer.shadowRadius = 3.0;
        _titleView.layer.shadowOffset = CGSizeZero;
        _titleView.layer.shadowColor = [UIColor blackColor].CGColor;
        _hintLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _hintLabel.text = @"←→";
        _hintLabel.font = [UIFont systemFontOfSize:14];
        _hintLabel.textColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.numberOfLines = 1;
        _hintLabel.layer.compositingFilter = @"plusD";
        _hintLabel.alpha = 0;
        [self addSubview:_backgroundView];
        [self addSubview:_titleView];
        [self addSubview:_hintLabel];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect frame = self.bounds;
    _backgroundView.frame = frame;
    frame.size.height = 22;
    frame.size.width -= 2;
    frame.origin.x += 1;
    _titleView.frame = frame;
    [_hintLabel sizeToFit];
    _hintLabel.center = CGPointMake(frame.size.width / 2.0, 140);
}

- (void)applyLayoutAttributes:(KazeQuickSwitcherHighlightViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    [self setTitleText:layoutAttributes.titleText];
    [self setHintShowing:layoutAttributes.hintShowing];
}

- (void)setTitleText:(NSString *)titleText {
    if (![_titleView.text isEqualToString:titleText]) {
        KazeTransit(_titleView, 0.25, ^{
            _titleView.text = titleText;
        }, NULL);
    }
}

- (void)setHintShowing:(BOOL)showing {
    CGFloat alpha = showing ? 1.0 : 0.0;
    if (_hintLabel.alpha != alpha) {
        KazeAnimate(1.0, ^{
            _hintLabel.alpha = alpha;
        }, NULL);
    }
}

@end

@implementation KazeQuickSwitcherHighlightViewLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    KazeQuickSwitcherHighlightViewLayoutAttributes *copy = [super copyWithZone:zone];
    copy.titleText = self.titleText;
    copy.hintShowing = self.hintShowing;
    return copy;
}

- (BOOL)isEqual:(id)object {
    return [super isEqual:object] && [object isKindOfClass:self.class]
    && ((self.titleText == nil && [object titleText] == nil) || [self.titleText isEqualToString:[object titleText]])
    && self.hintShowing == [object hintShowing];
}

@end

CHConstructor {
    @autoreleasepool {
        CHLoadLateClass(SBDeckSwitcherViewController);
        CHRegisterClass(KazeQuickSwitcherDeckViewController, SBDeckSwitcherViewController) {
            CHHookProperty(KazeQuickSwitcherDeckViewController, normalizedOffset, setNormalizedOffset);
            CHHook(3, KazeQuickSwitcherDeckViewController, setNormalizedOffset, animated, completion);
            CHHook(1, KazeQuickSwitcherDeckViewController, _scrollViewContentSizeForDisplayItemCount);
            CHHook(7, KazeQuickSwitcherDeckViewController, _frameForIndex, displayItemsCount, transitionParameters, scrollProgress, ignoringScrollOffset, ignoringKillingAdjustments, ignoringPinning);
            CHHook(4, KazeQuickSwitcherDeckViewController, _depthForIndex, displayItemsCount, scrollProgress, ignoringKillOffset);
            CHHook(1, KazeQuickSwitcherDeckViewController, _scaleForPresentedProgress);
            CHHook(2, KazeQuickSwitcherDeckViewController, _blurForIndex, scrollProgress);
            CHHook(1, KazeQuickSwitcherDeckViewController, _titleAndIconOpacityForIndex);
            CHHook(2, KazeQuickSwitcherDeckViewController, _titleOpacityForIndex, scrollProgress);
            CHHook(4, KazeQuickSwitcherDeckViewController, _scrollProgressForIndex, displayItemsCount, depth, ignoringKillOffset);
            CHHook(0, KazeQuickSwitcherDeckViewController, _normalizedScrollProgress);
            CHHook(3, KazeQuickSwitcherDeckViewController, _updateScrollViewContentOffsetToCenterIndex, animated, completion);
            CHHook(1, KazeQuickSwitcherDeckViewController, _indexForPresentationOrDismissalIsPresenting);
            CHHook(1, KazeQuickSwitcherDeckViewController, _isAboveTransitioningItemDuringPresentation);
            CHHook(1, KazeQuickSwitcherDeckViewController, _displayItemWantsToBeKeptInViewHierarchy);
            CHHook(1, KazeQuickSwitcherDeckViewController, setTransitionParameters);
        }
        CHLoadLateClass(SBIconController);
        CHLoadLateClass(SBIconView);
    }
}
