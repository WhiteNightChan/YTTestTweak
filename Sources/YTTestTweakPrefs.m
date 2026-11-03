#import "YTTestTweakPrefs.h"

static NSString * const kYTTestTweakHidePreviewCommentSectionKey =
    @"YTTestTweak_hidePreviewCommentSection";

static inline NSUserDefaults *YTTestTweakDefaults(void) {
    return [NSUserDefaults standardUserDefaults];
}

BOOL YTTestTweakHidePreviewCommentSectionEnabled(void) {
    return [YTTestTweakDefaults() boolForKey:kYTTestTweakHidePreviewCommentSectionKey];
}

void YTTestTweakSetHidePreviewCommentSectionEnabled(BOOL enabled) {
    [YTTestTweakDefaults() setBool:enabled
                           forKey:kYTTestTweakHidePreviewCommentSectionKey];
    [YTTestTweakDefaults() synchronize];
}
