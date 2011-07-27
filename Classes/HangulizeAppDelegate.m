//
//  HangulizeAppDelegate.m
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

#import "HangulizeAppDelegate.h"
#import "HangulizeViewController.h"

#import "CaulyViewController.h"

@implementation HangulizeAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize bannerView;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
	
	[CaulyViewController initCauly:(id<CaulyProtocol>)self setLogLevel:CL_RELEASE];
	
	if( [CaulyViewController requestBannerAD:nil caulyParentview:bannerView xPos:0.0f yPos:0.0f] == FALSE ) {
		ICLog(TRUE, @"requestBannerAD failed");
	}
	
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[bannerView release];
    [viewController release];
    [window release];
    [super dealloc];
}

#pragma mark Cauly

- (NSString *) devKey {
	return @"iYEufJHrmW";
}

@end
