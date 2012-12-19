//
//  HangulizeAppDelegate.h
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

#define HGPreferenceKeyLastSelectedLanguageIndex    @"HGLastSelectedLanguageIndex"
#define HGPreferenceKeyLanguages                    @"HGLanguages"
#define HGPreferenceKeyLastWord                     @"HGLastWord"
#define HGPreferenceKeyLastResult                   @"HGLastResult"

@class HangulizeViewController;

@interface HangulizeAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HangulizeViewController *viewController;
@property (nonatomic, retain) IBOutlet UIView *bannerView;

@end

