//
//  HangulizeAppDelegate.m
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "AppDelegate.h"
#import "HangulizeViewController.h"

@implementation AppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Crashlytics startWithAPIKey:@"1b5d8443c3eabba778b0d97bff234647af846181"];
    return YES;
}

#pragma mark -
#pragma mark Memory management


@end
