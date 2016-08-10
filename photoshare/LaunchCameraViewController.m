// 
// LaunchCameraViewController.m
// photoshare
// 
// Created by ignis2 on 03/02/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "LaunchCameraViewController.h"
#import "AppDelegate.h"

#import "SVProgressHUD.h"
#import "EditPhotoDetailViewController.h"
#import "AddEditFolderViewController.h"

@interface LaunchCameraViewController ()
{
    NSInteger globalIndex;
    
}
@end

@implementation LaunchCameraViewController
@synthesize sessions,assetLibrary,pickerimage;

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
    globalIndex = 0;
    
    // Detect device and load nib
    
    if([[ContentManager sharedManager] isiPad])
    {
        [[NSBundle mainBundle] loadNibNamed:@"LaunchCameraViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"LaunchCameraViewController" owner:self options:nil];
    }
    [self setUIForIOS6];
    
    // Initializes all needed objects
    
    @try {
        collectionIdArray=[[NSMutableArray alloc] init];
        collectionNameArray=[[NSMutableArray alloc] init];
        webservices=[[WebserviceController alloc] init];
        home=[[HomeViewController alloc] init];
        
        manager=[ContentManager sharedManager];
        dmc=[[DataMapperController alloc] init];
        NSDictionary *dic = [[dmc getUserDetails] mutableCopy];
        userid=[dic objectForKey:@"user_id"];
        [self showSelectFolderOption];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in Launch Camera: %@",exception.description);
    }
    
    [self addCustomNavigationBar];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
  
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    @try {
        if([[manager getData:@"reset_camera"] isEqualToString:@"YES"])
        {
              titleLabe.text=@"Select Folder";
            
            // Aviary Editor Open
            [self openAviaryEditor:self.pickerimage];
            [manager removeData:@"reset_camera"];
        }
        else
        {
            if([[manager getData:@"is_add_folder"] isEqualToString:@"YES"])
            {
                [manager storeData:@"NO" :@"is_add_folder"];
                @try {
                    NSNumber *newcolid=[manager getData:@"new_col_id"];
                    if(newcolid!=nil)
                    {
                        [self getCollectionInfoFromUserDefault];
                        NSInteger index=[collectionIdArray indexOfObject:[NSString stringWithFormat:@"%@",newcolid]];
                        
                        globalIndex = index;
                        
                        // Set picker row
                        [categoryPickerView reloadAllComponents];
                        [categoryPickerView selectRow:index inComponent:0 animated:NO];
                        titleLabe.text=[collectionNameArray objectAtIndex:index];
                        selectedCollectionId=[collectionIdArray objectAtIndex:index];
                    }

                    [manager removeData:@"is_add_folder,new_col_id"];
                }
                @catch (NSException *exception) {
                    
                }
            }
            else
            {
                if([[manager getData:@"isfromphotodetailcontroller"] isEqualToString:@"YES"])
                {
                    if(isGetSharedCollList)
                    {
                        [SVProgressHUD showWithStatus:@"Loading"];
                    }
                    else
                    {
                        [SVProgressHUD dismiss];
                    }
                    selectedCollectionId=@-1;
                    [self callGetLocation];
                    
                    photoTitleStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_title"];
                    photoDescriptionStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_description"];
                    photoTagStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_tags"];
                    
                    imgData=[manager getData:@"photo_data"];
                    imgView.image=[UIImage imageWithData:imgData];

                    [manager removeData:@"isfromphotodetailcontroller,photo_data,takephotodetail"];
                }
            }
        }
    }
    @catch (NSException *exception) {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *  For IOS6
 */
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        categoryPickerView.frame=CGRectMake(categoryPickerView.frame.origin.x, categoryPickerView.frame.origin.y+50, categoryPickerView.frame.size.width, categoryPickerView.frame.size.height);
    }
    
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


-(void)openeditorcontrol
{
    [self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];
}

/**
 *  Get Collection Details in NSUserDefaults for collections to populate picker view
 */

-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[dmc getCollectionDataList];
    [collectionIdArray removeAllObjects];
    [collectionNameArray removeAllObjects];
    [categoryPickerView reloadAllComponents];
    selectedCollectionId=@-1;
    @try {
        NSMutableArray *shareColIdsArray=[[NSMutableArray alloc] init];
        NSMutableArray *shareCollectionIArray = [[NSMutableArray alloc] init];
        
        for (int i=0;i<collection.count+2; i++)
        {
            if(i==0)
            {
                [collectionIdArray addObject:@-1];
                [collectionNameArray addObject:@"Select Folder"];
                
            }
            else if (i==1)
            {
                [collectionIdArray addObject:@-101];
                [collectionNameArray addObject:@"Add New Folder"];
            }
            else
            {
                NSNumber *coluserId=[[collection objectAtIndex:i-2] objectForKey:@"collection_user_id"];
                
                if(coluserId.integerValue==userid.integerValue)
                {
                    if([[[collection objectAtIndex:i-2] objectForKey:@"collection_name"] isEqualToString:@"Public"]||[[[collection objectAtIndex:i-2] objectForKey:@"collection_name"] isEqualToString:@"public"])
                    {
                        publicCollectionId=[[collection objectAtIndex:i-2] objectForKey:@"collection_id"];
                        
                        [collectionIdArray addObject:publicCollectionId];
                        [collectionNameArray addObject:@"123 Public"];
                    }
                    else
                    {
                        [collectionIdArray addObject:[[collection objectAtIndex:i-2] objectForKey:@"collection_id"]];
                        [collectionNameArray addObject:[[collection objectAtIndex:i-2] objectForKey:@"collection_name"]];
                    }
                }
                else
                {
                    [shareColIdsArray addObject:[[collection objectAtIndex:i-2] objectForKey:@"collection_id"]];
                    [shareCollectionIArray addObject:[[collection objectAtIndex:i-2] objectForKey:@"collection_user_id"]];
                }
            }
        }
        if(shareColIdsArray.count>0)
        {
            isGetSharedCollList=YES;
            webservices.delegate=self;
            [webservices getSharedCollectionList:shareColIdsArray userid:userid];
        }
        else
        {
            [categoryPickerView reloadAllComponents];
            [categoryPickerView selectRow:0 inComponent:0 animated:NO];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exec is %@",exception.description);
    }
    
}

/**
 *  Get The Write Permission Shared Collection List
 */

-(void)responseShareWritePermissionCollectionList:(NSArray *)colIdArray colNameArr:(NSArray *)colNameArr
{
    @try {
        [SVProgressHUD dismiss];
        isGetSharedCollList=NO;
        [collectionIdArray addObjectsFromArray:colIdArray];
        [collectionNameArray addObjectsFromArray:colNameArr];
        [categoryPickerView reloadAllComponents];
        [categoryPickerView selectRow:globalIndex inComponent:0 animated:NO];
    }
    @catch (NSException *exception) {
        
    }
}

/**
 *  Open Aviary Editor
 */
-(void)openAviaryEditor:(UIImage *)image
{
    @try {
        [self getCollectionInfoFromUserDefault];
        imgView.image=nil;
        photoLocationStr=@"";
        imgView.image=image;
        pickImage=image;
        isCameraEditMode=YES;
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
        [NSTimer scheduledTimerWithTimeInterval:0.0f   target:self selector:@selector(openeditorcontrol) userInfo:nil  repeats:NO];
        [self dismissViewControllerAnimated:NO completion:Nil];
    }
    @catch (NSException *exception) {
        
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


#pragma mark - Aviary Editor Methods

- (void) launchEditorWithAsset:(ALAsset *)asset
{
    UIImage * editingResImage = [self editingResImageForAsset:asset];
    UIImage * highResImage = [self highResImageForAsset:asset];
    
    [self launchPhotoEditorWithImage:editingResImage highResolutionImage:highResImage];
}




- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    [SVProgressHUD dismiss];
    
    // Customize editors appearance
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Init photoeditor and set delegates
    
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    photoEditor.view.frame=CGRectMake(0, 100, 320, 300);
    [photoEditor setDelegate:self];
    
    // Creates high resolution context image of photo editor
    
    if (highResImage) {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    }
    
    // Presents photo editor
    
    [self presentViewController:photoEditor animated:YES completion:nil];
}

- (void) setupHighResContextForPhotoEditor:(AFPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage
{
    // Capture a reference for editor session
    __block AFPhotoEditorSession *session = [photoEditor session];
   
    [[self sessions] addObject:session];
    
    // Create context for image with high resolution
    AFPhotoEditorContext *context = [session createContextWithImage:highResImage];
    
    __block LaunchCameraViewController * blockSelf = self;
    
    [context render:^(UIImage *result) {
        if (result) {
        }
        
        [[blockSelf sessions] removeObject:session];
        
        blockSelf = nil;
        session = nil;
        
    }];
}

#pragma mark - Photo Editor Delegate Methods

/**
 *  This is called when user taps "DONE" in the photo editor
 */
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    imgView.image=image;
    imgData=UIImagePNGRepresentation(image);
    isCameraEditMode=NO;
    [self resetTheView];
    [self goToPhotoDetailViewController];
}

/**
 *  This is called when user taps "CANCEL" in the photo editor
 */
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self resetTheView];
    [self goToHomePage];
}
-(void)resetTheView
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
#pragma mark - Photo Editor Customization


