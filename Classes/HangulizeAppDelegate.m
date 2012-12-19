//
//  HangulizeAppDelegate.m
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

#import "HangulizeAppDelegate.h"
#import "HangulizeViewController.h"

#import "CaulyHelper.h"

@implementation HangulizeAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window bringSubviewToFront:self.bannerView];
    CaulyGlobalSet(@"iYEufJHrmW", self.viewController, self.bannerView, nil);

    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    self.bannerView = nil;
    self.viewController = nil;
    self.window = nil;
    [super dealloc];
}

@end
