// 
// ReferFriendViewController.m
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "ReferFriendViewController.h"
#import "ReferralStageFourVC.h"
#import "SVProgressHUD.h"
#import "ContentManager.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "CustomCells.h"

@interface ReferFriendViewController ()

@end

@implementation ReferFriendViewController
{
    NSNumber *userID;
    NSMutableArray *toolkitIDArr;
    NSMutableArray *toolkitTitleArr;
    NSMutableArray *toolkitVimeoIDArr;
    NSMutableArray *toolkitEarningArr;
    NSMutableArray *toolkitreferralsArr;
    NSMutableArray *toolKitVisiblityArr;
    NSString *segmentControllerIndexStr;
    NSMutableArray *toolKitNameArray;
    UICollectionViewFlowLayout *layout;
    CGRect pickerFrame;
}
@synthesize webViewReferral,toolKitReferralStr, mypicker;
@synthesize collectionView = _collectionView;

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
        [[NSBundle mainBundle] loadNibNamed:@"ReferFriendViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"ReferFriendViewController" owner:self options:nil];
    }
    
    objManager = [ContentManager sharedManager];
    if([UIScreen mainScreen].bounds.size.height==568)
    {
        mypicker.frame=CGRectMake(mypicker.frame.origin.x, mypicker.frame.origin.y+20, mypicker.frame.size.width, mypicker.frame.size.height);
    }
    
    
    
    titleTextView.text=@"Select Invite Videos to refer friends";
    subTitle.text=@"(Check out the referral video tips too)";
    
    
    [self addCustomNavigationBar];
    
    // Allocate & initializing Array
    toolkitIDArr = [[NSMutableArray alloc] init];
    toolkitTitleArr = [[NSMutableArray alloc] init];
    toolkitVimeoIDArr = [[NSMutableArray alloc] init];
    toolkitEarningArr = [[NSMutableArray alloc] init];
    toolkitreferralsArr = [[NSMutableArray alloc] init];
    toolKitNameArray = [[NSMutableArray alloc] init];
    toolKitVisiblityArr=[[NSMutableArray alloc] init];
    
    segmentControllerIndexStr = @"";
    
    userID = [objManager getData:@"user_id"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    
    // Get ToolKit details
    WebserviceController *wb = [[WebserviceController alloc] init];
    wb.delegate = self;
    NSDictionary *dictData = @{@"user_id":userID};
    [wb call:dictData controller:@"toolkit" method:@"getall"] ;
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    
    // Checking device
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        // Customizing frame of webview
        
        if([[UIScreen mainScreen] bounds].size.height == 480)
        {
            // FOR 3.5 INCH
            CGRect frame = webViewReferral.frame;
            frame.origin.y = 55;
            frame.size.height = 180;
            webViewReferral.frame = frame;
            
            // UIPicker
            CGRect framePick = mypicker.frame;
            framePick.origin.y = 210;
            mypicker.frame = framePick;
        }
    }
    
    toolKitReferralStr = @"";
    webViewReferral.scalesPageToFit = YES;
    webViewReferral.autoresizesSubviews = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    activeIndex=0;
    [self detectDeviceOrientation];
    
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

#pragma mark - WebService Delegate Method

-(void) webserviceCallback:(NSDictionary *)data
{
    // Check if response was recieved
    
    int exitCode = [[data valueForKey:@"exit_code"] intValue];
    
    if(exitCode == 0)
    {
        [SVProgressHUD dismissWithError:@"loading Failed"];
    }
    else if([data count] == 0)
    {
        [SVProgressHUD dismissWithError:@"loading Failed"];
    }
    else
    {
        [SVProgressHUD dismissWithSuccess:@"Success"];
            NSMutableArray *outPutData=[data objectForKey:@"output_data"];
        // Set The Toolkit Details
        toolkitIDArr = [outPutData valueForKey:@"toolkit_id"];
        toolkitTitleArr = [outPutData valueForKey:@"title"];
        toolkitVimeoIDArr = [outPutData valueForKey:@"vimeo_id"];
        toolkitEarningArr = [outPutData valueForKey:@"earnings"];
        toolkitreferralsArr = [outPutData valueForKey:@"referrals"];
        toolKitVisiblityArr=[outPutData valueForKey:@"visible"];
        [self loadData];
        [mypicker reloadAllComponents];
    }
}

