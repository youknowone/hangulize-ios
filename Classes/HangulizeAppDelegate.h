//
//  HangulizeAppDelegate.h
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

#import "CaulyProtocol.h"

#define HGPreferenceKeyLastSelectedLanguageIndex	@"HGLastSelectedLanguageIndex"
#define HGPreferenceKeyLastWord						@"HGLastWord"
#define HGPreferenceKeyLastResult					@"HGLastResult"

@class HangulizeViewController;

@interface HangulizeAppDelegate : NSObject <UIApplicationDelegate, CaulyProtocol> {
    UIWindow *window;
    HangulizeViewController *viewController;
	
	UIView *bannerView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HangulizeViewController *viewController;
@property (nonatomic, retain) IBOutlet UIView *bannerView;

@end

