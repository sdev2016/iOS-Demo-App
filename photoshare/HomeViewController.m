// 
// HomeViewController.m
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "HomeViewController.h"
#import "ContentManager.h"
#import "AppDelegate.h"
#import "CommunityViewController.h"
#import "PhotoGalleryViewController.h"
#import "EarningViewController.h"
#import "LoginViewController.h"
#import "ReferFriendViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "NavigationBar.h"

#import "SVProgressHUD.h"
#import "ReferFriendViewController.h"
#import "LaunchCameraViewController.h"
#import "UploadMultiplePhotoOnServerViewController.h"
@interface HomeViewController ()

@end

@implementation HomeViewController
{
    NSString *servicesStr;
    NavigationBar *navnBar;
    CommunityViewController *com;
    PhotoGalleryViewController *photoGallery;
    ReferFriendViewController *lcam;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}
#pragma mark - ViewController methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Detect device and load nib
    
    if([[ContentManager sharedManager] isiPad])
    {
        [[NSBundle mainBundle] loadNibNamed:@"HomeViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"HomeViewController" owner:self options:nil];
    }
    [self initializeTheObject];
    [self addCustomNavigationBar];
    [self setUIForIOS6];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self orientCheck:[[UIApplication sharedApplication] statusBarOrientation]];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    
    // Set Total Earning in navigation bar
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    [self setThePublicCollectionInfo];
    
    // To launch camera
    [manager storeData:@"NO" :@"istabcamera"];
    [manager removeData:@"isfromphotodetailcontroller,is_add_folder,reset_camera"];
    
    [self setTheUSerDetails];
    AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    delegate.navControllercommunity.viewControllers=[[NSArray alloc] initWithObjects:com,nil];
    
    // Sets Tabbar index for homepage
    
    [self.tabBarController setSelectedIndex:0];
   

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

-(void)setUIForIOS6
{
    // Sets IOS 6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        profilePicImgView.frame=CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height);
        folderIconViewContainer.frame=CGRectMake(0, folderIconViewContainer.frame.origin.y+40,self.view.frame.size.width, folderIconViewContainer.frame.size.height);
    }
}

/**
 *  Custom Initialization
 */

-(void)initializeTheObject
{
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    com =[[CommunityViewController alloc] init];
    lcam=[[ReferFriendViewController alloc] init];
    dmc = [[DataMapperController alloc] init];
    userid = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
}

/**
 *  Set The User Details in UI Object
 */

-(void)setTheUSerDetails
{
    UIView *vi = [self.tabBarController.view viewWithTag:11];
    UILabel *lbl = (UILabel *)[vi viewWithTag:1] ;
    NSDictionary *dic = [dmc getUserDetails] ;
    NSNumber *total = [dic objectForKey:@"total_earnings"] ;
    lbl.text = [NSString  stringWithFormat:@"£%@", total];
    welcomeName.text=[dic objectForKey:@"user_realname"];
    self.navigationController.navigationBarHidden=YES;
}

#pragma mark - UITextField Delegate Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return  [textField resignFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(IBAction)goToReferFriend:(id)sender
{
    [self.navigationController pushViewController:lcam animated:YES];
}

-(IBAction)goToPublicFolder:(id)sender
{
    photoGallery=nil;
    photoGallery=[[PhotoGalleryViewController alloc] init];
    
    // Gets the collection info from NSUserDefault
    
    photoGallery.isPublicFolder=YES;
    photoGallery.collectionId=publicCollectionId;
    photoGallery.folderName=@"Public";
    photoGallery.selectedFolderIndex=folderIndex;
    photoGallery.collectionOwnerId=colOwnerId;
    [self.navigationController pushViewController:photoGallery animated:YES];
}



-(IBAction)goToCommunity:(id)sender
{
    CommunityViewController *comm=[[CommunityViewController alloc] init];
    comm.isInNavigation=YES;
    [self.tabBarController setSelectedIndex:3];
}

/**
 *  Set The Public Collection Detail
 */

-(void)setThePublicCollectionInfo
{
    NSMutableArray *collection=[dmc getCollectionDataList];
    @try {
        __block NSDictionary *dict=nil;
        [collection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dict=(NSDictionary *)obj;
            NSString *colName=[dict objectForKey:@"collection_name"];
            if([colName isEqualToString:@"public"] || [colName isEqualToString:@"Public"])
            {
                *stop=YES;
            }
        }];
        
        // Sets variables with values
        
        colOwnerId=[dict objectForKey:@"collection_user_id"];
        publicCollectionId=[dict objectForKey:@"collection_id"];
        folderIndex=[collection indexOfObject:dict];
        [manager storeData:publicCollectionId :@"public_collection_id"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exec in HomeView Controller%@",exception.description);
    }
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    // Sets earning details after recieving data from server
    
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    if([servicesStr isEqualToString:@"two"])
    {
        if(exitCode.integerValue==1)
        {
            NSMutableArray *outPutDatas =[data objectForKey:@"output_data"];
            NSString *strEarning = [NSString stringWithFormat:@"%@",[outPutDatas valueForKey:@"total_expected_income"]];
            [navnBar setTheTotalEarning:strEarning];
            servicesStr = @"";
        }
    }
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    CGFloat navBarYPos;
    CGFloat navBarHeight;
    
    // Checks for ios version and device type to set navigation bar
    
    if(IS_OS_7_OR_LATER)
        navBarYPos=20;
    else
        navBarYPos=0;
    
    if([manager isiPad])
        navBarHeight=110;
    else
        navBarHeight=60;
    
    navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, navBarYPos, [UIScreen mainScreen].bounds.size.width, navBarHeight)];
    
    [navnBar loadNav];
    [[self view] addSubview:navnBar];
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
    if([manager isiPad])
    {
        if(UIInterfaceOrientationIsPortrait(orientation))
        {
            profilePicImgView.image=[UIImage imageNamed:@"homeipadportrait.png"];
        }
        else
        {
            profilePicImgView.image=[UIImage imageNamed:@"homeipadlandscape.png"];
        }
    }
    else
    {
        if(UIInterfaceOrientationIsPortrait(orientation))
        {
            profilePicImgView.image=[UIImage imageNamed:@"homeiphoneportrait.png"];
        }
        else
        {
            profilePicImgView.image=[UIImage imageNamed:@"homeiphonelandscape.png"];
        }
        
    }

}
@end

