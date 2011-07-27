//
//  HangulizeViewController.m
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

#import "HangulizeAppDelegate.h"
#import "HangulizeViewController.h"

@implementation HangulizeViewController
@synthesize languages, result;

- (void) viewDidLoad {
	[super viewDidLoad];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithFormat:@"http://www.hangulize.org/langs"]];
	[request addValue:@"application/x-plist" forHTTPHeaderField:@"Accept"];
	[request addValue:NSLocalizedStringFromTable(@"__LOCALE__", @"common", @"") forHTTPHeaderField:@"Accept-Language"];
	
	NSError *error = nil;
	NSDictionary *languagesDictionary = [NSDictionary dictionaryWithContentsOfURLRequest:request options:0 format:NULL error:&error];
	if ( error != nil || languagesDictionary == nil || ![[languagesDictionary objectForKey:@"success"] boolValue] ) {
		UIAlertView *alert = [[UIAlertView alloc] initNoticeWithTitle:NSLocalizedStringFromTable(@"Network Error", @"common", @"") message:NSLocalizedStringFromTable(@"Network error when getting languages list from server.", @"hangulize", @"") cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"common", @"")];
		[alert show];
		[alert release];
		
		[NSTimer delayedTimerWithTimeInterval:3.0 target:[UIApplication sharedApplication] selector:@selector(finalize)];
		
		return;
	}
	
	wordSearchBar.text = [[ICPreference mainDictionary] objectForKey:HGPreferenceKeyLastWord];
	if ( wordSearchBar.text == nil ) wordSearchBar.text = @"Hangulize";
	
	self.result = [[ICPreference mainDictionary] objectForKey:HGPreferenceKeyLastResult];
	if ( self.result == nil ) self.result = @"한글라이즈";
	
	self.languages = [languagesDictionary objectForKey:@"langs"];
	assert([languages count] == [[languagesDictionary objectForKey:@"length"] integerValue]);

	[languagePickerView reloadAllComponents];
	
	NSNumber *lastSelectedLanguageIndexNumber = [[ICPreference mainDictionary] objectForKey:HGPreferenceKeyLastSelectedLanguageIndex];
	[languagePickerView selectRow:lastSelectedLanguageIndexNumber?[lastSelectedLanguageIndexNumber integerValue]:rand()%[languages count] inComponent:0 animated:NO];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	UIView *appBannerView = [(HangulizeAppDelegate *)[[UIApplication sharedApplication] delegate] bannerView];
	[appBannerView removeFromSuperview];
	[bannerView addSubview:appBannerView];
}

#pragma mark IBAction

- (void) showPreference {
	[self presentModalViewController:preferenceViewController animated:YES];
}

- (void) showExample {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithFormat:@"http://www.hangulize.org/example?lang=%@", [selectedLanguage objectForKey:@"code"]]];
	[request addValue:@"application/x-plist" forHTTPHeaderField:@"Accept"];

	tempRequest = request;

	[activityIndicator startAnimating];
	[NSTimer delayedTimerWithTimeInterval:0.1 target:self selector:@selector(showExampleWithTempRequest)];
}

- (void) showExampleWithTempRequest {
	NSError *error = nil;
	NSDictionary *example = [NSDictionary dictionaryWithContentsOfURLRequest:tempRequest options:0 format:NULL error:&error];
	[tempRequest release];
	tempRequest = nil;
	if ( error ) {
        [self networkErrorOccured:error];
    }
	wordSearchBar.text = [example objectForKey:@"word"];
	self.result = [example objectForKey:@"result"];
	[self preferenceChanged];
	[activityIndicator stopAnimating];
}

- (void) preferenceChanged {
	[layoutTableView reloadData];
	[[ICPreference mainDictionary] setObject:[NSNumber numberWithInteger:[languagePickerView selectedRowInComponent:0]] forKey:HGPreferenceKeyLastSelectedLanguageIndex];
	[[ICPreference mainDictionary] setObject:wordSearchBar.text forKey:HGPreferenceKeyLastWord];
	[[ICPreference mainDictionary] setObject:result forKey:HGPreferenceKeyLastResult];
	[[ICPreference mainPreference] writeToFile];
}

#pragma mark UISearchBar delegate

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar endEditing:YES];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar endEditing:YES];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithFormat:@"http://www.hangulize.org/?lang=%@&word=%@", [selectedLanguage objectForKey:@"code"], [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

	[request addValue:@"application/x-plist" forHTTPHeaderField:@"Accept"];
	
	tempRequest = request;
	
	[activityIndicator startAnimating];
	[NSTimer delayedTimerWithTimeInterval:0.1 target:self selector:@selector(queryWithTempRequest)];
}

- (void) queryWithTempRequest {
	NSError *error = nil;
	NSDictionary *hangulized = [NSDictionary dictionaryWithContentsOfURLRequest:tempRequest options:0 format:NULL error:&error];
	[tempRequest release];
	tempRequest = nil;
	if ( error ) {
		[self networkErrorOccured:error];
	}
	self.result = [hangulized objectForKey:@"result"];
	[self preferenceChanged];
	[activityIndicator stopAnimating];
}

- (void) networkErrorOccured:(NSError *)error {
	[UIAlertView showNoticeWithTitle:NSLocalizedStringFromTable(@"Network Error", @"common", @"")
							 message:NSLocalizedStringFromTable(@"Network error occured. Retry it please.", @"common", @"")
				   cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"common", @"")];
}

#pragma mark UITableView protocols

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0: return NSLocalizedStringFromTable(@"Result", @"hangulize", @"");
		case 1: return NSLocalizedStringFromTable(@"Preferences", @"hangulize", @"");
	}
	ICAssert(NO);
	return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 2;
		case 1:
			return 1;
	}
	ICAssert(NO);
	return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = nil;
	UITableViewCell *cell = nil;
	switch (indexPath.section) {
		case 0: switch (indexPath.row) {
			case 0:
				cellIdentifier = @"copyable";
				if ((cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier]) == nil ) {
					cell = [[ICTableViewCellCopyable alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    ((ICTableViewCellCopyable *)cell).delegate = self;
				}
				cell.textLabel.text = result;
				break;
			case 1:
				cellIdentifier = @"button";
				if ((cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier]) == nil ) {
					cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
					cell.textLabel.textColor = [UIColor grayColor];
					cell.textLabel.textAlignment = UITextAlignmentCenter;
					cell.textLabel.text = NSLocalizedStringFromTable(@"Show other Example", @"hangulize", @"");
				}
				break;
		} break;
		case 1:
			cellIdentifier = @"selectable";
			if ((cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier]) == nil ) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = NSLocalizedStringFromTable(@"Language", @"hangulize", @"");
			}
			NSInteger selectedLanguageIndex = [languagePickerView selectedRowInComponent:0];
			[[ICPreference mainDictionary] setObject:[NSNumber numberWithInteger:selectedLanguageIndex] forKey:HGPreferenceKeyLastSelectedLanguageIndex];
			selectedLanguage = [languages objectAtIndex:selectedLanguageIndex];
			cell.detailTextLabel.text = [selectedLanguage objectForKey:@"label"];
			break;
	}
	assert(cellIdentifier);
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0: switch (indexPath.row) {
			case 0:
                
				[tableView deselectRowAtIndexPath:indexPath animated:NO];
				break;
			case 1:
				[self showExample];
				break;
		}	break;
		case 1:
			[self showPreference];
			break;
	}
}

#pragma mark copyable table view cell



@end