/**
 *  Set The Data on WebView
 */

-(void)loadData
{
    // Load video from vimeo by default
    
    webViewReferral.delegate = self;
    [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:0]]]]];
    toolKitReferralStr = [NSString stringWithFormat:@"http://my.123friday.com/my123/live/toolkit/%@/%@",[toolkitIDArr objectAtIndex:0],[objManager getData:@"user_username"]];
    mypicker.layer.borderWidth = 1.0;
    mypicker.layer.borderColor = [UIColor blackColor].CGColor;
}

#pragma mark - UIPickerView Delegate and DataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component ==  0)
    {
        if(toolkitTitleArr.count > 0)
        {
            return toolkitTitleArr.count;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component==0)
    {
        return [toolkitTitleArr objectAtIndex:row];
    }
    else
    {
        return 0;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Video name: %@",[toolkitTitleArr objectAtIndex:row]);
    NSLog(@"%ld",(long)row);
    @try {
      // Add video referral in message imported from vimeo
      
      if(activeIndex!=row)
      {
          activeIndex=row;
          [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:row]]]]];
          toolKitReferralStr = [NSString stringWithFormat:@"http://my.123friday.com/my123/live/toolkit/%@/%@",[toolkitIDArr objectAtIndex:row],[objManager getData:@"user_username"]];
      }
    }
    @catch (NSException *exception) {
        
    } 
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 568, 50)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    }
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024, 80)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    }
    
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor whiteColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@",[toolkitTitleArr objectAtIndex:row]];
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        return 50.0;
    }
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return 80.0;
    }
    else
    {
        return 0;
    }
}

/**
 *  Open ReferralStageFourVC Controller
 */
-(void)chooseView
{
    ReferralStageFourVC *rf4 = [[ReferralStageFourVC alloc] init];
    
    rf4.toolkitLink = toolKitReferralStr;
    [self.navigationController pushViewController:rf4 animated:YES];

}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    // Add custom buttons in navigation bar
    
    // Button for back
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    UILabel *navTitle = [navnBar navBarTitleLabel:@"Refer Friends"];
    // Button for next
    UIButton *buttonLeft = [navnBar navBarRightButton:@"Next >"];
    [buttonLeft addTarget:self action:@selector(chooseView) forControlEvents:UIControlEventTouchDown];
    
    [navnBar addSubview:button];
    [navnBar addSubview:navTitle];
    [navnBar addSubview:buttonLeft];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    delgate.isGoToReferFriendController=NO;
    
    [[self navigationController] popViewControllerAnimated:YES];
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
        scrollView.scrollEnabled=YES;
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 480, 300);
            scrollView.contentSize = CGSizeMake(480, 440);
            scrollView.bounces = NO;
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 568, 300);
            scrollView.contentSize = CGSizeMake(568, 490);
            scrollView.bounces = NO;
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
            
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 1024, 700);
            scrollView.contentSize = CGSizeMake(1024, 850);
            scrollView.bounces = NO;
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        scrollView.scrollEnabled=NO;
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 370);
            scrollView.contentSize = CGSizeMake(320, 350);
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
            
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 423);
            scrollView.contentSize = CGSizeMake(320, 300);
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
            
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 768, 780);
            scrollView.contentSize = CGSizeMake(768, 600);
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
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self orient:toInterfaceOrientation];
}

-(void)setUIForIOS6
{
    // Set for IOS6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        scrollView.contentSize=CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height+90);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
