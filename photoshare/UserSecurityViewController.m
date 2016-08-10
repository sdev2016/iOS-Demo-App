// 
// UserSecurityViewController.m
// photoshare
// 
// Created by Dhiru on 28/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "UserSecurityViewController.h"
#import "WebserviceController.h"
#import "ContentManager.h"

@interface UserSecurityViewController ()

@end

@implementation UserSecurityViewController

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
        [[NSBundle mainBundle] loadNibNamed:@"UserSecurityViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"UserSecurityViewController" owner:self options:nil];
    }
    
    objManager = [ContentManager sharedManager];
    
    // Set delegate
    [oldpass setDelegate:self] ;
    [newpass setDelegate:self] ;
    
    wc = [[WebserviceController alloc] init] ;
    wc.delegate = self;
    dmc = [[DataMapperController alloc] init] ;
    
    // Add tap gesture For dismiss keyboard
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self addCustomNavigationBar];
}

/**
 *  Hide Keyboard
 */
-(void)hideKeyboard :(UITapGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}


/**
 *  Request password button action
 */
-(IBAction)changepassword:(id)sender
{
    NSString *oldpassval = oldpass.text ;
    NSString *newpassval = newpass.text;
    
    NSString *userid = [dmc getUserId] ;
    
    // Post change password request on server
    
    NSDictionary *postdic = @{@"user_id":userid,@"user_password":oldpassval,@"user_newpassword":newpassval} ;
    [wc call:postdic controller:@"user" method:@"changepassword"];
    
}
/**
 *  Cancel button action
 */
- (IBAction)userCancelButton:(id)sender {
    
    
    UITextField *field = (UITextField *) [self.view viewWithTag:([sender tag] -10)];
    field.text = @"";
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    
    NSLog(@"data--%@ ",data) ;
    
    // Alert if password is changed or not
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:[data objectForKey:@"user_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - UITextField Delegate Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    // Add custom navigation back button on navigation bar
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
    [self detectDeviceOrientation];
}

#pragma mark - Device Orientation Methods

-(void)detectDeviceOrientation
{
    if(UIDeviceOrientationIsPortrait(self.interfaceOrientation))
    {
        [self orient:self.interfaceOrientation];
    }
    else
    {
        [self orient:self.interfaceOrientation];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self orient:toInterfaceOrientation];
}

-(void)orient:(UIInterfaceOrientation)ott
{
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 60, 480, 250);
            scrollView.contentSize = CGSizeMake(480, 280);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 60, 568, 250);
            scrollView.contentSize = CGSizeMake(568, 250);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 155, 1024, 400);
            scrollView.contentSize = CGSizeMake(1024, 500);
            scrollView.bounces = NO;
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 90, 320, 245);
            scrollView.contentSize = CGSizeMake(320, 160);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 90, 320, 270);
            scrollView.contentSize = CGSizeMake(320, 200);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 155, 768, 426);
            scrollView.contentSize = CGSizeMake(768, 250);
            scrollView.bounces = NO;
        }
    }
    if(![objManager isiPad])
    {
        [self setUIForIOS6];
    }
}


-(void)setUIForIOS6
{
    // Set for IOS6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        scrollView.contentSize=CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height+50);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
