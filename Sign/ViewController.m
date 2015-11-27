//
//  ViewController.m
//  Sign
//
//  Created by Gowtham on 25/11/15.
//  Copyright © 2015 Gowtham. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
@interface ViewController ()<MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    long long expectedLength;
    long long currentLength;

}
@end

@implementation ViewController

//UIActivityIndicatorView *view;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginclicked:(id)sender {
    if([[self.username text] isEqualToString:@""] || [[self.password text] isEqualToString:@""] )
    {
        
        [self alertStatus:@"Please enter Email and Password" :@"Sign in Failed!" :0];
        
    }
    else
    {
         [self check];
  
    }
}
-(void)check
{
    NSURL *URL = [NSURL URLWithString:@"http://192.168.1.10"];
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
    HUD.labelText = @"Securing Login..";
    
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
                               
                               
                                   NSString *post =[[NSString alloc] initWithFormat:@"username=%@&password=%@",[self.username text],[self.password text]];
                                   NSLog(@"PostData: %@",post);
                                   
                                   NSURL *url=[NSURL URLWithString:@"http://192.168.1.10/projects/sign/login.php"];
                                   
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
                                               [self performSegueWithIdentifier:@"login_success" sender:self];
                                       }
                                       else
                                       {
                                           NSString *error_msg = (NSString *) jsonData[@"error_message"];
                                           [self alertStatus:error_msg :@"Sign in Failed!" :0];
                                       }
                                       
                                   }
                                   else
                                   {
                                       [self alertStatus:@"Connection Failed" :@"Sign in Failed!" :0];
                                   }
                               
                           }
                           @catch (NSException * e) {
                               NSLog(@"Exception: %@", e);
                                [self alertStatus:@"Sign in Failed." :@"Error!" :0];
                           }

                       }
                       );
                    }
                   );
    
    
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
    
}

- (IBAction)backgroundtab:(id)sender {
    [self.view endEditing:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
