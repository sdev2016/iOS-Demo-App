
// ReferralStageFourVC.m
// photoshare
// 
// Created by ignis3 on 27/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "ReferralStageFourVC.h"
#import "ContentManager.h"
#import "FBTWViewController.h"
#import "SVProgressHUD.h"
#import "TwitterTable.h"
#import "AppDelegate.h"
#import "MailMessageTable.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ReferralStageFourVC ()

@end

@implementation ReferralStageFourVC
{
    NSString *userSelectedEmail;
    NSString *userSelectedPhone;
    NSMutableDictionary *firendDictionary;
    NSMutableArray *FBEmailID;
    NSMutableArray *twiiterListArr;
    NSArray *sttt;
    NSString *tweetFail;
    NSNumber *userID;
    NSMutableArray *contactSelectedArray;
    NSMutableArray *contactNoSelectedArray;
    NSMutableDictionary *contactData;
    int totalCount;
    int countVar;
    int messagecount;
    int mailSent;
    BOOL grant;
    
    ACAccountStore *accountStore;
    ACAccountType *accountType;
}
@synthesize stringStr,twitterTweet,toolkitLink;
@synthesize referEmailStr,referPhoneStr,referredValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Detect device and load nib
    
    if([[ContentManager sharedManager] isiPad])
    {
        [[NSBundle mainBundle] loadNibNamed:@"ReferralStageFourVC_iPad" owner:self options:nil];
    }
    else
    {
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            [[NSBundle mainBundle] loadNibNamed:@"ReferralStageFourVC" owner:self options:nil];
        }
        else
        {
            [[NSBundle mainBundle] loadNibNamed:@"ReferrelStageFourVC3" owner:self options:nil];
        }
    }
    
    dmc = [[DataMapperController alloc] init];
    objManager = [ContentManager sharedManager];
    
    titleTextView.text = @"Write your personal message first then choose how to send it.";
    
    eglabel.text=@"If you want to personalise your message";
    editMessageTitleLbl.text=@"Click here! :)";
    _emailContacts.delegate = self;
    _emailMessageBody.delegate = self;
    emailView.hidden = YES;
    emailView.layer.borderColor = [UIColor blackColor].CGColor;
    emailView.layer.borderWidth = 2.0f;
    mailSent = 0;
    messagecount = 0;
    grant = NO;
    userID = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
    
    // For twitter account
    
    tweetFail =@"";
    accountStore = [[ACAccountStore alloc] init];
    accountType=[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    twiiterListArr = [[NSMutableArray alloc] init];
    firendDictionary = [[NSMutableDictionary alloc] init];
    FBEmailID = [[NSMutableArray alloc] init];
    contactSelectedArray = [[NSMutableArray alloc] init];
    contactNoSelectedArray = [[NSMutableArray alloc] init];
    setterEdit = NO;
    
    webservice=[[WebserviceController alloc] init];
    
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:@"Refer Friends"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    customImage.layer.cornerRadius = 5;
    
    
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
    
    // Checking the screen size
    
    countVar =0;
    [userMessage setDelegate:self];
    
    [self addCustomNavigationBar];
    
    // Added Tap gesture to dismiss keyboard
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.view addGestureRecognizer:tapGesture];
    
   
    [self getAppIdFromServer];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
}

/**
 *  When Keyboard show add custom "DONE" to hide the keyboard
 */

- (void)keyboardWillShow:(NSNotification *)notification

