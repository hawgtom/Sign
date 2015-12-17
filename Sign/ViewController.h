//
//  ViewController.h
//  Sign
//
//  Created by Gowtham on 25/11/15.
//  Copyright © 2015 Gowtham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *username;

@property (strong, nonatomic) IBOutlet UITextField *password;

- (IBAction)backgroundtab:(id)sender;
- (IBAction)loginclicked:(id)sender;
- (IBAction)signupclicked:(id)sender;

@end

