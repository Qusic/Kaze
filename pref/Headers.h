#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../src/Headers.h"

typedef enum PSCellType {
    PSGroupCell,
    PSLinkCell,
    PSLinkListCell,
    PSListItemCell,
    PSTitleValueCell,
    PSSliderCell,
    PSSwitchCell,
    PSStaticTextCell,
    PSEditTextCell,
    PSSegmentCell,
    PSGiantIconCell,
    PSGiantCell,
    PSSecureEditTextCell,
    PSButtonCell,
    PSEditTextViewCell,
} PSCellType;

@interface PSSpecifier : NSObject {
@public
    id target;
    SEL getter;
    SEL setter;
    SEL action;
    Class detailControllerClass;
    PSCellType cellType;
    Class editPaneClass;
    UIKeyboardType keyboardType;
    UITextAutocapitalizationType autoCapsType;
    UITextAutocorrectionType autoCorrectionType;
    int textFieldType;
@private
    NSString *_name;
    NSArray *_values;
    NSDictionary *_titleDict;
    NSDictionary *_shortTitleDict;
    id _userInfo;
    NSMutableDictionary *_properties;
}
@property (retain) NSMutableDictionary *properties;
@property (retain) NSString *identifier;
@property (retain) NSString *name;
@property (retain) id userInfo;
@property (retain) id titleDictionary;
@property (retain) id shortTitleDictionary;
@property (retain) NSArray *values;
+ (instancetype)preferenceSpecifierNamed:(NSString *)title target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(PSCellType)cell edit:(Class)edit;
+ (PSSpecifier *)groupSpecifierWithName:(NSString *)title;
+ (PSSpecifier *)emptyGroupSpecifier;
+ (UITextAutocapitalizationType)autoCapsTypeForString:(PSSpecifier *)string;
+ (UITextAutocorrectionType)keyboardTypeForString:(PSSpecifier *)string;
- (id)propertyForKey:(NSString *)key;
- (void)setProperty:(id)property forKey:(NSString *)key;
- (void)removePropertyForKey:(NSString *)key;
- (void)loadValuesAndTitlesFromDataSource;
- (void)setValues:(NSArray *)values titles:(NSArray *)titles;
- (void)setValues:(NSArray *)values titles:(NSArray *)titles shortTitles:(NSArray *)shortTitles;
- (void)setupIconImageWithPath:(NSString *)path;
- (NSString *)identifier;
- (void)setTarget:(id)target;
- (void)setKeyboardType:(UIKeyboardType)type autoCaps:(UITextAutocapitalizationType)autoCaps autoCorrection:(UITextAutocorrectionType)autoCorrection;
@end

@interface PSViewController : UIViewController {
    PSSpecifier *_specifier;
}
@property (retain) PSSpecifier *specifier;
- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
@end

