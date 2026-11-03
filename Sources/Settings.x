#import <objc/runtime.h>
#import <YouTubeHeader/YTIIcon.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import "YTTestTweakPrefs.h"

#define SECTION_HEADER(headerTitle)                                                                                    \
    [sectionItems addObject:[objc_getClass("YTSettingsSectionItem")                                                    \
                                          itemWithTitle:@"\t"                                                          \
                                       titleDescription:headerTitle                                                    \
                                accessibilityIdentifier:nil                                                            \
                                        detailTextBlock:nil                                                            \
                                            selectBlock:^BOOL(YTSettingsCell *cell, NSUInteger sectionItemIndex) {     \
                                                return NO;                                                             \
                                            }]]

#ifndef PACKAGE_VERSION
#define PACKAGE_VERSION @"Unknown"
#endif

static inline NSString *YTTestTweakVersionLabel(void) {
    return PACKAGE_VERSION;
}

static NSString *YTTestTweakLocalizationBundlePath(void) {
    NSString *rootlessBundlePath =
        @"/var/jb/Library/Application Support/YTTestTweak.bundle";

    if ([[NSFileManager defaultManager] fileExistsAtPath:rootlessBundlePath]) {
        return rootlessBundlePath;
    }

    NSString *sideloadBundlePath =
        [[NSBundle mainBundle] pathForResource:@"YTTestTweak"
                                        ofType:@"bundle"];
    if (sideloadBundlePath.length > 0) {
        return sideloadBundlePath;
    }

    return nil;
}

static NSBundle *YTTestTweakLocalizationBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *bundlePath = YTTestTweakLocalizationBundlePath();
        if (bundlePath.length > 0) {
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
    });

    return bundle;
}

static NSString *YTTestTweakLocalizedText(NSString *key) {
    NSBundle *bundle = YTTestTweakLocalizationBundle();
    if (!bundle) {
        return key;
    }

    return [bundle localizedStringForKey:key
                                   value:key
                                   table:nil];
}

static const NSInteger YTTestTweakSection = 'yttt';

@interface NSObject (YTTestTweakSettings)
- (void)reloadData;
@end

@interface YTSettingsSectionItemManager (YTTestTweak)
- (void)updateYTTestTweakSectionWithEntry:(id)entry;
@end

%hook YTAppSettingsPresentationData

+ (NSArray<NSNumber *> *)settingsCategoryOrder {
    NSArray<NSNumber *> *order = %orig;
    if (!order) {
        return @[@(YTTestTweakSection)];
    }

    NSMutableArray<NSNumber *> *mutableOrder = order.mutableCopy;
    if ([mutableOrder containsObject:@(YTTestTweakSection)]) {
        return mutableOrder.copy;
    }

    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        [mutableOrder insertObject:@(YTTestTweakSection) atIndex:insertIndex + 1];
    } else {
        [mutableOrder addObject:@(YTTestTweakSection)];
    }

    return mutableOrder.copy;
}

%end

%hook YTSettingsGroupData

- (NSArray<NSNumber *> *)orderedCategories {
    if (self.type != 1 ||
        class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks))) {
        return %orig;
    }

    NSArray *original = %orig;
    NSMutableArray *mutableCategories =
        original ? original.mutableCopy : [NSMutableArray array];

    if (![mutableCategories containsObject:@(YTTestTweakSection)]) {
        [mutableCategories insertObject:@(YTTestTweakSection) atIndex:0];
    }

    return mutableCategories.copy;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYTTestTweakSectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = nil;

    @try {
        delegate = [self valueForKey:@"_dataDelegate"];
    } @catch (id ex) {}

    if (!delegate) {
        @try {
            delegate = [self valueForKey:@"_settingsViewControllerDelegate"];
        } @catch (id ex) {}
    }

    if (!delegate) {
        return;
    }

    NSMutableArray *sectionItems = [NSMutableArray array];

    SECTION_HEADER(YTTestTweakLocalizedText(@"SETTINGS_RESTART_REQUIRED_HEADER"));

    SECTION_HEADER(YTTestTweakLocalizedText(@"SETTINGS_WATCH_UI_HEADER"));

    YTSettingsSectionItem *hidePreviewCommentSectionItem =
        [%c(YTSettingsSectionItem) switchItemWithTitle:YTTestTweakLocalizedText(@"SETTINGS_HIDE_COMMENT_PREVIEW_TITLE")
                                      titleDescription:YTTestTweakLocalizedText(@"SETTINGS_HIDE_COMMENT_PREVIEW_DESCRIPTION")
                               accessibilityIdentifier:@"YTTestTweakHideCommentPreview"
                                              switchOn:YTTestTweakHidePreviewCommentSectionEnabled()
                                           switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                                               YTTestTweakSetHidePreviewCommentSectionEnabled(enabled);

                                               if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                   [delegate reloadData];
                                               }

                                               return YES;
                                           }
                                         settingItemId:0];
    [sectionItems addObject:hidePreviewCommentSectionItem];

    YTSettingsSectionItem *versionItem =
        [%c(YTSettingsSectionItem) itemWithTitle:YTTestTweakLocalizedText(@"SETTINGS_VERSION_TITLE")
                                titleDescription:nil
                         accessibilityIdentifier:@"YTTestTweakVersion"
                                 detailTextBlock:^NSString *{
                                     return YTTestTweakVersionLabel();
                                 }
                                     selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                                         return YES;
                                     }];
    [sectionItems addObject:versionItem];

    if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_SETTINGS;

        [delegate setSectionItems:sectionItems
                      forCategory:YTTestTweakSection
                            title:YTTestTweakLocalizedText(@"SETTINGS_SECTION_TITLE")
                             icon:icon
                 titleDescription:nil
                     headerHidden:NO];
    } else {
        [delegate setSectionItems:sectionItems
                      forCategory:YTTestTweakSection
                            title:YTTestTweakLocalizedText(@"SETTINGS_SECTION_TITLE")
                 titleDescription:nil
                     headerHidden:NO];
    }
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTTestTweakSection) {
        [self updateYTTestTweakSectionWithEntry:entry];
        return;
    }

    %orig;
}

%end

%ctor {
    %init;
}