{
    CGPoint beginCentre = [[[notification userInfo] valueForKey:@"UIKeyboardCenterBeginUserInfoKey"] CGPointValue];
    
    CGPoint endCentre = [[[notification userInfo] valueForKey:@"UIKeyboardCenterEndUserInfoKey"] CGPointValue];
    
    CGRect keyboardBounds = [[[notification userInfo] valueForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if(nil == keyboardToolbar) {
        
        keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.width,self.view.bounds.size.width,25)];
        
        keyboardToolbar.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        
        keyboardToolbar.barStyle = UIBarStyleDefault;
        
        keyboardToolbar.tintColor = [UIColor blackColor];
        
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(0,0,50,25)];
        [btn setTitle:@"Done" forState:UIControlStateNormal];
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [[btn titleLabel] setFont:[UIFont fontWithName:@"system" size:11]];
        
        [btn addTarget:self action:@selector(endEditing) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithCustomView:btn];
        
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *items = [[NSArray alloc] initWithObjects:flex, barButtonItem, nil];
        
        [keyboardToolbar setItems:items];
        
        keyboardToolbar.frame = CGRectMake(beginCentre.x - (keyboardBounds.size.width/2),
                                           
                                           beginCentre.y - (keyboardBounds.size.height/2) - keyboardToolbar.frame.size.height,
                                           
                                           keyboardToolbar.frame.size.width,
                                           
                                           keyboardToolbar.frame.size.height);
        
        [self.view addSubview:keyboardToolbar];
        
        
        
    }
    
    [UIView beginAnimations:@"RS_showKeyboardAnimation" context:nil];
    
    [UIView setAnimationCurve:animationCurve];
    
    [UIView setAnimationDuration:animationDuration];

    keyboardToolbar.alpha = 1.0;
    
    keyboardToolbar.frame = CGRectMake(endCentre.x - (keyboardBounds.size.width/2),
                                       
                                       endCentre.y - (keyboardBounds.size.height/2) - keyboardToolbar.frame.size.height - self.view.frame.origin.y,
                                       
                                       keyboardToolbar.frame.size.width,
                                       
                                       keyboardToolbar.frame.size.height);
    
    [UIView commitAnimations];
    
    
    
}

/**
 *  When Keyboard is Hidden, hide the custom done button
 */
- (void)keyboardWillHide:(NSNotification *)notification

