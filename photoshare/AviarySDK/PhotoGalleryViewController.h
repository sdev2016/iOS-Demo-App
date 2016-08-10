// 
// PhotoGalleryViewController.h
// photoshare
// 
// Created by ignis2 on 25/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WebserviceController.h"
#import "ContentManager.h"
#import "NavigationBar.h"
#import "SearchPhotoViewController.h"
// for Aviary
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "AFPhotoEditorController.h"
#import "AFPhotoEditorCustomization.h"
#import "AFOpenGLManager.h"

#import <CoreLocation/CoreLocation.h>

// for mail send
#import <MessageUI/MFMailComposeViewController.h>
// For Select the Multiple images use Custom ELCImagePicker
#import "CTAssetsPickerController.h"

#import "UploadMultiplePhotoOnServerViewController.h"
@interface PhotoGalleryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,AFPhotoEditorControllerDelegate,WebserviceDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate,CLLocationManagerDelegate,UITextViewDelegate,MFMailComposeViewControllerDelegate,UIPopoverControllerDelegate,CTAssetsPickerControllerDelegate,UploadMultiplePhotoOnServerViewControllerDelegate>
{
    // GETS the userf location
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    IBOutlet UIButton           *addPhotoBtn;
    IBOutlet UIButton           *deletePhotoBtn;
    IBOutlet UIButton           *sharePhotoBtn;
    IBOutlet UICollectionView   *collectionview;
    IBOutlet UILabel            *emptyMessageLbl;
    WebserviceController        *webServices;
    SearchPhotoViewController   *searchController;
    
   
    NSMutableArray *selectedImagesIndex;
    NSString *refrenceUrlofImg;    
    NSNumber *userid;
    NSArray *sortedArray;
    NSArray *shareSortedArray;
    NSMutableArray *photoIdsArray;
    NSMutableArray *photoArray;
    NSMutableArray *photoInfoArray;
    
    int selectedEditImageIndex;
    BOOL isDeleteMode;
    BOOL isShareMode;
    
    
    BOOL isGetPhotoIdFromServer;
    BOOL isGetPhotoFromServer;
    BOOL isSaveDataOnServer;
    BOOL isEditImageFromServer;
    
    BOOL isNotFirstTime;
    BOOL isAviaryMode;
    int deleteImageCount;
    
    BOOL isPopFromPhotos;
    BOOL isGoToViewPhoto;
    BOOL isMailSendMode;
    
    UIImage *pickImage;
    BOOL isCameraMode;
    BOOL isCameraEditMode;
    BOOL isPhotoPickMode;
    
    // permission type of collection data
    BOOL isWritePermission;
    BOOL isReadPermission;
    BOOL isPhotoOwner;
    
    NSString *assetUrlOfImage;
    
    UIView *progressBarGestureView;
    
    ContentManager *manager;
    NavigationBar *navnBar;
    
    NSArray *selectedImagesArray;// Select Multiple images from picker 
    
    NSData *imageData;
    UIImage *editedImage;
    
    // for add photo Detail
    UIView *backViewPhotDetail;
    UITextField *photoTitleTF;
    UITextView *photoDescriptionTF;
    UITextField *phototagTF;
    
    NSString *photoTitleStr;
    NSString *photoDescriptionStr;
    NSString *photoTagStr;
    NSString *photoLocationStr; // userLoaction is save
    
    // for Multiple Photo
    UploadMultiplePhotoOnServerViewController *uploadMultiPlePhoto;
    
    NSInteger countRecievedPhoto;
    BOOL isCallMultiplePhoto;
    
    NSNumber *imgIdTemp;
    UIImage *imgTemp;
}
@property(nonatomic,assign)BOOL isPublicFolder;
@property(nonatomic,assign)int selectedFolderIndex;

@property(nonatomic,assign)NSNumber *collectionId;
@property(nonatomic,assign)NSNumber *collectionOwnerId;

@property(nonatomic,retain)NSString *folderName;
// For multiple image select
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
// for Aviary
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;
@property(nonatomic,retain)UIPopoverController *popover;
-(IBAction)addPhoto:(id)sender;
-(IBAction)deletePhoto:(id)sender;
-(IBAction)sharePhoto:(id)sender;
@end
