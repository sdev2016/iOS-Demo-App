// 
// LaunchCameraViewController.h
// photoshare
// 
// Created by ignis2 on 03/02/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "ContentManager.h"
#import "DataMapperController.h"
#import "WebserviceController.h"
// for Aviary
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "AFPhotoEditorController.h"
#import "AFPhotoEditorCustomization.h"
#import "AFOpenGLManager.h"

#import "HomeViewController.h"
#import "DataMapperController.h"
#import "NavigationBar.h"
#import <CoreLocation/CoreLocation.h>
@interface LaunchCameraViewController : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WebserviceDelegate,AFPhotoEditorControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate,UITextViewDelegate,UIPopoverControllerDelegate,UITabBarControllerDelegate>
{
    IBOutlet UIPickerView *categoryPickerView;
    IBOutlet UIImageView *imgView;
    
    // GETS the userf location
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    NSMutableArray *collectionNameArray;
    NSMutableArray *collectionIdArray;
    
    NSNumber *publicCollectionId;
    NSNumber *selectedCollectionId;
    NSData *imgData;
    UIToolbar *pickerToolbar;
    
    NSNumber *userid;
    DataMapperController *dmc;
    ContentManager *manager;
    WebserviceController *webservices;
    NavigationBar *navnBar;
    HomeViewController *home;
    UIImage *pickImage;

    BOOL isCameraEditMode;
    BOOL isPhotoSavingMode;
    BOOL isGetSharedCollList;
    
    
    NSString *photoTitleStr;
    NSString *photoDescriptionStr;
    NSString *photoTagStr;
    NSString *photoLocationStr;
    
    UIInterfaceOrientation orientation;
    UILabel *titleLabe;
}
@property(nonatomic,retain)UIImage *pickerimage;
// for Aviary
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;

// for popover
@property (nonatomic, strong) UIPopoverController * popover;
@property (nonatomic, assign) BOOL shouldReleasePopover;

@end
