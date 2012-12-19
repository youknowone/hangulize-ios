//
//  PreferenceViewController.h
//  Hangulize
//
//  Created by youknowone on 11. 1. 29..
//  Copyright 2011 3rddev Inc. All rights reserved.
//

@interface PreferenceViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource> 

@property (nonatomic, assign) HangulizeViewController *hangulizeViewController;
@property (nonatomic, retain) IBOutlet UIPickerView *languagePickerView;

- (IBAction) done;

@end

@interface LanguageView: UIView {    
    IBOutlet UILabel *nameLabel, *codeLabel;
}

- (id)initWithName:(NSString *)name code:(NSString *)code;
+ (LanguageView *)viewWithName:(NSString *)name code:(NSString *)code;

@end