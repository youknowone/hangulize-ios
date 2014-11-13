//
//  HangulizeViewController.h
//  Hangulize
//
//  Created by youknowone on 11. 1. 24..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

@class PreferenceViewController;
@interface HangulizeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UIATableViewCellCopyableDelegate> {
    NSDictionary *selectedLanguage;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UITableView *layoutTableView;
    
    // preference
    PreferenceViewController *preferenceViewController;
    
    // current status
    IBOutlet UISearchBar *wordSearchBar;
}

@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) NSString *result;

- (IBAction)showPreference;
- (IBAction)preferenceChanged;
- (IBAction)showExample;

- (void)networkErrorOccured:(NSError *)error;

@end
