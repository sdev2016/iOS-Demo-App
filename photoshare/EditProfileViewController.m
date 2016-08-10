// 
// EditProfileViewController.m
// photoshare
// 
// Created by Dhiru on 28/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "EditProfileViewController.h"
#import "WebserviceController.h"
#import "ContentManager.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

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
    objManager = [ContentManager sharedManager];
    [super viewDidLoad];
  
    wc = [[WebserviceController alloc] init];
    wc.delegate = self;
    
    // Set Delegate of UITextField
    
    [name setDelegate:self] ;
    [email setDelegate:self] ;
    
    dmc  = [[DataMapperController alloc] init] ;
    [self getDetails] ;
    
    // Tap gestures added to view
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapGesture];
    [self addCustomNavigationBar];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
    [self detectDeviceOrientation];
}
-(void)hideKeyboard :(UITapGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}


/**
 *  Get User Details From Server
 */
-(void) getDetails
{
    
    calltype = @"getdetails";
    
    NSString *userid =[dmc getUserId] ;
    NSDictionary *dic = @{@"user_id":userid,@"target_user_id":userid};
    [wc call:dic controller:@"user" method:@"get"];

}

/**
 *  Save user details button click
 */
-(IBAction)saveProfile:(id)sender
{
    NSString *nameval = name.text ;
    NSString *emailval = email.text;
   
    calltype = @"saveprofile";
   
     NSString *userid =[dmc getUserId] ;
     NSDictionary *dic = @{@"user_id":userid,@"user_realname":nameval,@"user_emailaddress":emailval};
    
    [wc call:dic controller:@"user" method:@"change"];
    
}
/**
 *  Cancel button Click
 */

- (IBAction)userCancelButton:(id)sender {
    UITextField *field = (UITextField *) [self.view viewWithTag:([sender tag] -10)];
    field.text = @"";
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    // Get Details Response
    if([calltype isEqualToString:@"getdetails"] )
    {
        name.text = [[[data valueForKey:@"output_data"] objectAtIndex:0] valueForKey:@"user_realname"] ;
        email.text = [[[data valueForKey:@"output_data"] objectAtIndex:0] valueForKey:@"user_emailaddress"];
    }
    
    // Save Details Response
    
    if([calltype isEqualToString:@"saveprofile"])
    {
        // Update user details in NSUserDefaults
        
        NSDictionary *userDetails=[[dmc getUserDetails] mutableCopy];
        [userDetails setValue:name.text forKey:@"user_realname"];
        [userDetails setValue:email.text forKey:@"user_emailaddress"];
        [dmc setUserDetails:userDetails];
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:[data objectForKey:@"user_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    
    }
    
    if([[UIScreen mainScreen] bounds].size.height == 480.0f)
    {
        scrollView.frame = CGRectMake(0, 88, 320, 297);
    }
}


#pragma mark - UITextField Delegate Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



/**
 *  For IOS6
 */
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        scrollView.contentSize=CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height+50);
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
-(void)orient:(UIInterfaceOrientation)ott
{
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 60, 480, 300);
            scrollView.contentSize = CGSizeMake(480, 330);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 60, 568, 300);
            scrollView.contentSize = CGSizeMake(568, 330);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 150, 1024, 500);
            scrollView.contentSize = CGSizeMake(1024, 500);
            scrollView.bounces = NO;
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 88, 320, 297);
            scrollView.contentSize = CGSizeMake(320, 250);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 88, 320, 297);
            scrollView.contentSize = CGSizeMake(320, 250);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 150, 768, 477);
            scrollView.contentSize = CGSizeMake(768, 250);
            scrollView.bounces = NO;
        }
    }
    if(![objManager isiPad])
    {
        [self setUIForIOS6];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self orient:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    // Set custom back button on navigation bar
    
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