{
    
    [self.view endEditing:YES];
    
    [self resetTheScrollviewContent];
    
    if (nil == keyboardToolbar ) {
        return;
    }
    
    CGPoint endCentre = [[[notification userInfo] valueForKey:@"UIKeyboardCenterEndUserInfoKey"] CGPointValue];
    
    CGRect keyboardBounds = [[[notification userInfo] valueForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
   
    [UIView beginAnimations:@"RS_hideKeyboardAnimation" context:nil];
    
    [UIView setAnimationCurve:animationCurve];
    
    [UIView setAnimationDuration:animationDuration];
    
    keyboardToolbar.alpha = 0.0;
    
    keyboardToolbar.frame = CGRectMake(endCentre.x - (keyboardBounds.size.width/2),
                                       
                                       endCentre.y - (keyboardBounds.size.height/2) - keyboardToolbar.frame.size.height,
                                       
                                       keyboardToolbar.frame.size.width,
                                       
                                       keyboardToolbar.frame.size.height);
    [UIView commitAnimations];
    
}

/**
 *  Get FacebookAppID From Server. And Dynamically change the facebook App Id
 */

-(void)getAppIdFromServer
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    isGetFacebookAppID=YES;
    webservice.delegate=self;
    [webservice call:nil controller:@"appmanager" method:@"get_fbid"];
}

/**
 *  Set The FacebookAppID , display name in FBSettings
 */
-(void)setFBAppId :(NSString *)appId displayName:(NSString *)displayName
{
    [FBSettings setDefaultAppID:appId];
    [FBSettings setDefaultDisplayName:displayName];
    [FBSettings setDefaultUrlSchemeSuffix:[NSString stringWithFormat:@"fb%@",appId]];
}
-(void)endEditing
{
    [self.view endEditing:YES];
  
    [self resetTheScrollviewContent];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [navnBar setTheTotalEarning:objManager.weeklyearningStr];   
    
    
    // For Twitter
    if(twitterTweet.length != 0)
    {
        if([twitterTweet isEqualToString:@"(null)"])
        {
            twitterTweet=@"";
        }
        [SVProgressHUD dismissWithSuccess:@"Done"];
        
        // Check and Open SLComposeViewController For Twitter
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ \n I've just joined 123friday. Watch my short video,",twitterTweet]];
            [tweetSheet addImage:[UIImage imageNamed:@"login-logo-log.png"]];
            [tweetSheet addURL:[NSURL URLWithString:toolkitLink]];
            
            
            [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
                FBTWViewController *tw = [[FBTWViewController alloc] init];
                tw.successType = @"tw";
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        [objManager showAlert:@"Cancelled" msg:@"Tweet Cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
                        [self dismissModals];
                        break;
                    case SLComposeViewControllerResultDone:
                        [self.navigationController pushViewController:tw animated:YES];
                        break;
                    default:
                        break;
                }
            }];
            [self presentViewController:tweetSheet animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        twitterTweet = @"";
    }
    // For Email
    if([referredValue isEqualToString:@"Refer Mail"])
    {
        
        userSelectedEmail = referEmailStr;
        
        NSArray *arr = [referEmailStr componentsSeparatedByString:@","];
        contactSelectedArray = [NSMutableArray arrayWithArray:arr];
        mailFilter = YES;
        NSString *objFirst = [arr objectAtIndex:0];
        if(objFirst.length == 0)
        {
            [objManager showAlert:@"No Contact" msg:@"No contact available to mail" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Composing Message" maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(mailToFun) withObject:self afterDelay:0.0f];
        }
    }
    // For SMS
    else if ([referredValue isEqualToString:@"Refer Text"])
    {
        userSelectedPhone = referPhoneStr;
        NSArray *arr = [referPhoneStr componentsSeparatedByString:@", "];
        contactNoSelectedArray = [NSMutableArray arrayWithArray:arr];
        smsFilter = YES;
        NSString *objFirst = [arr objectAtIndex:0];
        if(objFirst.length == 0)
        {
            [objManager showAlert:@"No Contact" msg:@"No contact available for text" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Composing Message" maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(sendInAppSMS_referral) withObject:self afterDelay:5.0f];
        }
    }
    
    [self detectDeviceOrientation];
}

#pragma mark - UITextView delegate Methods

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    isUserMessageEditing=YES;
    [self setScrollviewContentForTextView];
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.stringStr=userMessage.text;
    NSLog(@"User Message : %@",self.stringStr);
    
    return YES;
}

/**
 *  Set Scroll View Contentoffset for UITextView
 */
-(void)setScrollviewContentForTextView
{
    if(UIDeviceOrientationIsPortrait(self.interfaceOrientation))
    {
        if(![objManager isiPad])
        {
            if([UIScreen mainScreen].bounds.size.height==480)
            {
                [scrollView setContentOffset:CGPointMake(0,105) animated:YES];
            }
            else
            {
                [scrollView setContentOffset:CGPointMake(0,45) animated:YES];
            }
        }
        
    }
    else
    {
        if(![objManager isiPad])
        {
            if([UIScreen mainScreen].bounds.size.height==480)
            {
                [scrollView setContentOffset:CGPointMake(0,185) animated:YES];
            }
            else
            {
                [scrollView setContentOffset:CGPointMake(0,210) animated:YES];
            }
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,280) animated:YES];
        }

    }
}

/** 
 *  Reset The Scroll View Content Offset
 */

-(void)resetTheScrollviewContent
{
    [scrollView setContentOffset:CGPointMake(0,-15) animated:YES];
    self.stringStr=userMessage.text;
    if(self.stringStr.length==0)
    {
        [self hideTheUserMessageEditTextView];
    }
    NSLog(@"User Message : %@",self.stringStr);
    isUserMessageEditing=NO;
}

/**
 *  When User Edit message button Click
 */

- (IBAction)editMsg_Btn:(id)sender {
    
    [self showTheUserMessageEditTextView];
    
}

/**
 *  Show Edit message TextView
 */
