#import "Headers.h"

static NSString * const updateBlockKey = @"updateBlock";
static NSString * const isShowingBlockKey = @"isShowingBlock";
static NSString * const isEnabledBlockKey = @"isEnabledBlock";

@implementation QSPSListController {
    NSArray *_allSpecifiers;
}

- (NSUserDefaults *)preferences {
    static NSUserDefaults *preferences;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preferences = KazePreferences();
    });
    return preferences;
}

- (NSArray *)newAllSpecifiers {
    return @[];
}

- (NSArray *)allSpecifiers {
    if (!_allSpecifiers) {
        _allSpecifiers = self.newAllSpecifiers;
    }
    return _allSpecifiers;
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = self.allSpecifiers.copy;
    }
    return _specifiers;
}

- (id)getPreferences:(PSSpecifier *)specifier {
    return [self.preferences objectForKey:specifier.identifier];
}

- (void)setPreferences:(id)value specifier:(PSSpecifier *)specifier {
    [self.preferences setObject:value forKey:specifier.identifier];
    [self updateSpecifiers:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSpecifiers:NO];
}

- (void)reloadSpecifiers {
    [super reloadSpecifiers];
    [self updateSpecifiers:NO];
}

- (void)updateSpecifiers:(BOOL)animated {
    NSInteger index = 0;
    for (PSSpecifier *specifier in self.allSpecifiers) {
        BOOL isShowing = ((QSPSSpecifierBoolBlock)specifier.userInfo[isShowingBlockKey])(specifier);
        BOOL isEnabled = ((QSPSSpecifierBoolBlock)specifier.userInfo[isEnabledBlockKey])(specifier);
        BOOL __block needsReload = [[specifier propertyForKey:@"enabled"]boolValue] != isEnabled;
        [specifier setProperty:@(isEnabled) forKey:@"enabled"];
        ((QSPSSpecifierUpdateBlock)specifier.userInfo[updateBlockKey])(specifier, ^(NSString *key, id value) {
            if (![[specifier propertyForKey:key]isEqual:value]) {
                [specifier setProperty:value forKey:key];
                needsReload = YES;
            }
        });
        if (isShowing != [self containsSpecifier:specifier]) {
            if (isShowing) {
                [self insertSpecifier:specifier atIndex:index animated:animated];
            } else {
                [self removeSpecifier:specifier animated:animated];
            }
        } else if (isShowing) {
            if (needsReload) {
                [self reloadSpecifier:specifier animated:animated];
            }
        }
        if (isShowing) {
            index++;
        }
    }
}

- (PSSpecifier *)newSpecifierForIdentifier:(NSString *)identifier name:(NSString *)name image:(UIImage *)image cell:(PSCellType)cellType setupBlock:(QSPSSpecifierSetupBlock)setupBlock updateBlock:(QSPSSpecifierUpdateBlock)updateBlock isShowingBlock:(QSPSSpecifierBoolBlock)isShowingBlock isEnabledBlock:(QSPSSpecifierBoolBlock)isEnabledBlock {
    static QSPSSpecifierSetupBlock const defaultSetupBlock = ^(PSSpecifier *specifier) { return; };
    static QSPSSpecifierUpdateBlock const defaultUpdateBlock = ^(PSSpecifier *specifier, QSPSSpecifierSetPropertyBlock setProperty) { return; };
    static QSPSSpecifierBoolBlock const defaultBoolBlock = ^(PSSpecifier *specifier) { return YES; };
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setPreferences:specifier:) get:@selector(getPreferences:) detail:nil cell:cellType edit:Nil];
    [specifier setIdentifier:identifier];
    [specifier setProperty:image forKey:@"iconImage"];
    [specifier setProperty:@YES forKey:@"enabled"];
    (setupBlock ?: defaultSetupBlock)(specifier);
    specifier.userInfo = @{
        updateBlockKey: updateBlock ?: defaultUpdateBlock,
        isShowingBlockKey: isShowingBlock ?: defaultBoolBlock,
        isEnabledBlockKey: isEnabledBlock ?: defaultBoolBlock
    };
    return specifier;
}

- (PSSpecifier *)newGroupSpecifierForIdentifier:(NSString *)identifier name:(NSString *)name footer:(NSString *)footer updateBlock:(QSPSSpecifierUpdateBlock)updateBlock {
    PSSpecifier *specifier = [self newSpecifierForIdentifier:identifier name:name image:nil cell:PSGroupCell setupBlock:NULL updateBlock:updateBlock isShowingBlock:NULL isEnabledBlock:NULL];
    [specifier setProperty:footer forKey:@"footerText"];
    return specifier;
}

@end
