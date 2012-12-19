//
//  HangulizeViewController.m
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

#import "HangulizeAppDelegate.h"
#import "HangulizeViewController.h"

#import "PreferenceViewController.h"

@implementation HangulizeViewController
@synthesize languages, result;

- (void)dealloc {
    self.languages = nil;
    self.result = nil;
    [super dealloc];
}

- (void)awakeFromNib {
    preferenceViewController = [[PreferenceViewController alloc] initWithNibName:@"PreferenceViewController" bundle:nil];
    preferenceViewController.hangulizeViewController = self;
    [preferenceViewController view]; // force load

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    wordSearchBar.text = [userDefault objectForKey:HGPreferenceKeyLastWord];
    if (wordSearchBar.text == nil) {
        wordSearchBar.text = @"Hangulize";
    }

    self.result = [userDefault objectForKey:HGPreferenceKeyLastResult];
    if (self.result == nil) {
        self.result = @"한글라이즈";
    }

    NSNumber *lastSelectedLanguageIndexNumber = [userDefault objectForKey:HGPreferenceKeyLastSelectedLanguageIndex];
    NSInteger selectedLanguageIndex = lastSelectedLanguageIndexNumber ? [lastSelectedLanguageIndexNumber integerValue] : (rand() % languages.count);
    [preferenceViewController.languagePickerView selectRow:selectedLanguageIndex inComponent:0 animated:NO];

    [layoutTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    self.languages = [userDefault objectForKey:HGPreferenceKeyLanguages];

    // refresh languages
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:@"http://www.hangulize.org/langs".URL];
    [request addValue:@"application/x-plist" forHTTPHeaderField:@"Accept"];
    [request addValue:NSLocalizedStringFromTable(@"__LOCALE__", @"common", @"") forHTTPHeaderField:@"Accept-Language"];
    
    NSError *error = nil;
    NSDictionary *languagesDictionary = [NSDictionary dictionaryWithContentsOfURLRequest:request format:NULL error:&error];
    if (self.languages == nil && (error != nil || languagesDictionary == nil || ![[languagesDictionary objectForKey:@"success"] boolValue])) {
        UIAlertView *alert = [[UIAlertView alloc] initNoticeWithTitle:NSLocalizedStringFromTable(@"Network Error", @"common", @"") message:NSLocalizedStringFromTable(@"Network error when getting languages list from server.", @"hangulize", @"") cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"common", @"")];
        [alert show];
        [alert release];
        
        [NSTimer delayedTimerWithTimeInterval:3.0 target:[UIApplication sharedApplication] selector:@selector(finalize)];

        return;
    }

    self.languages = [languagesDictionary objectForKey:@"langs"];
    dassert([languages count] == [[languagesDictionary objectForKey:@"length"] integerValue]);
}

#pragma mark IBAction

- (void)showPreference {
    [self presentModalViewController:preferenceViewController animated:YES];
}

- (void)showExample {
    [activityIndicator startAnimating];
    NSThread *thread = [[[NSThread alloc] initWithTarget:self selector:@selector(showExampleBackground) object:nil] autorelease];
    [thread start];
}

- (void)showExampleBackground {
    NSURL *URL = [@"http://www.hangulize.org/example?lang=%@" format:[selectedLanguage objectForKey:@"code"]].URL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request addValue:@"application/x-plist" forHTTPHeaderField:@"Accept"];

    NSError *error = nil;
    NSDictionary *example = [NSDictionary dictionaryWithContentsOfURLRequest:request format:NULL error:&error];

    [self performSelectorOnMainThread:@selector(showExampleFinished:) withObject:example ? example : error waitUntilDone:NO];
}

- (void)showExampleFinished:(id)data {
    [activityIndicator stopAnimating];
    if ([data isKindOfClass:[NSError class]]) {
        [self networkErrorOccured:data];
        return;
    }
    wordSearchBar.text = [data objectForKey:@"word"];
    self.result = [data objectForKey:@"result"];
    [self preferenceChanged];
}

- (void)preferenceChanged {
    [layoutTableView reloadData];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger selectedLanguageIndex = [preferenceViewController.languagePickerView selectedRowInComponent:0];
    [userDefault setObject:[NSNumber numberWithInteger:selectedLanguageIndex] forKey:HGPreferenceKeyLastSelectedLanguageIndex];
    [userDefault setObject:wordSearchBar.text forKey:HGPreferenceKeyLastWord];
    [userDefault setObject:result forKey:HGPreferenceKeyLastResult];
    [userDefault synchronize];
}

#pragma mark UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    [activityIndicator startAnimating];
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(queryBackground) object:nil];
    [thread start];
}

- (void)queryBackground {
    NSString *code = [selectedLanguage objectForKey:@"code"];
    NSString *text = [wordSearchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[@"http://www.hangulize.org/?lang=%@&word=%@" format:code, text].URL];

    [request addValue:@"application/x-plist" forHTTPHeaderField:@"Accept"];
    NSError *error = nil;
    NSDictionary *hangulized = [NSDictionary dictionaryWithContentsOfURLRequest:request format:NULL error:&error];

    [self performSelectorOnMainThread:@selector(queryFinished:) withObject:hangulized ? hangulized : error waitUntilDone:NO];
}

- (void)queryFinished:(id)data {
    [activityIndicator stopAnimating];
    if ([data isKindOfClass:[NSError class]]) {
        [self networkErrorOccured:data];
        return;
    }
    self.result = [data objectForKey:@"result"];
    [self preferenceChanged];
}

- (void)networkErrorOccured:(NSError *)error {
    [UIAlertView showNoticeWithTitle:NSLocalizedStringFromTable(@"Network Error", @"common", @"")
                             message:NSLocalizedStringFromTable(@"Network error occured. Retry it please.", @"common", @"")
                   cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"common", @"")];
}

#pragma mark UITableView protocols

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return NSLocalizedStringFromTable(@"Result", @"hangulize", @"");
        case 1: return NSLocalizedStringFromTable(@"Preferences", @"hangulize", @"");
    }
    dassert(NO);
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 1;
    }
    dassert(NO);
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = nil;
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0: switch (indexPath.row) {
            case 0:
                cellIdentifier = @"copyable";
                if ((cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier]) == nil ) {
                    UIATableViewCellCopyable *ccell = [[UIATableViewCellCopyable alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//                    ccell.delegate = self;
                    cell = ccell;
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
            NSInteger selectedLanguageIndex = [preferenceViewController.languagePickerView selectedRowInComponent:0];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:selectedLanguageIndex] forKey:HGPreferenceKeyLastSelectedLanguageIndex];
            selectedLanguage = [languages objectAtIndex:selectedLanguageIndex];
            cell.detailTextLabel.text = [selectedLanguage objectForKey:@"label"];
            break;
    }
    assert(cellIdentifier);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: switch (indexPath.row) {
            case 0:
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                break;
            case 1:
                [self showExample];
                break;
        }    break;
        case 1:
            [self showPreference];
            break;
    }
}

#pragma mark copyable table view cell



@end