-(void)showTheUserMessageEditTextView
{
    [userMessage becomeFirstResponder];
    editMessageTitleLbl.hidden=YES;
    editMessageBtn.hidden=YES;
    userMessage.hidden=NO;
    eglabel.hidden=YES;
}
/**
 *  Hide The Edit Message TextView
 */
-(void)hideTheUserMessageEditTextView
{
    [userMessage resignFirstResponder];
    editMessageTitleLbl.hidden=NO;
    editMessageBtn.hidden=NO;
    userMessage.text=@"";
    userMessage.hidden=YES;
    eglabel.hidden=NO;
}
/**
 *  Action for Facebook
 */
- (IBAction)fbFilter_Btn:(id)sender {
    [self endEditing];
    fbFilter = YES;
    twFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
    [self postTofacebook];
}
/**
 *  Action for Twitter
 */
- (IBAction)twFilter_Btn:(id)sender {
    [self endEditing];
    twFilter = YES;
    fbFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
}

/**
 *  Action for Email
 */
- (IBAction)emailFilter_Btn:(id)sender {
     [self endEditing];
    self.stringStr=userMessage.text;
     NSLog(@"User Message : %@",self.stringStr);
    mailFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    smsFilter = NO;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Select email from Contacts", @"Manually enter email", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
/**
 *  Action for SMS
 */
- (IBAction)smsFilter_Btn:(id)sender {
     [self endEditing];
    self.stringStr=userMessage.text;
    NSLog(@"User Message : %@",self.stringStr);
    smsFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Select from Contacts", @"Manually enter contact", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
              [self ContactSelectorMethod];
            break;
        case 1:
            [self actionsheetCheeker];
            break;
        case 2:
            NSLog(@"Cancelled");
            break;
    }
}

-(void)actionsheetCheeker
{
    if(mailFilter)
    {
        [self mailToFun];
    }
    else if(smsFilter)
    {
        [self sendInAppSMS_referral];
    }
}


#pragma mark - Facebook Delegate Methods

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // If the user is logged in, they can post to Facebook using API calls, so we show the buttons
    [_FacebookShareLinkWithAPICallsButton setHidden:NO];
    // [_StatusUpdateWithAPICallsButton setHidden:NO];
}

/**
 *  Method to modify your app's UI for logged-out users
 */
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // If the user is NOT logged in, they can't post to Facebook using API calls, so we show the buttons
    [_FacebookShareLinkWithAPICallsButton setHidden:YES];
    // [_StatusUpdateWithAPICallsButton setHidden:YES];
}

/**
 *  Overriden method to handle error
 */
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

/**
 *  Function for parsing url parameters returned by the feed dialog
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

/**
 *  Post On Facebook
 */
- (void)postTofacebook{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"I've joined 123friday.", @"name",@" ", @"caption",@"Watch my short video.", @"description",toolkitLink, @"link",@"http://my.123friday.com/img/facebook.png",@"picture",nil];
    // Show the feed dialog
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
    {
        if (error)
        {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
        else
        {
            if (result == FBWebDialogResultDialogNotCompleted)
            {  // User canceled.
                NSLog(@"User cancelled.");
            }
            else
            {
                // Handle the publish feed callback
                NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                if (![urlParams valueForKey:@"post_id"])
                {
                    // User canceled.
                    UIAlertView *alC = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Post Cancelled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alC show];
                    NSLog(@"User cancelled.");
                }
                else
                {
                    // User clicked the Share button
                    NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                    FBTWViewController *fb = [[FBTWViewController alloc] init];
                    fb.successType = @"fb";
                    [self.navigationController pushViewController:fb animated:YES];
                    NSLog(@"result %@", result);
                }
            }
        }
    }];
}
/**
 *  Post On Twitter
 */

- (IBAction)postToTwitter:(id)sender {
    self.stringStr=userMessage.text;
    
    NSMutableArray *arr = [objManager getData:@"twFriendList"];
    
    if(arr.count > 0)
    {
        sttt = arr;
        totalCount =[sttt count];
        [twiiterListArr removeAllObjects];
        [self goToTwittertable];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"Downloading Data" maskType:SVProgressHUDMaskTypeBlack];
        // Get Twitter Account
        [self getTwitterAccounts];
    }
}

