//
//  signup.h
//  Sign
//
//  Created by Gowtham on 28/11/15.
//  Copyright © 2015 Gowtham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface signup : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nametext;
@property (strong, nonatomic) IBOutlet UITextField *emailtext;
@property (strong, nonatomic) IBOutlet UITextField *mobiletext;
@property (strong, nonatomic) IBOutlet UITextField *passwordtext;
@property (strong, nonatomic) IBOutlet UISwitch *agreeswitch;
- (IBAction)signup:(id)sender;
- (IBAction)backgroundtap:(id)sender;
- (IBAction)back:(id)sender;

@end
