// 
// PhotoViewController.h
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "ContentManager.h"
#import "DataMapperController.h"
#import "WebserviceController.h"
#import "LargePhotoViewController.h"
#import "NavigationBar.h"
// for Aviary
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "AFPhotoEditorController.h"
#import "AFPhotoEditorCustomization.h"
#import "AFOpenGLManager.h"
#import "DataMapperController.h"

#import <CoreLocation/CoreLocation.h>

@interface PhotoViewController : UIViewController
<WebserviceDelegate,AFPhotoEditorControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,UITextFieldDelegate,UITextViewDelegate,CLLocationManagerDelegate>
{
    
    // GETS the userf location
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
       
    NSNumber *selectedCollectionId;
    NSData *imgData;
    UIPickerView *categoryPickerView;
    UIToolbar *pickerToolbar;
    
    NSNumber *userid;
    DataMapperController *dmc;
    
    ContentManager *manager;
    LargePhotoViewController *largeImage;
    WebserviceController *webservices;
    NavigationBar *navnBar;
    BOOL isSavePhotoOnServer;
    
    UIImage *pickImage;
    BOOL isCameraMode;
    BOOL isCameraEditMode;
    
    BOOL isPhotoOwner;
    
    BOOL isViewLargeImageMode;
    
    UIImage *originalImage;
    BOOL isoriginalImageGet;
    IBOutlet UIImageView *imageView;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UILabel *folderLocationShowLabel;
    IBOutlet UILabel *folderLocationIndicator;
    IBOutlet UIButton *photoViewBtn;
    UILabel *photoTitleLBL;
    UIImageView *imgV;
    
    
    UIView *backViewPhotDetail;
    UITextField *photoTitleTF;
    UITextView *photoDescriptionTF;
    UITextField *phototagTF;
    
    NSString *photoTitleStr;
    NSString *photoDescriptionStr;
    NSString *photoTagStr;
    NSString *photoLocationStr;
}
- (IBAction)segmentSwitch:(id)sender;
- (IBAction)viewPhoto:(id)sender;


@property(nonatomic,retain)NSNumber *photoId;
@property(nonatomic,assign)NSNumber *collectionId;
@property(nonatomic,assign)NSNumber *collectionOwnerId;
@property(nonatomic,assign)NSNumber *photoOwnerId;
@property(nonatomic,assign)NSInteger selectedIndex;
@property(nonatomic,retain)UIImage *smallImage;
@property(nonatomic,retain)NSString *folderName;
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;
@property(nonatomic,assign)BOOL isViewPhoto;
@property(nonatomic,assign)BOOL isPublicFolder;
@property(nonatomic,assign)BOOL isOnlyReadPermission;

@end

