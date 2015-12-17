//
//  LoginVerification.h
//  Sign
//
//  Created by Gowtham on 01/12/15.
//  Copyright © 2015 Gowtham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVerification : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *email;
- (IBAction)sendcode:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *mob;
@property (strong,nonatomic) NSString *getemail;
@end
