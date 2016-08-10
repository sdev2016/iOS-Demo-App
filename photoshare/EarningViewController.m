// 
// EarningViewController.m
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "EarningViewController.h"
#import "PastPayementViewController.h"
#import "MyReferralViewController.h"
#import "FinanceCalculatorViewController.h"
#import "ReferFriendViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "ContentManager.h"

@interface EarningViewController ()

@end

@implementation EarningViewController
{
    NSNumber *userID;
    NSString *service;
    BOOL checkAgain;
}
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
        [[NSBundle mainBundle] loadNibNamed:@"EarningViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"EarningViewController" owner:self options:nil];
    }
    dmc = [[DataMapperController alloc] init];
    objManager = [ContentManager sharedManager];
    [self addCustomNavigationBar];
    
    userID = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
    webservice = [[WebserviceController alloc] init] ;
    
    [self getEarning];
     checkAgain = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(deviceOrientDetect) userInfo:nil repeats:NO];
}

/**
 *  Get Earning Details From Server
 */

-(void)getEarning
{
    webservice.delegate = self;
    isGetEarning=YES;
    NSDictionary *dictData = @{@"user_id":userID};
    [webservice call:dictData controller:@"user" method:@"getearningsdetails"];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
   
}

/**
 *  Get Income Details From Server
 */
-(void)getIncomeFromServer
{
    userID = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
    isGetIcomeDetail=YES;
    webservice.delegate=self;
    NSDictionary *dicData=@{@"user_id":userID};
    [webservice call:dicData controller:@"referral" method:@"calculateincome"];
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
   
   if(isGetEarning)
   {
       // Get the earning details from server and set them in the view
       
       if([data count] == 0 || exitCode == 0)
       {
           [SVProgressHUD dismissWithError:@"Failed To load Data"];
       }
       else
       {
           NSString *totalEarnStr = [NSString stringWithFormat:@"%@",[outPutData valueForKey:@"total_earnings"]];
           totalEarningLabel.text = [@"£" stringByAppendingString:totalEarnStr];
       }
       isGetEarning=NO;
       [self getIncomeFromServer];
   }
    else if(isGetIcomeDetail)
    {
        // Get the weekly income details from server and set them in the view
        
        if([data count] == 0 || exitCode == 0)
        {
            [SVProgressHUD dismissWithError:@"Failed To load Data"];
        }
        else
        {
            NSNumber *dict = [outPutData valueForKey:@"total_expected_income"];
            objManager.weeklyearningStr = [NSString stringWithFormat:@"%@",dict];
            [navnBar setTheTotalEarning:objManager.weeklyearningStr];
            
            [SVProgressHUD dismissWithSuccess:@"Success"];
        }
        isGetIcomeDetail=NO;
    }
}

#pragma mark - UIButton Action Methods

- (IBAction)viewPastPaymentsBtn:(id)sender {
    self.navigationController.navigationBarHidden = YES;
    PastPayementViewController *pastPay = [[PastPayementViewController alloc] init];
    [self.navigationController pushViewController:pastPay animated:YES];
}

- (IBAction)financeCalculatorBtn:(id)sender {
    self.navigationController.navigationBarHidden = YES;
    FinanceCalculatorViewController *financeCalci = [[FinanceCalculatorViewController alloc] init];
    [self.navigationController pushViewController:financeCalci animated:YES];
}

- (IBAction)inviteMoreFriendsBtn:(id)sender {
    self.navigationController.navigationBarHidden = YES;
    ReferFriendViewController *referFriend = [[ReferFriendViewController alloc] init];
    [self.navigationController pushViewController:referFriend animated:YES];
}

- (IBAction)yourReferrelBtn:(id)sender {
    self.navigationController.navigationBarHidden = YES;
    MyReferralViewController *mtReffVC = [[MyReferralViewController alloc] init];
    [self.navigationController pushViewController:mtReffVC animated:YES];
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    navnBar=[[NavigationBar alloc] init];
    [navnBar loadNav];
    UILabel *navTitle = [navnBar navBarTitleLabel:@"My Money"];
    
    [navnBar addSubview:navTitle];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
    
    if(!checkAgain)
    {
        [self getEarning];
    }
    checkAgain = NO;
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Device Orientation Methods

-(void)deviceOrientDetect
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
}
-(void)orient:(UIInterfaceOrientation)ott
{
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 90.0f, 480.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(480,400);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 90.0f, 568.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(568,400);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 190.0f, 1024.0f, 768.0f);
            scrollView.contentSize = CGSizeMake(1024,1000);
            scrollView.bounces = NO;
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 90.0f, 320.0f, 327.0f);
            scrollView.contentSize = CGSizeMake(320,257);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 90.0f, 320.0f, 415.0f);
            scrollView.contentSize = CGSizeMake(320,320);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 185.0f, 768.0f, 800.0f);
            scrollView.contentSize = CGSizeMake(768,700);
            scrollView.bounces = NO;
        }
    }
   if(![objManager isiPad])
   {
       // Sets UI for IOS 6
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
@end
