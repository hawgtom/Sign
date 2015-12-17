//
//  verification.m
//  Sign
//
//  Created by Gowtham on 30/11/15.
//  Copyright © 2015 Gowtham. All rights reserved.
//

#import "verification.h"
#import "GUAAlertView.h"
#import "MBProgressHUD.h"
@interface verification ()<MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    long long expectedLength;
    long long currentLength;
    
}

@end

@implementation verification
@synthesize veri_code;
@synthesize mob;
- (void)viewDidLoad {
    [super viewDidLoad];
    veri_code.text=mob;
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.codetext.inputAccessoryView = numberToolbar;
    // Do any additional setup after loading the view.
}

-(void)cancelNumberPad{
    [self.codetext resignFirstResponder];
}

-(void)doneWithNumberPad{
    NSString *numberFromTheKeyboard = self.codetext.text;
    [self.codetext resignFirstResponder];
}

    // Do any additional setup after loading the view.


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
    [veri_code release];
    [_codetext release];
    [super dealloc];
}
- (IBAction)getaccess:(id)sender {
   
        if([[self.codetext text] isEqualToString:@""])
        {
            [self alertStatus:@"Enter the Verification Code" :@"Required" :0];
            
        }
        else
        {
                [self check];
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
    HUD.labelText = @"Validating Code..";
    
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
                                              
                                              
                                              NSString *post =[[NSString alloc] initWithFormat:@"code=%@&mob=%@&status=%@",[self.codetext text],[self.veri_code text],@"0"];
                                              NSLog(@"PostData: %@",post);
                                              
                                              NSURL *url=[NSURL URLWithString:@"http://192.168.1.13/projects/sign/verifycode.php"];
                                              
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
                                                      [self alert:@"Verification Successful" :@"Signature" :1];
                                                     
                                                      //[self performSegueWithIdentifier:@"verified_login" sender:self];
                                                  }
                                                  else
                                                  {
                                                      NSString *error_msg = (NSString *) jsonData[@"error_message"];
                                                      [self alert:error_msg :@"Verification Error" :0];
                                                      
                                                  }
                                                  
                                              }
                                              else
                                              {
                                                  [self alert:@"Connection Failed" :@"SignUp Failed!" :0];
                                              }
                                              
                                          }
                                          @catch (NSException * e) {
                                              NSLog(@"Exception: %@", e);
                                              [self alert:@"SignUp Failed." :@"Error!" :0];
                                          }
                                          
                                      }
                                      );
                   }
                   );
    
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void) alert:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action)
                         {
                             [self performSegueWithIdentifier:@"verified_login" sender:self];
                                                      }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                             {
                            }];
    if(tag != 1)
    {
        [alert addAction:cancel];
    }
    else
    {
        [alert addAction:ok];
    }
    [self presentViewController:alert animated:YES completion:nil];
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

@end