/**
 *  Get Twitter Account
 */
-(void)getTwitterAccounts {
    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        grant = granted;
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"%@",twitterAccount.username);
                NSLog(@"%@",twitterAccount.identifier);
                [self performSelectorInBackground:@selector(getTwitterFriendsIDListForThisAccount:) withObject:twitterAccount.username];
                [SVProgressHUD showWithStatus:@"Downloading Data" maskType:SVProgressHUDMaskTypeBlack];
            }
        }
    }];
    
    if([accountsArray count] == 0)
    {
        [self disMissProgress];
        UIAlertView *twAl = [[UIAlertView alloc] initWithTitle:@"Twitter Account Not Found/ Twitter Account not Granted" message:@"Please sign-in your twitter account from your ios setting and run the app again. Grant permission to access this app. If twitter table loaded ignore this message." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [twAl show];
    }
}


-(void) getTwitterFriendsIDListForThisAccount:(NSString *)myAccount{
    
    if (grant) {
    
        NSArray *accounts = [accountStore accountsWithAccountType:accountType];
        
        // Check if the users has setup at least one Twitter account
        
        if (accounts.count > 0)
        {
            ACAccount *twitterAccount = [accounts objectAtIndex:0];
            
            // Creating a request to get the info about a user on Twitter
            SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1/friends/ids.json"] parameters:[NSDictionary dictionaryWithObject:myAccount forKey:@"screen_name"]];
                
            [twitterInfoRequest setAccount:twitterAccount];
                // Making the request
            [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Check if we reached the reate limit
                    if ([urlResponse statusCode] == 429) {
                        NSLog(@"Rate limit reached");
                        [SVProgressHUD dismissWithError:@"Rate limit reached" afterDelay:3.0f];
                        return;
                    }
                    // Check if there was an error
                    if (error) {
                        [SVProgressHUD dismissWithError:error.localizedDescription afterDelay:3.0f];
                        NSLog(@"Error: %@", error.localizedDescription);
                        return;
                    }
                    // Check if there is some response data
                    if (responseData) {
                        NSError *error = nil;
                        NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            
                        sttt = [(NSDictionary *)TWData objectForKey:@"ids"];
                        totalCount =[sttt count];
                        [twiiterListArr removeAllObjects];
                        
                        if(totalCount == 0)
                        {
                            [SVProgressHUD dismissWithError:@"No Twitter ID's Found"];
                            [objManager showAlert:@"Alert" msg:@"No Twitter ID Found or There are zero Follower in your Twitter account" cancelBtnTitle:@"Ok" otherBtn:nil];
                        }
                        [self goToTwittertable];
                    }
                });
            }];
        }
    }
    else {
      NSLog(@"No access granted");
    }
}

