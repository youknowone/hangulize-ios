//
//  HangulizeAppDelegate.m
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

@import Fabric;
@import Crashlytics;

#import "AppDelegate.h"
#import "HangulizeViewController.h"

@implementation AppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[CrashlyticsKit]];
    return YES;
}

#pragma mark -
#pragma mark Memory management


@end
