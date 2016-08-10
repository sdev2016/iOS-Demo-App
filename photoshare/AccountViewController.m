// 
// AccountViewController.m
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "AccountViewController.h"
#import "EditProfileViewController.h"
#import "UserSecurityViewController.h"
#import "TermConditionViewController.h"
#import "ReferFriendViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "ContentManager.h"
#import "WebserviceController.h"
@interface AccountViewController ()

@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Detect device and load nib
    
    if([[ContentManager sharedManager] isiPad])
    {
        [[NSBundle mainBundle] loadNibNamed:@"AccountViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"AccountViewController" owner:self options:nil];
    }
    
    dmc = [[DataMapperController alloc] init];
    objManager = [ContentManager sharedManager];

    [self addCustomNavigationBar];
    [self setUIForIOS6];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self orientCheck:[[UIApplication sharedApplication] statusBarOrientation]];
    
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUIForIOS6
{
    // For IOS 6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        profilePicImgView.frame=CGRectMake(0, 40, profilePicImgView.frame.size.width, profilePicImgView.frame.size.height+40);
        settingMenuContainerView.frame=CGRectMake(0, settingMenuContainerView.frame.origin.y+50,settingMenuContainerView.frame.size.width, settingMenuContainerView.frame.size.height);
    }
}

#pragma mark - UIButton Action Methods

-(IBAction)editProfile:(id)sender
{
    self.navigationController.navigationBarHidden = NO;
    EditProfileViewController *epVC;
    
    // Detect Device
    
    if([objManager isiPad])
    {
        epVC = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        epVC = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController" bundle:[NSBundle mainBundle]] ;
    }
    
    [self.navigationController pushViewController:epVC animated:YES] ;
    epVC.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}



-(IBAction)userSecurity:(id)sender
{
    self.navigationController.navigationBarHidden = NO;
    UserSecurityViewController *usVC;
    
    // Detect Device
    
    if([objManager isiPad])
    {
        usVC = [[UserSecurityViewController alloc] initWithNibName:@"UserSecurityViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else{
        usVC = [[UserSecurityViewController alloc] initWithNibName:@"UserSecurityViewController" bundle:[NSBundle mainBundle]] ;
    }
    [self.navigationController pushViewController:usVC animated:YES] ;
    usVC.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}



-(IBAction)referFriend:(id)sender
{
    self.navigationController.navigationBarHidden = NO;
    ReferFriendViewController *rf;
    
    // Detect Device
    
    if([objManager isiPad])
    {
        rf = [[ReferFriendViewController alloc] initWithNibName:@"ReferFriendViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        rf = [[ReferFriendViewController alloc] initWithNibName:@"ReferFriendViewController" bundle:[NSBundle mainBundle]] ;
    }
    [self.navigationController pushViewController:rf animated:YES] ;
rf.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}



-(IBAction)logout:(id)sender
{
    [self logOutFromServer];
    [self goToLoginPageAfterLogout];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    [self performSelector:@selector(showLogoutmessage) withObject:nil afterDelay:1.2f];
}


-(IBAction)termCondition:(id)sender
{
    self.navigationController.navigationBarHidden = NO;
    TermConditionViewController *tc;
    
    // Allocates nib for 'Terms and Condition' controller after detecting device
    
    if([objManager isiPad])
    {
        tc = [[TermConditionViewController alloc] initWithNibName:@"TermConditionViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        tc = [[TermConditionViewController alloc] initWithNibName:@"TermConditionViewController" bundle:[NSBundle mainBundle]] ;
    }
    [self.navigationController pushViewController:tc animated:YES] ;
    tc.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}

-(void)showLogoutmessage
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showSuccessWithStatus:@"You are now logged out"];
}


/**
 *  Logout From Server
 */
-(void)logOutFromServer
{
    @try {
        WebserviceController *ws=[[WebserviceController alloc] init];
      
        NSDictionary *dicData=@{@"user_id":[objManager getData:@"user_id"]};
        [ws call:dicData controller:@"authentication" method:@"logout"];
        AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        NSDictionary *dicData2=@{@"user_id":[objManager getData:@"user_id"],@"device_token":delgate.token};
        [ws call:dicData2 controller:@"push" method:@"unregister_device"];
        
    }
    @catch (NSException *exception) {
        
    }
}

/**
 * Go To Login Page After Logout and Remove All Data from NSUser Default and All Photos from Document Directory
 */

-(void)goToLoginPageAfterLogout
{
    [dmc removeAllData];
    
    [objManager storeData:@"" :@"twFriendList"];
    
    LoginViewController *login=[[LoginViewController alloc] init];
    [self presentViewController:login animated:NO completion:nil] ;
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    CGFloat navBarYPos;
    CGFloat navBarHeight;
    
    if(IS_OS_7_OR_LATER)
        navBarYPos=20;
    else
        navBarYPos=0;
    
    if([objManager isiPad])
        navBarHeight=110;
    else
        navBarHeight=60;
    
    navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, navBarYPos, [UIScreen mainScreen].bounds.size.width, navBarHeight)];
    
    [navnBar loadNav];
    
    [[self view] addSubview:navnBar];
    
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}


#pragma mark - Device Orientation Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self orientCheck:toInterfaceOrientation];
}
-(void)orientCheck :(UIInterfaceOrientation)orientation
{
    // Sets custom background for devices according to orientation
    
    if([objManager isiPad])
    {
        if(UIInterfaceOrientationIsPortrait(orientation))
        {
            profilePicImgView.image=[UIImage imageNamed:@"settingsipadportrait.png"];
        }
        else
        {
            profilePicImgView.image=[UIImage imageNamed:@"settingsIpadLandscape.png"];
        }
    }
    else
    {
        if(UIInterfaceOrientationIsPortrait(orientation))
        {
            profilePicImgView.image=[UIImage imageNamed:@"settingsiphoneportrait.png"];
        }
        else
        {
            profilePicImgView.image=[UIImage imageNamed:@"settingsiphonelandscape.png"];
        }
        
    }
    
}
@end