- (void) setPhotoEditorCustomizationOptions
{
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set custom crop sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    // Set supported resolutions
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AFPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}
/**
 *  ALAssets helper methods
 */

- (UIImage *)editingResImageForAsset:(ALAsset*)asset
{
    CGImageRef image = [[asset defaultRepresentation] fullScreenImage];
    
    return [UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp];
}

- (UIImage *)highResImageForAsset:(ALAsset*)asset
{
    ALAssetRepresentation * representation = [asset defaultRepresentation];
    
    CGImageRef image = [representation fullResolutionImage];
    UIImageOrientation orientationss = (UIImageOrientation)[representation orientation];
    CGFloat scale = [representation scale];
    
    return [UIImage imageWithCGImage:image scale:scale orientation:orientationss];
}

 

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    [SVProgressHUD dismiss];
   
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    if (isPhotoSavingMode)
    {
        if(exitCode.integerValue==1)
        {
            NSLog(@"Photo saving Succees ");
        }
        else
        {
            NSLog(@"Photo saving Fail ");
            [manager showAlert:@"Message" msg:@"Photo Saving Failed" cancelBtnTitle:@"Ok" otherBtn:Nil];
            
        }
         [self removePickerView];
        isPhotoSavingMode=NO;
    }
    
}

/**
 *  Show Select Folder Option
 */

