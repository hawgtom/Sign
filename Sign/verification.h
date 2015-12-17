//
//  verification.h
//  Sign
//
//  Created by Gowtham on 30/11/15.
//  Copyright © 2015 Gowtham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface verification : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel *veri_code;
@property (strong,nonatomic) NSString *mob;
@property (strong, nonatomic) IBOutlet UITextField *codetext;
- (IBAction)getaccess:(id)sender;



@end