-(void)getFollowerNameFromID:(NSString *)ID{
    
    // Request access to the Twitter account
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            // Check if user has a single account setup
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                // Creating request to getinfo about user on twitter
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",ID] forKey:@"user_id"]];
                
                [twitterInfoRequest setAccount:twitterAccount];

                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // Check if we have reached the rate limit
                        
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            [SVProgressHUD dismissWithError:@"Rate limit reached"];
                            return;
                        }
                        
                        // Check if there was an error
                        
                        if (error) {
                            [SVProgressHUD dismissWithError:error.localizedDescription afterDelay:3.0f];
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        // Check if there is some response data
                        
                        if (responseData) {
                            
                            NSError *error = nil;
                            
                            NSDictionary *friendsdata = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            NSLog(@"friendsdata value is %@", friendsdata);
                            
                            NSString *stt= [@"@" stringByAppendingString:[friendsdata objectForKey:@"screen_name"]];
                            [twiiterListArr addObject:stt];
                            
                            if(totalCount > countVar)
                            {
                                countVar++;
                            }
                        }
                        
                        if(totalCount == countVar)
                        {
                            [self disMissProgress];
                            TwitterTable *tw = [[TwitterTable alloc] init];
                            tw.tweetUserName = [NSMutableArray arrayWithArray:twiiterListArr];
                            [self.navigationController pushViewController:tw animated:NO];
                            tw.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
                            totalCount = 0;
                            countVar = 0;
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}
/**
 *  Open Twitter Table For Select The Friends
 */
-(void)goToTwittertable
{
    TwitterTable *tw = [[TwitterTable alloc] init];
    tw.tweetUserIDsArray = [NSMutableArray arrayWithArray:sttt];
    tw.accountStore=accountStore;
    tw.accountType=accountType;
    [self.navigationController pushViewController:tw animated:NO];
    tw.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
    totalCount = 0;
    countVar = 0;
}


-(void)disMissProgress
{
    [SVProgressHUD dismissWithSuccess:@"Done"];
}



/**
 *  Send referral by Email
 */
-(void)mailToFun {
    
    self.stringStr=userMessage.text;
    [self composedMailMessage];
    referredValue = @"";
    // Email subjects
    NSString *emailTitle = @" ";
    // Email content
    NSString *message=self.stringStr;
    NSString *messageBody =nil;
    if(message==NULL || message.length==0)
    {
        messageBody= [NSString stringWithFormat:@"I'm using 123friday! Watch this short video then give me a call or message me :-)  <a href=%@>123friday video</a>",toolkitLink];
    }
    else
    {
        message=[NSString stringWithFormat:@"%@.",message];
        messageBody= [NSString stringWithFormat:@"%@ <a href=%@>123friday video</a>",message,toolkitLink];
    }
    
    // "To" address
    NSArray *toRecipents = [NSArray arrayWithArray:contactSelectedArray];
        
    MFMailComposeViewController *mfMail = [[MFMailComposeViewController alloc] init];
    mfMail.mailComposeDelegate = self;
    
    [mfMail setSubject:emailTitle];
    [mfMail setMessageBody:messageBody isHTML:YES];
    if(toRecipents.count>0)
    {
        [mfMail setToRecipients:[NSArray arrayWithObject:[toRecipents objectAtIndex:0]]];
        NSMutableArray *torec=[toRecipents mutableCopy];
        if(torec.count>1)
        {
            [torec removeObjectAtIndex:0];
            [mfMail setBccRecipients:torec];
        }
    }
    
    // Present mail view controller on the screen
    
    [[self navigationController] presentViewController:mfMail animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewController Delegate Methods

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully referred your friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [objManager showAlert:@"Cancelled" msg:@"Mail cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactSelectedArray removeAllObjects];
            break;
        case MFMailComposeResultSaved:
            [objManager showAlert:@"Saved" msg:@"You mail is saved in draft" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactSelectedArray removeAllObjects];
            break;
        case MFMailComposeResultSent:
            [alert show];
            [self mailToServer];
            break;
        case MFMailComposeResultFailed:
            [objManager showAlert:@"Mail sent failure" msg:[error localizedDescription] cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactSelectedArray removeAllObjects];
            break;
        default:
            break;
    }
    
    // Close the mail interface
    [self dismissModals];
}

/**
 *  Send referral by SMS
 */
-(void)sendInAppSMS_referral
{
    [self composedMailMessage];
    referredValue = @"";
    
    NSString *message=self.stringStr;
    NSString *msgBody=nil;
    if(message==NULL || message.length==0)
    {
        msgBody=[NSString stringWithFormat:@"I'm using 123friday! Watch this short video then give me a call or message me :-) %@",toolkitLink];
    }
    else
    {
        message=[NSString stringWithFormat:@"%@.",message];
        msgBody=[NSString stringWithFormat:@"%@ %@",message,toolkitLink];
    }
    
    
    msgBody = [msgBody stringByTrimmingCharactersInSet:                               [NSCharacterSet whitespaceCharacterSet]];
    
	if([MFMessageComposeViewController canSendText])
	{
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
		controller.body = msgBody;
        controller.recipients = contactNoSelectedArray;
        [[self navigationController] presentViewController:controller animated:NO completion:nil];
	}
    else
    {
        [objManager showAlert:@"Alert !" msg:@"Your device not support messaging or currently not configured to send messages." cancelBtnTitle:@"Ok" otherBtn:Nil];
    }
}

#pragma mark - MFMessageComposeViewController Delegate Methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully referred your friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
	switch (result) {
		case MessageComposeResultCancelled:
			[objManager showAlert:@"Cancelled" msg:@"Message Composed Cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactNoSelectedArray removeAllObjects];
			break;
		case MessageComposeResultFailed:
			[objManager showAlert:@"Failed" msg:@"Something went wrong!! Please try again" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactNoSelectedArray removeAllObjects];
            userSelectedPhone = @"";
            break;
		case MessageComposeResultSent:
                [alert show];
            [self hideTheUserMessageEditTextView];
                [contactNoSelectedArray removeAllObjects];
			break;
		default:
			break;
	}
    
	[self dismissModals];
}

-(void)composedMailMessage
{
    [SVProgressHUD dismissWithSuccess:@"Composed"];
}

/**
 *  Load Contacts From ABAddressBookRef
 */

-(void)ContactSelectorMethod
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted)
            {
                [self loadContacts];
            }
    });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        [self loadContacts];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"You have denied to load contact for this app" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
       
        [alert show];
    }
    
    CFRelease(addressBook);
}