@interface PSListController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *_specifiers;
    UITableView *_table;
}
@property (retain, nonatomic) NSArray *specifiers;
- (UITableView *)table;
- (NSBundle *)bundle;
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
- (PSSpecifier *)specifierForID:(NSString *)identifier;
- (PSSpecifier *)specifierAtIndex:(NSInteger)index;
- (NSArray *)specifiersForIDs:(NSArray *)identifiers;
- (NSArray *)specifiersInGroup:(NSInteger)group;
- (BOOL)containsSpecifier:(PSSpecifier *)specifier;
- (NSInteger)numberOfGroups;
- (NSInteger)rowsForGroup:(NSInteger)group;
- (NSInteger)indexForRow:(NSInteger)row inGroup:(NSInteger)group;
- (BOOL)getGroup:(NSInteger *)group row:(NSInteger *)row ofSpecifier:(PSSpecifier *)specifier;
- (BOOL)getGroup:(NSInteger *)group row:(NSInteger *)row ofSpecifierID:(NSString *)identifier;
- (BOOL)getGroup:(NSInteger *)group row:(NSInteger *)row ofSpecifierAtIndex:(NSInteger )index;
- (void)addSpecifier:(PSSpecifier *)specifier;
- (void)addSpecifiersFromArray:(NSArray *)array;
- (void)addSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated;
- (void)addSpecifiersFromArray:(NSArray *)array animated:(BOOL)animated;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifier:(PSSpecifier *)afterSpecifier;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifierID:(NSString *)afterSpecifierID;
- (void)insertSpecifier:(PSSpecifier *)specifier atIndex:(NSInteger)index;
- (void)insertSpecifier:(PSSpecifier *)specifier atEndOfGroup:(NSInteger)index;
- (void)insertContiguousSpecifiers:(NSArray *)spcifiers afterSpecifier:(PSSpecifier *)afterSpecifier;
- (void)insertContiguousSpecifiers:(NSArray *)spcifiers afterSpecifierID:(NSString *)afterSpecifierID;
- (void)insertContiguousSpecifiers:(NSArray *)spcifiers atIndex:(NSInteger)index;
- (void)insertContiguousSpecifiers:(NSArray *)spcifiers atEndOfGroup:(NSInteger)index;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifier:(PSSpecifier *)afterSpecifier animated:(BOOL)animated;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifierID:(NSString *)afterSpecifierID animated:(BOOL)animated;
- (void)insertSpecifier:(PSSpecifier *)specifier atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)insertSpecifier:(PSSpecifier *)specifier atEndOfGroup:(NSInteger)index animated:(BOOL)animated;
- (void)insertContiguousSpecifiers:(NSArray *)spcifiers afterSpecifier:(PSSpecifier *)afterSpecifier animated:(BOOL)animated;
- (void)insertContiguousSpecifiers:(NSArray *)spcifiers afterSpecifierID:(NSString *)afterSpecifierID animated:(BOOL)animated;
- (void)insertContiguousSpecifiers:(NSArray *)spcifiers atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)insertContiguousSpecifiers:(NSArray *)spcifiers atEndOfGroup:(NSInteger)index animated:(BOOL)animated;
- (void)replaceContiguousSpecifiers:(NSArray *)oldSpecifiers withSpecifiers:(NSArray *)newSpecifiers;
- (void)replaceContiguousSpecifiers:(NSArray *)oldSpecifiers withSpecifiers:(NSArray *)newSpecifiers animated:(BOOL)animated;
- (void)removeSpecifier:(PSSpecifier *)specifier;
- (void)removeSpecifierID:(NSString *)identifier;
- (void)removeSpecifierAtIndex:(NSInteger)index;
- (void)removeLastSpecifier;
- (void)removeContiguousSpecifiers:(NSArray *)specifiers;
- (void)removeSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated;
- (void)removeSpecifierID:(NSString *)identifier animated:(BOOL)animated;
- (void)removeSpecifierAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeLastSpecifierAnimated:(BOOL)animated;
- (void)removeContiguousSpecifiers:(NSArray *)specifiers animated:(BOOL)animated;
- (void)reloadSpecifier:(PSSpecifier *)specifier;
- (void)reloadSpecifierID:(NSString *)identifier;
- (void)reloadSpecifierAtIndex:(NSInteger)index;
- (void)reloadSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated;
- (void)reloadSpecifierID:(NSString *)identifier animated:(BOOL)animated;
- (void)reloadSpecifierAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)reloadSpecifiers;
- (void)updateSpecifiers:(NSArray *)oldSpecifiers withSpecifiers:(NSArray *)newSpecifiers;
- (void)updateSpecifiersInRange:(NSRange)range withSpecifiers:(NSArray *)newSpecifiers;
@end

@interface PSListItemsController : PSListController
@end

typedef void (^QSPSSpecifierSetPropertyBlock)(NSString *key, id value);
typedef void (^QSPSSpecifierSetupBlock)(PSSpecifier *specifier);
typedef void (^QSPSSpecifierUpdateBlock)(PSSpecifier *specifier, QSPSSpecifierSetPropertyBlock setProperty);
typedef BOOL (^QSPSSpecifierBoolBlock)(PSSpecifier *specifier);

@interface QSPSListController : PSListController
- (NSUserDefaults *)preferences;
- (NSArray *)newAllSpecifiers;
- (PSSpecifier *)newSpecifierForIdentifier:(NSString *)identifier name:(NSString *)name image:(UIImage *)image cell:(PSCellType)cellType setupBlock:(QSPSSpecifierSetupBlock)setupBlock updateBlock:(QSPSSpecifierUpdateBlock)updateBlock isShowingBlock:(QSPSSpecifierBoolBlock)isShowingBlock isEnabledBlock:(QSPSSpecifierBoolBlock)isEnabledBlock;
- (PSSpecifier *)newGroupSpecifierForIdentifier:(NSString *)identifier name:(NSString *)name footer:(NSString *)footer updateBlock:(QSPSSpecifierUpdateBlock)updateBlock;
@end