-(void)showSelectFolderOption
{
    @try {
        imgView.contentMode=UIViewContentModeScaleAspectFit;
        imgView.backgroundColor=[UIColor blackColor];
        
        pickerToolbar=[[UIToolbar alloc] init];
        [self.view addSubview:pickerToolbar];
        
        // Added Gesture on category picker
        
        UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerViewTapGestureRecognized:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        [categoryPickerView addGestureRecognizer:gestureRecognizer];
        
        categoryPickerView.backgroundColor=[UIColor whiteColor];
        [categoryPickerView setDataSource: self];
        [categoryPickerView setDelegate: self];
        categoryPickerView.showsSelectionIndicator = YES;
        
        if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)          pickerToolbar.frame=CGRectMake(0,self.view.frame.size.height-180, 320, 40);
        else
        {
            if([manager isiPad])
                pickerToolbar.frame=CGRectMake(0,self.view.frame.size.height-260, 320, 40);
            else
                pickerToolbar.frame=CGRectMake(0,self.view.frame.size.height-222, 320, 40);
        }
        
        // Stes Picker view toolbar
        
        pickerToolbar.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth;
        
        pickerToolbar.barStyle = UIBarStyleBlackOpaque;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        titleLabe=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
        titleLabe.text=@"Select Folder";
        titleLabe.textAlignment =NSTextAlignmentCenter;
        titleLabe.textColor=[UIColor whiteColor];
        titleLabe.backgroundColor=[UIColor clearColor];
        
        // Set barbutton items on picker toolbar
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(categoryCancelButtonPressed)];
        
        UIBarButtonItem *toolBarTitle=[[UIBarButtonItem alloc]  initWithCustomView:titleLabe];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(categoryDoneButtonPressed)];
        
        [barItems addObject:cancelBtn];
        [barItems addObject:flexSpace];
        [barItems addObject:toolBarTitle];
        [barItems addObject:flexSpace];
        [barItems addObject:doneBtn];
        
        [pickerToolbar setItems:barItems animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
}

/**
 *  When category done button is pressed
 */