/**
 *  Load All Contacts From ABAddressBookRef
 */

-(void)loadContacts
{
    CFErrorRef error = NULL;
    
    contactData = [[NSMutableDictionary alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook != (__bridge ABAddressBookRef)((id)[NSNull null]))
    {
        NSLog(@"Succesful.");
        
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            NSString *firstName = (__bridge_transfer NSString
                                   *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString
                                   *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            if(firstName.length == 0)
            {
                firstName = @"";
            }
            else if(lastName.length == 0)
            {
                lastName = @"";
            }
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",
                                  firstName, lastName];
            if(fullName.length<=1)
            {
                fullName=@"";
            }
            NSLog(@"Full Name: %@",fullName);
            
            NSString *concatStr = @"";
            NSString *concatStr2 = @"";
            
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            NSUInteger j = 0;
            for (j = 0; j < ABMultiValueGetCount(emails); j++)
            {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                if(concatStr.length == 0)
                {
                    concatStr = email;
                }
                else
                {
                    concatStr = [NSString stringWithFormat:@"%@,%@",concatStr,email];
                }
            }
            
            ABMutableMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSUInteger k = 0;
            for(k = 0;k< ABMultiValueGetCount(phones); k++)
            {
                NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, k);
                if(concatStr2.length == 0)
                {
                    concatStr2 = phone;
                }
                else
                {
                    concatStr2 = [NSString stringWithFormat:@"%@ , %@",concatStr2,phone];
                }
            }
            
            CFRelease(emails);
            CFRelease(phones);
            
            NSDictionary *dict = @{@"name":fullName,@"email":concatStr,@"phone":concatStr2};
            
            [contactData setObject:dict forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    CFRelease(addressBook);
    
    // Forwarding to controller
    
    if(mailFilter)
    {
        MailMessageTable *mmVC;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable_iPad" bundle:nil];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable" bundle:nil];
        }
        mmVC.contactDictionary = contactData;
        mmVC.filterType = @"Refer Mail";
        
        [self.navigationController pushViewController:mmVC animated:YES];
    }
    else if (smsFilter)
    {
        
        MailMessageTable *mmVC;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable_iPad" bundle:nil];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable" bundle:nil];
        }
        mmVC.contactDictionary = contactData;
        mmVC.filterType = @"Refer Text";
        
        [self.navigationController pushViewController:mmVC animated:YES];
       
    }
}

