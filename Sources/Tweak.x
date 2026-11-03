#import <UIKit/UIKit.h>

#import <YouTubeHeader/_ASDisplayView.h>

#import "YTTestTweakPrefs.h"

%group gYTTestTweak

%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;

    NSString *identifier = self.accessibilityIdentifier;

    if (YTTestTweakHidePreviewCommentSectionEnabled() &&
        ([identifier isEqualToString:@"id.ui.comments_entry_point_teaser"] ||
         [identifier isEqualToString:@"id.ui.comments_entry_point_simplebox"])) {
        self.hidden = YES;
        self.opaque = YES;
        self.userInteractionEnabled = NO;

        CGRect frame = self.frame;
        frame.size.height = 0;
        self.frame = frame;

        if (self.superview) {
            [self.superview layoutIfNeeded];
        }

        [self setNeedsLayout];
        [self removeFromSuperview];
        return;
    }
}
%end

%end

%ctor {
    %init(gYTTestTweak);
}