-(void)categoryDoneButtonPressed{
    if(selectedCollectionId.integerValue!=-1 && selectedCollectionId.integerValue!=-101)
    {
         [self savePhotosOnServer:userid filepath:imgData];
    }
    else
    {
        if(selectedCollectionId.integerValue==-101)
        {
            AddEditFolderViewController *addeditvc=[[AddEditFolderViewController alloc] init];
            addeditvc.isAddFolder=YES;
            addeditvc.isFromLaunchCamera=YES;
            [self.navigationController pushViewController:addeditvc animated:YES];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Folder Selected" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alert show];

        }
        
    }
    
}
/**
 *  Remove Picker View From View
 */
-(void)removePickerView
{
    [self goToHomePage];
}
-(void)categoryCancelButtonPressed{
    [self removePickerView];
}

/**
 *  Goto PhotoDetailViewController
 */

-(void)goToPhotoDetailViewController
{
    EditPhotoDetailViewController *editDetail;
    if([manager isiPad])
    {
        editDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController_iPad" bundle:[NSBundle mainBundle]];
    }
    else
    {
        editDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController" bundle:[NSBundle mainBundle]];
    }
    editDetail.isLaunchCamera=YES;
    [manager storeData:imgData :@"photo_data"];
    [self.navigationController pushViewController:editDetail animated:NO];
}

#pragma mark - UIPickerView Delegate and DataSource Methods

- (void)pickerViewTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer
{
    if([categoryPickerView selectedRowInComponent:0]==0)
    {
        AddEditFolderViewController *addeditvc=[[AddEditFolderViewController alloc] init];
        addeditvc.isAddFolder=YES;
        addeditvc.isFromLaunchCamera=YES;
         [self.navigationController pushViewController:addeditvc animated:YES];
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
 
    if(row==0)
    {
        selectedCollectionId=@-1;
        titleLabe.text=@"Select Folder";
        
    }
    else if (row==1)
    {
        // Open AddEditController to store pictures in folders
        selectedCollectionId=[collectionIdArray objectAtIndex:row];
        titleLabe.text=[collectionNameArray objectAtIndex:row];
        AddEditFolderViewController *addeditvc=[[AddEditFolderViewController alloc] init];
        addeditvc.isAddFolder=YES;
        addeditvc.isFromLaunchCamera=YES;
        [self.navigationController pushViewController:addeditvc animated:YES];
    }
    else
    {
        selectedCollectionId=[collectionIdArray objectAtIndex:row];
        titleLabe.text=[collectionNameArray objectAtIndex:row];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [collectionIdArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [collectionNameArray objectAtIndex: row];
    
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *text = [collectionNameArray objectAtIndex: row];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
    mutParaStyle.alignment = NSTextAlignmentCenter;
    [as addAttribute:NSParagraphStyleAttributeName value:mutParaStyle range:NSMakeRange(0,[text length])];
    return as;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 320;
    
    return sectionWidth;
}

/**
 *  Store Photo On Server
 */

-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imageData
{
    [SVProgressHUD showWithStatus:@"Photo is saving" maskType:SVProgressHUDMaskTypeBlack];
    isPhotoSavingMode=YES;
    webservices.delegate=self;
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitleStr,@"photo_description":photoDescriptionStr,@"photo_location":photoLocationStr,@"photo_tags":photoTagStr,@"photo_collections":selectedCollectionId};
    [webservices saveFileData:dic controller:@"photo" method:@"store" filePath:imageData] ;
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

/**
 *  Opens Home Page
 */
-(void)goToHomePage
{
    isCameraEditMode=NO;
    AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    [manager storeData:@"YES" :@"istabcamera"];
    delgate.navControllerhome.viewControllers=[NSArray arrayWithObjects:home, nil];
        [delgate.tbc setSelectedIndex:0];
}

/**
 *  Get User Location
 */

-(void)callGetLocation
{
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    [self getLocation];
}
-(void)getLocation
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocation Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    // Reverse Geocoding for current user address
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            NSString *location = [NSString stringWithFormat:@"%@,%@,%@",  placemark.locality,placemark.administrativeArea,                                  placemark.country];
            photoLocationStr=location;
            NSLog(@"Current location is %@",location);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    [locationManager stopUpdatingLocation];
}

@end
