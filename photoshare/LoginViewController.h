// 
// LoginViewController.h
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WebserviceController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ContentManager.h"
#import "DataMapperController.h"
#import "HomeViewController.h"
#import "CommunityViewController.h"
#import "EarningViewController.h"
#import "ReferFriendViewController.h"
#import "AccountViewController.h"
#import "WebserviceController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "LaunchCameraViewController.h"
#import "ContentManager.h"
#import "CameraViewController.h"
@class ContentManager;
@interface LoginViewController : UIViewController <UITextFieldDelegate, WebserviceDelegate,UITabBarControllerDelegate>
{
    IBOutlet UIImageView *loginBackgroundImage;
    IBOutlet UIImageView *loginLogoImage;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIButton *signinBtn;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIButton *namecancelBtn;
    IBOutlet UIButton *passwordcancelBtn;
    IBOutlet UIButton *rememberMeBtn;
    IBOutlet UIButton *forgetPwd;
    
    BOOL usrFlt, pwsFlt;
    BOOL rememberFltr;
    BOOL isGetTheCollectionListData;
    BOOL isGetLoginDetail;
    BOOL isGetStorage;
    BOOL isGetIcomeDetail;
    BOOL isGetSharingUserId;
    BOOL isGetTheOwnCollectionListData;
    BOOL isGetTheSharingCollectionListData;
    
    WebserviceController *webservices;
    ContentManager *manager;
    DataMapperController *dmc;
    ContentManager *objManager;
    AppDelegate *delegate;
    HomeViewController *hm;
    EarningViewController *ea;
    LaunchCameraViewController *lcam;
    CommunityViewController *com;
    AccountViewController *acc;
    CameraViewController *cameravc;
    
    
    NSMutableArray *sharingIdArray;
    NSMutableArray *collectionArrayWithSharing;
    int countSharing;
    NSNumber *userid;
    UIView *dataFetchView;
        
}
@property(nonatomic,retain)ALAssetsLibrary *library;
- (IBAction)rememberBtnTapped;
@end
