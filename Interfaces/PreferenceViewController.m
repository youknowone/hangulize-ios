//
//  PreferenceViewController.m
//  Hangulize
//
//  Created by youknowone on 11. 1. 29..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

#import "HangulizeAppDelegate.h"
#import "HangulizeViewController.h"
#import "PreferenceViewController.h"


@implementation PreferenceViewController

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	UIView *appBannerView = [(HangulizeAppDelegate *)[[UIApplication sharedApplication] delegate] bannerView];
	[appBannerView removeFromSuperview];
	[bannerView addSubview:appBannerView];
}

#pragma mark IBAction

- (void) done {
	[self dismissModalViewControllerAnimated:YES];
	[hangulizeViewController preferenceChanged];
}

#pragma mark UIPickerView protocols

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [hangulizeViewController.languages count];
}

- (UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	NSDictionary *language = [hangulizeViewController.languages objectAtIndex:row];
	
	NSString *code = [language objectForKey:@"iso639-1"];
	if ( code == nil ) code = [language objectForKey:@"iso639-3"];
	
	return [LanguageView viewWithName:[language objectForKey:@"label"] code:code];
}

- (CGFloat) pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 36.0f;
}

#pragma mark UITableView datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedStringFromTable(@"Languages", @"hangulize", @"");
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	assert(NO);
	return nil;
}

@end


@implementation LanguageView

- (id)initWithName:(NSString *)name code:(NSString *)code {
	UIViewController *vc = [[UIViewController alloc] initWithNibName:@"LanguageTitleViewContainer" bundle:nil];
	self = [vc.view retain];
	[vc release];
	if ( self != nil ) {
		nameLabel.text = name;
		codeLabel.text = [NSString stringWithFormat:@"%@", code];
	}
	return self;
}

+ (LanguageView *)viewWithName:(NSString *)name code:(NSString *)code {
	return [[[self alloc] initWithName:name code:code] autorelease];
}

@end