/**
 *  Alert view delegates
 */
-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%li",(long)buttonIndex);
    NSLog(@"The %@ button was tapped.", [alert buttonTitleAtIndex:buttonIndex]);
    if(buttonIndex == 1)
    {
        if(mailFilter)
        {
            [self ContactSelectorMethod];
        }
        else if(smsFilter)
        {
            [self ContactSelectorMethod];
        }
    }
}



/**
 *  Dismiss models
 */
-(void)dismissModals
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

/**
 *  Send Email detail To The Server
 */

 -(void)mailToServer
{
    [self hideTheUserMessageEditTextView];
    WebserviceController *wbh = [[WebserviceController alloc] init];
    wbh.delegate = self;
    NSArray *arr = [toolkitLink componentsSeparatedByString:@"/"];
    NSString *message=self.stringStr;
    if(message==NULL)
    {
        message = [NSString stringWithFormat:@""];
    }
    
    for(int sm=0;sm<contactSelectedArray.count;sm++)
    {
        NSDictionary *dictData = @{@"user_id":userID, @"email_addresses":[contactSelectedArray objectAtIndex:sm] ,@"message_title":message,@"toolkit_id":[arr objectAtIndex:6]};
        [wbh call:dictData controller:@"broadcast" method:@"sendmail"];
    }
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];

    UILabel *navTitle = [navnBar navBarTitleLabel:@"Refer Friends"];
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];

    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

/**
 *  Actions defined for email
 */
- (IBAction)sendEmailView:(id)sender {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully referred your friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
    [alert show];
    [self mailToServer];
    emailView.hidden = YES;
    referredValue = @"";
    referEmailStr = @"";
    _emailContacts.text = @"";
}
- (IBAction)cancelEmailView:(id)sender {
    _emailContacts.text = @"";
    
    [objManager showAlert:@"Cancelled" msg:@"Mail cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
    emailView.hidden = TRUE;
    referredValue = @"";
    referEmailStr = @"";
}


- (IBAction)addmoreBtn:(id)sender
{
    [self ContactSelectorMethod];
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    // Recieve FacebookAppID from server
    NSLog(@"WebService Data -- %@",data);
    NSNumber *exit_code=[data objectForKey:@"exit_code"];
    if(isGetFacebookAppID)
    {
        @try {
            if(exit_code.integerValue==1)
            {
                // Save details recieved to FBSettings
                [self setFBAppId:[[data objectForKey:@"output_data"] objectForKey:@"fb_appid"] displayName:@"123Friday"];
            }
        }
        @catch (NSException *exception) {
            
        }
        [SVProgressHUD dismiss];
        isGetFacebookAppID=NO;
    }
    else
    {
        mailSent++;
    }
}

#pragma mark - Device Orientation Methods

-(void)detectDeviceOrientation
{
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self orient:toInterfaceOrientation];
    if(isUserMessageEditing)
    {
        [self setScrollviewContentForTextView];
    }
}

-(void)orient:(UIInterfaceOrientation)ott
{
    [self endEditing];
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 80, 480, 320);
            scrollView.contentSize = CGSizeMake(480, 450);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(0, 80, 480, 430);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 80, 568, 300);
            scrollView.contentSize = CGSizeMake(568, 480);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(0, 81, 568, 400);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 170, 1024, 900);
            scrollView.contentSize = CGSizeMake(1024, 1100);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(14, 20, 1000, 688);
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 80, 320, 370);
            scrollView.contentSize = CGSizeMake(320, 280);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(0, 20, 320, 330);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 80, 320, 568);
            scrollView.contentSize = CGSizeMake(320, 300);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(0, 81, 320, 390);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 170, 768, 752);
            scrollView.contentSize = CGSizeMake(768, 500);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(14, 20, 734, 688);
        }
    }
    if(![objManager isiPad])
    {
        [self setUIForIOS6];
    }
}

/**
 *  For IOS6
 */
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        scrollView.contentSize=CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height+70);
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
