//
//  HangulizeViewController.h
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

@interface HangulizeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ICTableViewCellCopyableDelegate> {
	NSArray *languages;
	NSDictionary *selectedLanguage;
	
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UITableView *layoutTableView;
	IBOutlet UIView *bannerView;
	
	// preference
	IBOutlet UIPickerView *languagePickerView;
	IBOutlet UIViewController *preferenceViewController;
	
	// current status
	IBOutlet UISearchBar *wordSearchBar;
	NSString *result;
	
	// temporary variables
	NSMutableURLRequest *tempRequest;
}

@property (nonatomic, retain) NSArray *languages;
@property (nonatomic, retain) NSString *result;

- (IBAction) showPreference;
- (IBAction) preferenceChanged;
- (IBAction) showExample;

- (void) networkErrorOccured:(NSError *)error;

@end
