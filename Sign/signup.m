//
//  signup.m
//  Sign
//
//  Created by Gowtham on 28/11/15.
//  Copyright © 2015 Gowtham. All rights reserved.
//

#import "signup.h"
#import "GUAAlertView.h"
#import "MBProgressHUD.h"
#import "verification.h"
@interface signup ()<MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    long long expectedLength;
    long long currentLength;
    
}

@end

@implementation signup
@synthesize mobiletext;
- (void)viewDidLoad {
    [super viewDidLoad];
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.mobiletext.inputAccessoryView = numberToolbar;
    // Do any additional setup after loading the view.
}

-(void)cancelNumberPad{
    [self.mobiletext resignFirstResponder];
}

-(void)doneWithNumberPad{
    NSString *numberFromTheKeyboard = self.mobiletext.text;
    [self.mobiletext resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_nametext release];
    [_emailtext release];
    [mobiletext release];
    [_passwordtext release];
    [_agreeswitch release];
    [super dealloc];
}
- (IBAction)signup:(id)sender {
    if([[self.nametext text] isEqualToString:@""] || [[self.passwordtext text] isEqualToString:@""] || [[self.nametext text] isEqualToString:@""] ||[[self.nametext text] isEqualToString:@""] )
    {
        [self alertStatus:@"Fill The Details" :@"Required" :0];
        
    }else if (![self.agreeswitch isOn])
    {
        [self alertStatus:@"Please Agree Terms & Conditions" :@"Required" :0];
    }
    else
    {
         NSInteger sam=[self validEmail:[self.emailtext text]];
         if(!sam)
         {
             [self alertStatus:@"Valid Email-ID is Required" :@"Alert" :0];

         }
        else
        {
            [self check];
        }
        
    }
}
- (NSInteger) validEmail:(NSString*) emailString {
    
    if([emailString length]==0){
        return NO;
    }
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
       if (regExMatches == 0) {
        return 0;
    } else {
        return 1;
    }
}
-(void)check
{
    NSURL *URL = [NSURL URLWithString:@"http://192.168.1.13"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    [connection release];
    HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
    HUD.labelText = @"Connecting to Signature..";
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    expectedLength = MAX([response expectedContentLength], 1);
    currentLength = 0;
    HUD.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    currentLength += [data length];
    HUD.progress = currentLength / (float)expectedLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [HUD showWhileExecuting:@selector(myMixedTask) onTarget:self withObject:nil animated:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [HUD hide:YES];
    [self alertStatus:@"Please Check the Internet" :@"Network Error" :0];
}

- (void)myMixedTask {
    // Indeterminate mode
    sleep(2);
    
    // Switch to determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Signing Up..";
    
    float progress = 0.0f;
    while (progress < 1.0f)
    {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(5000);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performBackgroundTask];
        
    });
}
-(void)performBackgroundTask
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          NSInteger success=0;
                                          @try{
                                              
                                              
                                              NSString *post =[[NSString alloc] initWithFormat:@"name=%@&email=%@&mob=%@&pwd=%@",[self.nametext text],[self.emailtext text],[self.mobiletext text],[self.passwordtext text]];
                                              NSLog(@"PostData: %@",post);
                                              
                                              NSURL *url=[NSURL URLWithString:@"http://192.168.1.13/projects/sign/signup.php"];
                                              
                                              NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                                              
                                              NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                                              
                                              NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                                              [request setURL:url];
                                              [request setHTTPMethod:@"POST"];
                                              [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                                              [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                                              [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                                              [request setHTTPBody:postData];
                                              
                                              //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
                                              
                                              NSError *error = [[NSError alloc] init];
                                              NSHTTPURLResponse *response = nil;
                                              NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                                              
                                              NSLog(@"Response code: %ld", (long)[response statusCode]);
                                              
                                              if ([response statusCode] >= 200 && [response statusCode] < 300)
                                              {
                                                  
                                                  NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                                                  NSLog(@"Response ==> %@", responseData);
                                                  
                                                  NSError *error = nil;
                                                  NSDictionary *jsonData = [NSJSONSerialization
                                                                            JSONObjectWithData:urlData
                                                                            options:NSJSONReadingMutableContainers
                                                                            error:&error];
                                                  
                                                  success = [jsonData[@"success"] integerValue];
                                                  NSLog(@"Success: %ld",(long)success);
                                                  if(success == 1)
                                                  {
                                                      [self alertStatus:@"Registration Successful" :@"Alert" :0];
                                                      [self performSegueWithIdentifier:@"verification" sender:self];
                                                }
                                                  else
                                                  {
                                                      NSString *error_msg = (NSString *) jsonData[@"error_message"];
                                                      [self alert:error_msg :@"Login Failed" :2];
                                                  }
                                                  
                                              }
                                              else
                                              {
                                                  [self alertStatus:@"Connection Failed" :@"SignUp Failed!" :0];
                                              }
                                              
                                          }
                                          @catch (NSException * e) {
                                              NSLog(@"Exception: %@", e);
                                              [self alertStatus:@"SignUp Failed." :@"Error!" :0];
                                          }
                                          
                                      }
                                      );
                   }
                   );
    
    
}
- (IBAction)backgroundtap:(id)sender {
     [self.view endEditing:YES];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
            if ([[segue identifier] isEqualToString:@"verification"]) {
            
            // Get destination view
            verification *vc = [segue destinationViewController];
            
            // Get button tag number (or do whatever you need to do here, based on your object
                vc.mob=[self.mobiletext text];
            }
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO;
   // [textField resignFirstResponder];
  //  return YES;
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{

    
    GUAAlertView *v = [GUAAlertView alertViewWithTitle:title
                                               message:msg
                                           buttonTitle:@"Swipe Alert Down"
                                   buttonTouchedAction:^{
                                       
                                   } dismissAction:^{
                                       
                                   }];
    [v show];
}
- (void) alert:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action)
                         {
                             if(tag == 2)
                                 [self dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
