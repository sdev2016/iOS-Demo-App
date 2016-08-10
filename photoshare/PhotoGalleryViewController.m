// 
// PhotoGalleryViewController.m
// photoshare
// 
// Created by ignis2 on 25/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "PhotoGalleryViewController.h"

#import "Base64.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "WebserviceController.h"
#import "SVProgressHUD.h"
#import "EditPhotoDetailViewController.h"
#import "PhotoViewController.h"
#import "PhotoShareController.h"

@interface PhotoGalleryViewController ()
{
    SVProgressHUD *pro;
    CGRect frame; // frame for button
    NSNumber *selectedPhotoId;
    
    UILabel *navsubTitle;
}
@end

@implementation PhotoGalleryViewController
@synthesize isPublicFolder,selectedFolderIndex,folderName;
@synthesize collectionId,collectionOwnerId,popover;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - View Controller Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Detect device and load nib
    
    if([[ContentManager sharedManager] isiPad])
    {
        [[NSBundle mainBundle] loadNibNamed:@"PhotoGalleryViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"PhotoGalleryViewController" owner:self options:nil];
    }
    
    // For multiple photos
    
    uploadMultiPlePhoto=[UploadMultiplePhotoOnServerViewController sharedMultipleUpload];
    uploadMultiPlePhoto.delegate=self;
    
    countRecievedPhoto=0;
    
    
    webServices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    
    searchController=[[SearchPhotoViewController alloc] init];
    
    // Set NO in NSUserDefaults for isEditPhoto key
    [manager storeData:@"NO" :@"isEditPhoto"];
    
    selectedImagesIndex=[[NSMutableArray alloc] init];
    photoArray=[[NSMutableArray alloc] init];
    photoIdsArray=[[NSMutableArray alloc] init];
    photoInfoArray = [[NSMutableArray alloc] init];
    
    // Set UI for IOS6
    
    [self setUIForIOS6];
    [self addCustomNavigationBar];
    
    // Set the Design of the button
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    float btnBorderWidth=2;
    float btnCornerRadius=8;
    addPhotoBtn.layer.cornerRadius=btnCornerRadius;
    addPhotoBtn.layer.borderWidth=btnBorderWidth;
    addPhotoBtn.layer.borderColor=btnBorderColor.CGColor;
    deletePhotoBtn.layer.cornerRadius=btnCornerRadius;
    deletePhotoBtn.layer.borderWidth=btnBorderWidth;
    deletePhotoBtn.layer.borderColor=btnBorderColor.CGColor;
    sharePhotoBtn.layer.cornerRadius=btnCornerRadius;
    sharePhotoBtn.layer.borderWidth=btnBorderWidth;
    sharePhotoBtn.layer.borderColor=btnBorderColor.CGColor;
    
    // Register cell for the CollectionView
    [collectionview registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CVCell"];
    
    // Adds the tap gesture & long gesture in CollectionView
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
    [collectionview addGestureRecognizer:tapGesture];
        longPressGesture.minimumPressDuration=0.6;
    [collectionview addGestureRecognizer:longPressGesture];
    
    // For Aviary photo editor
    
    ALAssetsLibrary * assetLibrary = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary];
    NSMutableArray * sessions = [NSMutableArray new];
    [self setSessions:sessions];
    [AFOpenGLManager beginOpenGLLoad];
    
    userid=[manager getData:@"user_id"];
    
    // Reset BOOL Value
    isPopFromPhotos=NO;
    isGetPhotoFromServer=NO;
    isGetPhotoIdFromServer=NO;
    isSaveDataOnServer=NO;
    [self getPhotoIdFromServer];
    
    [emptyMessageLbl setText:@"Click search for pictures using key words via Title & Description"];
    
    // Set add/delete photo buttons visibility
    
    if(![self.folderName isEqualToString:@"Public"] && ![self.folderName isEqualToString:@"public"])
    {
        emptyMessageLbl.hidden=YES;
        if(self.collectionOwnerId.integerValue==userid.integerValue)
        {
            addPhotoBtn.hidden=NO;
            deletePhotoBtn.hidden=NO;
        }
        else
        {
            deletePhotoBtn.hidden=YES;
            addPhotoBtn.hidden=YES;
            sharePhotoBtn.hidden=YES;
        }
    }
    
    emptyMessageLbl.hidden=YES;
    navsubTitle.hidden=YES;
    
    isCallMultiplePhoto=NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    
    // If returned from EditPhotoDetailViewController with edit photo
    
    if([[manager getData:@"isfromphotodetailcontroller"] isEqualToString:@"YES"])
    {
        @try {
            [self callGetLocation];
            photoTitleStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_title"];
            photoDescriptionStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_description"];
            photoTagStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_tags"];
            
            imageData=[manager getData:@"photo_data"];
            
            [self savePhotosOnServer:userid filepath:imageData];
            
            [manager removeData:@"isfromphotodetailcontroller,takephotodetail,photo_data"];
        }
        @catch (NSException *exception) {
            
        }
    }
    else
    {
        @try {
            isPopFromPhotos=NO;
            isGoToViewPhoto=NO;
            
            if([[manager getData:@"istabcamera"] isEqualToString:@"YES"])
            {
                [manager storeData:@"NO" :@"istabcamera"];
                [self.navigationController popViewControllerAnimated:NO];
            }
        
            // If returned from EditPhotoDetailViewController with edit only Photo Details
            if([[manager getData:@"isEditPhotoInViewPhoto"] isEqualToString:@"YES"])
            {
                NSData *photo=[manager getData:@"photo"];
                UIImage *image=[UIImage imageWithData:photo];
                [photoArray addObject:image];
                [photoIdsArray addObject:[manager getData:@"photoId"]];
                NSMutableArray *photoinfoarray=[NSKeyedUnarchiver unarchiveObjectWithData:[[manager getData:@"photoInfoArray"] mutableCopy]];
                photoInfoArray=photoinfoarray;
                [collectionview reloadData];
                [manager storeData:@"NO" :@"isEditPhotoInViewPhoto"];
                
                // Remove data from NSUserDefaults
                [manager removeData:@"photo,photoId,isEditPhotoInViewPhoto"];// photo info array is use later
                
                [self saveImageInDocumentDirectry:image index:photoArray.count-1];
            }
        }
        @catch (NSException *exception) {
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!isGoToViewPhoto&&!isCameraMode&&!isCameraEditMode&&!isMailSendMode)
    {
        isPopFromPhotos=YES;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUIForIOS6
{
    // Set for IOS6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        collectionview.frame=CGRectMake(collectionview.frame.origin.x, collectionview.frame.origin.y, collectionview.frame.size.width, collectionview.frame.size.height+50);
        addPhotoBtn.frame=CGRectMake(addPhotoBtn.frame.origin.x, addPhotoBtn.frame.origin.y+50, addPhotoBtn.frame.size.width, addPhotoBtn.frame.size.height);
        deletePhotoBtn.frame=CGRectMake(deletePhotoBtn.frame.origin.x, deletePhotoBtn.frame.origin.y+50, deletePhotoBtn.frame.size.width, deletePhotoBtn.frame.size.height);
        sharePhotoBtn.frame=CGRectMake(sharePhotoBtn.frame.origin.x, sharePhotoBtn.frame.origin.y+50, sharePhotoBtn.frame.size.width, sharePhotoBtn.frame.size.height);
    }
}

#pragma mark - UITextField Delegate Method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

/**
 *  Open Aviary editor
 */
-(void)openeditorcontrol
{
    [self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];
    
}

-(void)removeProgressBar
{
    [SVProgressHUD dismiss];
}
-(void)addProgressBar :(NSString *)message
{
    [SVProgressHUD showWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
}

/**
 *  Add Button Click
 */
-(IBAction)addPhoto:(id)sender
{
    if(photoArray.count==photoIdsArray.count)
    {
        [self resetButton];
        UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"From Camera",@"From Phone", nil];
        actionSheet.tag=10001;
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Photos are Loading" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
        [alert show];
    }
    
}

/**
 *  Delete Button Click
 */
-(IBAction)deletePhoto:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(photoArray.count==photoIdsArray.count)
    {
        if(btn.selected==NO)
        {
            [self resetButton];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:Nil message:@"Please select one or more photos" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alert show];
            deletePhotoBtn.backgroundColor=[UIColor blueColor];
            [deletePhotoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.selected=!btn.selected;
            isDeleteMode=YES;
        }
        else
        {
            [collectionview reloadData];
            // Sort the index array in descending order
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO] ;
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            sortedArray = [selectedImagesIndex sortedArrayUsingDescriptors:sortDescriptors];
            if(sortedArray.count>0)
            {
                deleteImageCount=0;
                @try {
                    
                    // Delete Photo From Server by Selected Photo Id
                    for(int i=0;i<sortedArray.count;i++)
                    {
                        [self deletePhotoFromServer:userid photoId:[photoIdsArray objectAtIndex:[[sortedArray objectAtIndex:i] integerValue]]];
                        [photoArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                        [photoIdsArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                        [photoInfoArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                    }
                    NSData *dat = [NSKeyedArchiver archivedDataWithRootObject:photoInfoArray];
                    [manager storeData:dat:@"photoInfoArray"];
                    
                    
                    [collectionview reloadData];
                    
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:[NSString stringWithFormat:@"%d Photo deleted",sortedArray.count] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                    [alert show];
                    
                    sortedArray=nil;
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                    
                }
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Photo Selected" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                [alert show];
            }
            [self resetButton];
        }
        
    }
    else
    {
        // Alert shows if images have loaded or not
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:(photoIdsArray.count>0?@"Photos are Loading":@"No Photo Available") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
        [alert show];
        
    }
    
}

/**
 *  Share button click
 */
-(IBAction)sharePhoto:(id)sender
{
    if(photoArray.count==photoIdsArray.count)
    {
        UIButton *btn=(UIButton *)sender;
        if(btn.selected==NO)
        {
             [self resetButton];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:Nil message:@"Please select one or more photos" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alert show];
            sharePhotoBtn.backgroundColor=[UIColor blueColor];
            [sharePhotoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            btn.selected=!btn.selected;
            
            isShareMode=YES;
        }
        else
        {
            [collectionview reloadData];
            
            // Sort the index array in descending order
            
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO] ;
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            shareSortedArray = [selectedImagesIndex sortedArrayUsingDescriptors:sortDescriptors];
            
            if(shareSortedArray.count > 0)
            {
                NSMutableArray *photoIdList = [[NSMutableArray alloc] init];
                [photoIdList removeAllObjects];
                for(int i=0;i<shareSortedArray.count;i++)
                {
                    [photoIdList addObject:[photoIdsArray objectAtIndex:[[shareSortedArray objectAtIndex:i] integerValue]]];
                }
                NSArray *userDetail = [[NSArray alloc] initWithObjects:userid,collectionId,@1, nil];
                
                // Detect device type and set nib for pushed controllers
                
                PhotoShareController *photoShare;
                if([manager isiPad])
                {
                    photoShare = [[PhotoShareController alloc] initWithNibName:@"PhotoShareController_iPad" bundle:nil];
                }
                else{
                    photoShare = [[PhotoShareController alloc] initWithNibName:@"PhotoShareController" bundle:nil];
                }
                photoShare.otherDetailArray = userDetail;
                photoShare.sharedImagesArray = photoIdList;
                
                [self.navigationController pushViewController:photoShare animated:YES];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Photo Selected" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                [alert show];
            }
            [self resetButton];
        }
    }
    else
    {
        // Alert shows if images have not loaded
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:(photoIdsArray.count>0?@"Photos are Loading":@"No Photo Available") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
        [alert show];
    }
}

#pragma mark - UIActionSheet delegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    photoLocationStr=@"";
    NSInteger tag=actionSheet.tag;
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.delegate=self;
    if(tag==10001)// Add Button Click
    {
        if(photoArray.count==photoIdsArray.count)
        {
            [self callGetLocation];
            
            isCameraMode=YES;
            if(buttonIndex==0)// Open Camera
            {
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
                    imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                    
                        [self presentViewController:imagePicker animated:YES completion:nil];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera is Not Available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
                    [alert show];
                }
            }
            else if(buttonIndex==1)// Open Photos From Device
            {
                UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Upload single photo",@"Upload multiple photos", nil];
                actionSheet.tag=10003;
                [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
                
            }
            else if(buttonIndex==2)// Cancel
            {
                NSLog(@"Cancel Button Click");
            }      
            
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Photo is Loading" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
    else if(tag==10002)// Edit Button Click
    {
        [self callGetLocation];
        if(buttonIndex==0)// Edit Photo
        {
            [self getImageFromServerForEdit:selectedEditImageIndex];
        }
        else if(buttonIndex==1)// Edit Detail
        {
            if(isPhotoOwner)
            {
                EditPhotoDetailViewController *editPhotoDetail;
                
                // Detect device and load nib for controller being pushed
                if([manager isiPad])
                {
                    editPhotoDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController_iPad" bundle:[NSBundle mainBundle]];
                }
                else
                {
                    editPhotoDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController" bundle:[NSBundle mainBundle]];
                }
                editPhotoDetail.photoId=[photoIdsArray objectAtIndex:selectedEditImageIndex];
                editPhotoDetail.collectionId=self.collectionId;
                editPhotoDetail.selectedIndex=selectedEditImageIndex;
                [self.navigationController pushViewController:editPhotoDetail animated:NO];
            }
        }
    }
    else if (tag==10003)// Add Photo Option
    {
        if(buttonIndex==0)// With Editor
        {
             imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
             if([manager isiPad])
             {
                 self.popover = [[UIPopoverController alloc]
                                 initWithContentViewController:imagePicker];
                 self.popover.delegate = self;
             
                 [self.popover presentPopoverFromRect:CGRectMake(self.view.center.x-100, self.view.center.y-100, 200, 200) inView:self.view permittedArrowDirections:0 animated:YES];
             }
             else
             {
                 [self presentViewController:imagePicker animated:YES completion:nil];
             }
        }
        else if (buttonIndex==1)// WithOutEditor
        {
            [self openCustomImagePicker];
        }
        else if (buttonIndex==2)
        {
            NSLog(@"Cancel Button Click");
        }
    }
}

#pragma mark - Device Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

/**
 *  Custom Image Picker For Pick The Multiple Photos
 */

-(void)openCustomImagePicker
{
    [self pickAssets:nil];

}

- (void)pickAssets:(id)sender
{
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelections = 10;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    
    // Only allow video clips if they are 5 Sec long
    
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(ALAsset* asset, NSDictionary *bindings) {
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 5;
        } else {
            return YES;
        }
    }];
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}


/**
 *  Multiple photo assets picker delegates
 */

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *arr=[NSMutableArray arrayWithArray:assets];
    
    [self saveMultiplePhotoOnServer:arr];
}

- (NSArray *)indexPathOfNewlyAddedAssets:(NSArray *)assets
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = self.assets.count; i < self.assets.count + assets.count ; i++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    
    return indexPaths;
}



/**
 *  Get Photos Ids From Server
 */

-(void)getPhotoIdFromServer
{
    [selectedImagesIndex removeAllObjects];
    [photoArray removeAllObjects];
    [photoIdsArray removeAllObjects];
    [photoInfoArray removeAllObjects];
    [collectionview reloadData];

    [self addProgressBar:@"Standby"];
    isGetPhotoIdFromServer=YES;
    
    webServices.delegate=self;
    
    NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
    
    [webServices call:dicData controller:@"collection" method:@"get"];
}

/**
 *  Get Photo From Server
 */


-(void)getPhotoFromServer :(int)photoIdIndex
{
    isGetPhotoFromServer=YES;
    NSDictionary *dicData;
    @try {
        if(photoIdsArray.count>0)
        {
            
            deleteImageCount=0;
            NSString *imageReSize;
            if([manager isiPad])
            {
                imageReSize=@"360";
            }
            else
            {
                imageReSize=@"180";
            }
            webServices.delegate=self;
            NSNumber *num = [NSNumber numberWithInt:1] ;
            selectedPhotoId = [photoIdsArray objectAtIndex:photoIdIndex];
            dicData = @{@"user_id":userid,@"photo_id":[photoIdsArray objectAtIndex:photoIdIndex],@"get_image":num,@"collection_id":self.collectionId,@"image_resize":imageReSize};
            
            [webServices call:dicData controller:@"photo" method:@"get"];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is found :%@",exception.description);
    }
}

/**
 *  Save Photo on Server
 */


-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)image
{
    isSaveDataOnServer=YES;
    
    [self addProgressBar:@"Photo is saving"];
    webServices=[[WebserviceController alloc] init];
    webServices.delegate=self;
    if(photoLocationStr==nil)
    {
        photoLocationStr=@"";
    }
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitleStr,@"photo_description":photoDescriptionStr,@"photo_location":photoLocationStr,@"photo_tags":photoTagStr,@"photo_collections":self.collectionId};
    
    [webServices saveFileData:dic controller:@"photo" method:@"store" filePath:image] ;
}

/**
 *  Save multiple photo on server
 */

-(void)saveMultiplePhotoOnServer:(NSMutableArray *)photoA
{
    isCallMultiplePhoto=YES;
    [uploadMultiPlePhoto uploadMultiplePhoto:photoA userId:userid collectionId:self.collectionId];
}


/**
 *  Response for multiple photo upload
 */

-(void)responseForMultiPleImageUpload:(UIImage *)img imgid:(NSNumber *)imgid colId:(NSNumber *)colId
{
    if(colId.integerValue==self.collectionId.integerValue)
    {
        if(isCallMultiplePhoto)
        {
            [self updatePhotoInCollectionViewData:imgid image:img cache:NO];
        }
        else
        {
            imgIdTemp=imgid;
            imgTemp=img;
            [self performSelector:@selector(updatePhoto) withObject:nil afterDelay:15.0f];
        }
    }
}

/**
 *  Update Photo in Collection view
 */
-(void)updatePhoto
{
    [self updatePhotoInCollectionViewData:imgIdTemp image:imgTemp cache:NO];
}
-(void)uploadStatus:(BOOL)status
{
    if(status)
    {
        // [self performSelector:@selector(getPhotoIdFromServer) withObject:self afterDelay:5.0];
    }
}

/**
 *  Delete Photo From Server
 */

-(void)deletePhotoFromServer :(NSNumber *)usrId photoId:(NSNumber *)photoId
{
    [self deletePhotoFromDocumentDirectory:photoId];
    
    isDeleteMode=YES;
     webServices.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid,@"photo_id":photoId};
    [webServices call:dicData controller:@"photo" method:@"delete"];
}

/**
 *  Get Photo From Server
 */
-(void)getImageFromServerForEdit :(int)selectedIndex
{
    isEditImageFromServer=YES;
    NSNumber *num = [NSNumber numberWithInt:1] ;
    webServices.delegate=self;
    
    NSString *imageReSize=@"320";
    if([manager isiPad])
    {
        imageReSize=@"768";
    }
    
    NSDictionary *dicData = @{@"user_id":userid,@"photo_id":[photoIdsArray objectAtIndex:selectedIndex],@"get_image":num,@"image_resize":imageReSize,@"collection_id":self.collectionId};
    
    [self addProgressBar:@"Photo is Loading"];
    [webServices call:dicData controller:@"photo" method:@"get"];
}

#pragma mark - WebService Delegate Methods

-(void) webserviceCallbackImage:(UIImage *)image
{
    // Preparing image from server for editing
    [self removeProgressBar];
    @try {
        if(isEditImageFromServer)
        {
            [self launchPhotoEditorWithImage:image highResolutionImage:image];
            isEditImageFromServer=NO;
        }
        else if(isGetPhotoFromServer)
        {
            countRecievedPhoto++;
            if(image==NULL)
            {
                image=[UIImage imageNamed:@"error.png"];
            }
            [self saveImageInDocumentDirectry:image index:photoArray.count];
            [photoArray addObject:image];
                
            int count=photoArray.count;
            NSLog(@"Photo Array Count is : %d",count);
            UIImageView *imgView=(UIImageView *)[collectionview viewWithTag:100+count];
            UIActivityIndicatorView *indicator=(UIActivityIndicatorView *)[collectionview viewWithTag:1100+count];
            [indicator removeFromSuperview];
            imgView.image=image;
            
            if(photoArray.count<photoIdsArray.count)
            {
                if(!isPopFromPhotos)
                {
                    [self getPhotoFromServer:countRecievedPhoto];
                }
            }
            else
            {
                isGetPhotoFromServer=NO;
                countRecievedPhoto=0;
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}

-(void)webserviceCallback:(NSDictionary *)data
{
    // Checks if photos edited are saved on the server
    
    NSDictionary *outputData=[data objectForKey:@"output_data"];
    
    int exitcode=[[data objectForKey:@"exit_code"] integerValue];
    
    if(isSaveDataOnServer)
    {
        [self removeProgressBar];
        if(exitcode==1)
        {
            [self updatePhotoInCollectionViewData:[outputData objectForKey:@"image_id"]image:editedImage cache:YES];
        }
        else
        {
            NSLog(@"Photo saving failed");
            NSString *errorMessage=[data objectForKey:@"user_message"];
            if(errorMessage.length==0 ||& errorMessage==NULL)
            {
                errorMessage=@"Photo Saving Failed";
            }
            [manager showAlert:@"Error !" msg:errorMessage cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        isSaveDataOnServer=NO;
    }
    else if(isGetPhotoIdFromServer)
    {
        [self removeProgressBar];
        if(exitcode==1)
        {
            isGetPhotoIdFromServer=NO;
            
            NSDictionary *collectionContent=[outputData objectForKey:@"collection_contents"];
            // Set the collection details
            NSString *writeUserIdStr=[[outputData objectForKey:@"collection_write_user_ids"] componentsJoinedByString:@","];
            NSString *readUserIdStr=[[outputData objectForKey:@"collection_read_user_ids"] componentsJoinedByString:@","];
            // Stores in NSUserDefaults
            NSArray *writePer=[outputData objectForKey:@"collection_write_user_ids"];
            NSArray *readPer=[outputData objectForKey:@"collection_read_user_ids"];
            isWritePermission=[writePer containsObject:userid];
            isReadPermission=[readPer containsObject:userid];
            if(isWritePermission)
            {
                addPhotoBtn.hidden=NO;
                sharePhotoBtn.hidden=NO;
            }
            [manager storeData:writeUserIdStr :@"writeUserId"];
            [manager storeData:readUserIdStr :@"readUserId"];
            
            if(collectionContent.count>0)
            {
                emptyMessageLbl.hidden=YES;
                
                // Sets the photo id
                
                [photoIdsArray addObjectsFromArray:[collectionContent allKeys]];
                [photoInfoArray addObjectsFromArray:[collectionContent allValues]];
                
                // Stores photo info array in NSUserDefaults
                
                NSData *dat = [NSKeyedArchiver archivedDataWithRootObject:photoInfoArray];
                [manager storeData:dat:@"photoInfoArray"];
                
                [collectionview reloadData];
                NSString *checkNotFirstTime=[manager getData:[NSString stringWithFormat:@"isNotFirstTimeIn%@",folderName]];
                if([checkNotFirstTime isEqualToString:@"YES"])
                {
                    for (int i=0; i<photoIdsArray.count; i++) {
                        if([self getImageFromDocumentDirectory:i]!=(id)nil)
                        {
                            [photoArray addObject:[self getImageFromDocumentDirectory:i]];
                        }
                        else
                        {
                            [self getPhotoFromServer:i];
                            break;
                        }
                    }
                    
                }
                else
                {
                    [self getPhotoFromServer:0];
                    [manager storeData:@"YES" :[NSString stringWithFormat:@"isNotFirstTimeIn%@",folderName]];
                }
            }
            else
            {
                NSData *dat = [NSKeyedArchiver archivedDataWithRootObject:photoInfoArray];
                [manager storeData:dat:@"photoInfoArray"];
                if(self.isPublicFolder)
                {
                    emptyMessageLbl.hidden=NO;
                }
                
                 [collectionview reloadData];
                [SVProgressHUD showSuccessWithStatus:@"No Photos Available"];
            }
            
        }
        
    }
}

/**
 *  Update Collection View Data
 */

-(void)updatePhotoInCollectionViewData:(NSNumber *)photoId image:(UIImage *)image cache:(BOOL)saveinCache
{
    @try {
        // For Photo Detail
        if(photoDescriptionStr.length==0)
            photoDescriptionStr=@"";
        if(photoLocationStr.length==0)
            photoLocationStr=@"";
        if(photoTitleStr.length==0)
            photoTitleStr=@"Untitled";
        
        [photoArray addObject:image];
        [photoIdsArray addObject:photoId];
        
        
        // Save image in document directory
        NSData *dta = UIImageJPEGRepresentation(image, 0.1);
        UIImage *newImage = [UIImage imageWithData:dta];
        if(saveinCache)
        {
            [self saveImageInDocumentDirectry:newImage index:photoIdsArray.count-1];
        }
        // Update the photo info in NSUserDefaults
        NSMutableArray *photoinfoarray=[NSKeyedUnarchiver unarchiveObjectWithData:[[manager getData:@"photoInfoArray"] mutableCopy]];
        
        size_t imageSize = CGImageGetBytesPerRow(pickImage.CGImage) * CGImageGetHeight(pickImage.CGImage);
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"collection_photo_added_date"];
        [dic setObject:photoDescriptionStr forKey:@"collection_photo_description"];
        [dic setObject:photoTitleStr forKey:@"collection_photo_title"];
        [dic setObject:photoId forKey:@"collection_photo_id"];
        [dic setObject:[NSString stringWithFormat:@"%zu",imageSize] forKey:@"collection_photo_filesize"];
        [dic setObject:userid forKey:@"collection_photo_user_id"];
        
        // Update photo info array in NSUserDefaults
        
        [photoinfoarray addObject:dic];
        
        NSData *data=[NSKeyedArchiver archivedDataWithRootObject:photoinfoarray];
        [manager storeData:data :@"photoInfoArray"];
        
        [photoInfoArray addObject:dic];
        if(self.isPublicFolder)
        {
            // Public img count for home page
            NSNumber *imgCout=[NSNumber numberWithInteger:photoArray.count];
            [manager storeData:imgCout :@"publicImgIdArray"];
        }
       
    }
    @catch (NSException *exception) {
            }
   [collectionview reloadData];
}

/**
 *  Save Image In Document Directory
 */

-(void)saveImageInDocumentDirectry:(UIImage *)img index:(NSInteger)index
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Create Folder
    
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/123FridayImages"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if(self.isPublicFolder)
    {
        dataPath = [dataPath stringByAppendingPathComponent:@"/PublicFolder"];
    }
    else
    {
        dataPath = [dataPath stringByAppendingPathComponent:@"/YourFolder"];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if(!self.isPublicFolder)
    {
        dataPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",folderName]];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Photo_%@.png",userid,[photoIdsArray objectAtIndex:index]]];
    UIImage *image = img;
    NSData *imgData = UIImagePNGRepresentation(image);
    [imgData writeToFile:savedImagePath atomically:NO];
    
}

/**
 *  Get Image From Document Directory
 */
-(UIImage *)getImageFromDocumentDirectory :(NSInteger)index
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath;
    if(self.isPublicFolder)
    {
        getImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/123FridayImages/PublicFolder/%@_Photo_%@.png",userid,[photoIdsArray objectAtIndex:index]]];
    }
    else
    {
        getImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/123FridayImages/YourFolder/%@/%@_Photo_%@.png",folderName,userid,[photoIdsArray objectAtIndex:index]]];
    }
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    return img;
   
}

/**
 *  Delete Photo From Document Directory
 */
-(void)deletePhotoFromDocumentDirectory:(NSNumber *)photoId
{
    // Get documents from directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSString *smallImagePath;
    NSString *largeImagePath;
    if(self.isPublicFolder)
    {
        smallImagePath=[NSString stringWithFormat:@"/123FridayImages/PublicFolder/%@_Photo_%@.png",userid,photoId];
        largeImagePath=[NSString stringWithFormat:@"/123FridayImages/PublicFolder/%@_LargePhoto_%@.png",userid,photoId];
    }
    else
    {
        smallImagePath=[NSString stringWithFormat:@"/123FridayImages/YourFolder/%@/%@_Photo_%@.png",self.folderName,userid,photoId];
        largeImagePath=[NSString stringWithFormat:@"/123FridayImages/YourFolder/%@/%@_LargePhoto_%@.png",self.folderName,userid,photoId];
    }
    
    // Delete file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager removeItemAtPath:[documentsDirectoryPath stringByAppendingPathComponent:smallImagePath] error:nil])
    {
        
    }
    if([fileManager removeItemAtPath:[documentsDirectoryPath stringByAppendingPathComponent:largeImagePath] error:nil])
    {
        
    }
}

/**
 *  Reset Button
 */
-(void)resetButton
{
    for (int i=0; i<photoArray.count; i++) {
        UIImageView *chechBoxImf=(UIImageView *)[collectionview viewWithTag:1001];
        [chechBoxImf removeFromSuperview];
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
        cell.selected=NO;
    }
    if(collectionOwnerId.integerValue==userid.integerValue)
    {addPhotoBtn.hidden=NO;deletePhotoBtn.hidden=NO;sharePhotoBtn.hidden=NO;}
    else
    {
        if(isWritePermission)
        {addPhotoBtn.hidden=NO;deletePhotoBtn.hidden=YES;sharePhotoBtn.hidden=NO;}
        else
        {addPhotoBtn.hidden=YES;deletePhotoBtn.hidden=YES;sharePhotoBtn.hidden=YES;}
    }
    
    isDeleteMode=NO;isShareMode=NO;deletePhotoBtn.selected=NO;sharePhotoBtn.selected=NO;
    deletePhotoBtn.backgroundColor=[UIColor whiteColor];
    [deletePhotoBtn setTitleColor:BTN_FONT_COLOR forState:UIControlStateNormal];
    sharePhotoBtn.backgroundColor=[UIColor whiteColor];
    [sharePhotoBtn setTitleColor:BTN_FONT_COLOR forState:UIControlStateNormal];
    
    [selectedImagesIndex removeAllObjects];
}
/**
 *  Taphandle Method for Collection view
 */

-(void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil)
    {
        
        UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
        NSLog(@"cell selected %hhd",cell.selected);
        if(isDeleteMode)
        {
            if(cell.selected==NO)
            {
                if(photoArray.count>indexPath.row)
                {
                    selectedEditImageIndex=indexPath.row;
                    NSNumber *photoUserId=[[photoInfoArray objectAtIndex:selectedEditImageIndex] objectForKey:@"collection_photo_user_id"];
                    if(photoUserId.integerValue==userid.integerValue)
                    {
                        UIImageView *checkBoxImg=[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width-25,15, 20, 20)];
                        checkBoxImg.layer.masksToBounds=YES;
                        checkBoxImg.image=[UIImage imageNamed:@"tick_circle.png"];
                        checkBoxImg.tag=1001;
                        [cell.contentView addSubview:checkBoxImg];
                        
                        [selectedImagesIndex addObject:[NSNumber numberWithInteger:[indexPath row]]];
                    }
                    else
                    {
                        [manager showAlert:@"Warning" msg:@"You are not the owner of this Photo" cancelBtnTitle:@"Ok" otherBtn:Nil];
                    }
                    
                }
                else
                {
                    [manager showAlert:@"Warning" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:Nil];
                }
                
            }
            else
            {
                UIImageView *checkBox=(UIImageView *)[cell viewWithTag:1001];
                [checkBox removeFromSuperview];
                [selectedImagesIndex removeObject:[NSNumber numberWithInteger:[indexPath row]]];
            }
        }
        else if(isShareMode)
        {
            if(cell.selected==NO)
            {
                if(photoArray.count>indexPath.row)
                {
                    UIImageView *checkBoxImg=[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width-25,15, 20, 20)];
                    checkBoxImg.layer.masksToBounds=YES;
                    checkBoxImg.image=[UIImage imageNamed:@"tick_circle.png"];
                    checkBoxImg.tag=1001;
                    [cell.contentView addSubview:checkBoxImg];
                    
                    [selectedImagesIndex addObject:[NSNumber numberWithInteger:[indexPath row]]];
                }
                else
                {
                    [manager showAlert:@"Warning" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:Nil];
                }
                
            }
            else
            {
                UIImageView *checkBox=(UIImageView *)[cell viewWithTag:1001];
                [checkBox removeFromSuperview];
                [selectedImagesIndex removeObject:[NSNumber numberWithInteger:[indexPath row]]];
            }
        }
        else
        {
            if(photoArray.count>indexPath.row)
            {
                selectedEditImageIndex=indexPath.row;
                [self viewPhoto:indexPath];
            }
            else
            {
                [manager showAlert:@"Warning" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:Nil];
            }

        }
        cell.selected=!cell.selected;
    }
    else
    {
        [self resetButton];
    }
}

/**
 *  Long Press Method For UICollectionView
 */

-(void)longPressHandle:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    
    CGRect frameForMenuController;
    if([manager isiPad])
    {
        frameForMenuController=CGRectMake(50,40, 50, 50);
    }
    else
    {
        frameForMenuController=CGRectMake(25,40, 50, 50);
    }
    if(!isDeleteMode && !isShareMode)
    {
        if (indexPath != nil){
            
            selectedEditImageIndex=indexPath.row;
            NSNumber *photoUserId=[[photoInfoArray objectAtIndex:selectedEditImageIndex] objectForKey:@"collection_photo_user_id"];
            
            UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
            if(collectionOwnerId.integerValue==userid.integerValue)
            {
                UIMenuController *menu = [UIMenuController sharedMenuController];
                UIMenuItem *editPhoto = [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(editImage:)];
                
                [menu setMenuItems:[NSArray arrayWithObjects:editPhoto,nil]];
                [menu setTargetRect:frameForMenuController inView:cell];
                [menu setMenuVisible:YES animated:YES];
                NSLog(@"Edit Photo");
            }
            else
            {
                if(isWritePermission)
                {
                    if(photoUserId.integerValue==userid.integerValue)
                    {
                        isPhotoOwner=YES;
                        UIMenuItem *edit = [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(edit:)];
                        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteSelectedPhoto:)];
                        UIMenuController *menu = [UIMenuController sharedMenuController];
                        [menu setMenuItems:[NSArray arrayWithObjects:edit,delete, nil]];
                        [menu setTargetRect:frameForMenuController inView:cell];
                        [menu setMenuVisible:YES animated:YES];
                    }
                    else
                    {
                        isPhotoOwner=NO;
                        UIMenuItem *edit = [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(edit:)];
                        UIMenuItem *reportAbuse = [[UIMenuItem alloc] initWithTitle:@"Report Abuse" action:@selector(reportAbuse:)];
                        
                        UIMenuController *menu = [UIMenuController sharedMenuController];
                        
                        [menu setMenuItems:[NSArray arrayWithObjects:edit, reportAbuse,nil]];
                        [menu setTargetRect:frameForMenuController inView:cell];
                        [menu setMenuVisible:YES animated:YES];
                    }
                    
                    NSLog(@"Write Permission");
                }
                else if (isReadPermission)
                {
                    UIMenuItem *reportAbuse = [[UIMenuItem alloc] initWithTitle:@"Report Abuse" action:@selector(reportAbuse:)];
                    
                    UIMenuController *menu = [UIMenuController sharedMenuController];
                    [menu setMenuItems:[NSArray arrayWithObjects:reportAbuse,nil]];
                    [menu setTargetRect:frameForMenuController inView:cell];
                    [menu setMenuVisible:YES animated:YES];
                    NSLog(@"Read Permission");
                }
            }
        }
    }
}

/**
 *  For UIMenuController
 */
- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if(isWritePermission)
    {
        NSNumber *photoUserId=[[photoInfoArray objectAtIndex:selectedEditImageIndex] objectForKey:@"collection_photo_user_id"];
        if (action == @selector(edit:))
        return YES;
        if(photoUserId.integerValue==userid.integerValue)
        {
            if (action == @selector(deleteSelectedPhoto:))
            return YES;
        }
        else
        {
            if (action == @selector(reportAbuse:))
            return YES;
        }
    }
    else if (isReadPermission)
    {
        if (action == @selector(reportAbuse:))
        return YES;
    }
    else
    {
        if (action == @selector(editImage:))
        return YES;
        if (action == @selector(reportAbuse:))
            return YES;
    }
    return NO;
   
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

/**
 *  Menu Controller Edit button click
 */
- (void)edit:(id)sender {
    photoLocationStr=@"";
    [self callGetLocation];
    NSNumber *photoUserId=[[photoInfoArray objectAtIndex:selectedEditImageIndex] objectForKey:@"collection_photo_user_id"];
    
    if(photoUserId.integerValue==userid.integerValue)
    {
        UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Edit Photo",@"Edit Properties", nil];
        actionSheet.tag=10002;
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    else
    {
        [self getImageFromServerForEdit:selectedEditImageIndex];
    }
   	NSLog(@"Photo Edit");
}


/**
 *  Menu Controller ReportAbuse button click
 */

- (void)reportAbuse:(id)sender {
    
    isMailSendMode=YES;// for photo loading
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObject:@"reportabuse@123friday.com"]];
    [controller setSubject:@"Report Abuse"];
    
    NSString *body=[NSString stringWithFormat:@"Collection Owner Id :%@\nCollection Name:%@\nCollection Id:%@\nPhoto Id:%@",self.collectionOwnerId,self.folderName,self.collectionId,[photoIdsArray objectAtIndex:selectedEditImageIndex]];
    
    [controller setMessageBody:body isHTML:NO];
    
    if (controller)
    {
        [self presentViewController:controller animated:YES completion:nil];
    }
	NSLog(@"Cell was approved");
}

/**
 *  Menu Controller Delete button click
 */

-(void)deleteSelectedPhoto:(id)sender
{
    [self deletePhotoFromServer:userid photoId:[photoIdsArray objectAtIndex:selectedEditImageIndex]];
    [photoArray removeObjectAtIndex:selectedEditImageIndex];
    [photoIdsArray removeObjectAtIndex:selectedEditImageIndex];
    [photoInfoArray removeObjectAtIndex:selectedEditImageIndex];
    [collectionview reloadData];
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Photo Deleted" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
    [alert show];
}

#pragma mark - MFMailComposeViewController delegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    isMailSendMode=NO;
    
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
        [manager showAlert:@"Message" msg:@"Mail Successfully sent" cancelBtnTitle:@"Ok" otherBtn:Nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  Open photo view controller
 */

-(void)viewPhoto :(NSIndexPath *)indexPath
{
    @try {
        PhotoViewController *viewPhoto=[[PhotoViewController alloc] init];
        
        NSNumber *photoUserId=[[photoInfoArray objectAtIndex:selectedEditImageIndex] objectForKey:@"collection_photo_user_id"];
        if(!isWritePermission && isReadPermission)
        {
            viewPhoto.isOnlyReadPermission=YES;
        }
        else
        {
            viewPhoto.isOnlyReadPermission=NO;
        }
        viewPhoto.photoOwnerId=photoUserId;
        viewPhoto.photoId=[photoIdsArray objectAtIndex:indexPath.row];
        viewPhoto.smallImage=[photoArray objectAtIndex:indexPath.row];
        viewPhoto.isViewPhoto=YES;
        viewPhoto.collectionId=self.collectionId;
        viewPhoto.collectionOwnerId=self.collectionOwnerId;
        viewPhoto.selectedIndex=indexPath.row;
        viewPhoto.isPublicFolder=self.isPublicFolder;
       
        isGoToViewPhoto=YES;
        if(self.isPublicFolder)
        {
            viewPhoto.folderName=@"Public";
        }
        else
        {
            viewPhoto.folderName=self.folderName;
        }
        
        [self.navigationController pushViewController:viewPhoto animated:YES];

    }
    @catch (NSException *exception) {
        NSLog(@"Exception in View Photo :%@",exception.description);
    }
}

/**
 *  Open edit options
 */

-(void)editImage:(id)sender
{
    @try {
        NSNumber *photoUserId=[[photoInfoArray objectAtIndex:selectedEditImageIndex] objectForKey:@"collection_photo_user_id"];
        if(photoUserId.integerValue==userid.integerValue)
        {
            isPhotoOwner=YES;
            UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Edit Photo",@"Edit Properties", nil];
            actionSheet.tag=10002;
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
        else
        {
            isPhotoOwner=NO;
            UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Edit Photo", nil];
            actionSheet.tag=10002;
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
}

/**
 *  Open EditPhotoDetailViewController
 */

-(void)goToPhotoDetailViewControler
{
    EditPhotoDetailViewController *editDetail;
    
    // Sets view according to the device
    
    if([manager isiPad])
    {
        editDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController_iPad" bundle:[NSBundle mainBundle]];
    }
    else
    {
        editDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController" bundle:[NSBundle mainBundle]];
    }
    editDetail.isPhotoAdd=YES;
    
    [manager storeData:imageData :@"photo_data"];
    
    [self.navigationController pushViewController:editDetail animated:NO];
}

#pragma mark - UIImagePickerController Delegate Methods

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if([manager isiPad])
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if([manager isiPad])
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    // Sets the asset url in String
    assetUrlOfImage=[NSString stringWithFormat:@"%@",assetURL];
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    @try {
        if(picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        {
            image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
        }
    }
    @catch (NSException *exception) {
        
    }
    if(isCameraMode)
    {
        isCameraEditMode=YES;
        isCameraMode=NO;
        pickImage=image;
        [self dismissViewControllerAnimated:NO completion:Nil];
        if (isCameraEditMode) {
            isCameraEditMode = false ;
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(openeditorcontrol) userInfo:nil repeats:NO];
        }
    }
    else
    {
        void(^completion)(void)  = ^(void){
            
            [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if (asset){
                    [self launchEditorWithAsset:asset];
                }
            } failureBlock:^(NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        };
            [self dismissViewControllerAnimated:NO completion:completion];
    }
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
}


/**
 *  Open SearchView
 */
-(void)searchViewOpen
{
    searchController=nil;
    searchController=[[SearchPhotoViewController alloc] init];
    searchController.searchType=@"public";
    [self.navigationController pushViewController:searchController animated:NO];
}

#pragma mark - UICollectionView delegate Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.isPublicFolder && !isGetPhotoIdFromServer)
    {
        if(photoIdsArray.count>0)
        {
            emptyMessageLbl.hidden=YES;
            navsubTitle.hidden=NO;
        }
        else
        {
            emptyMessageLbl.hidden=NO;
            navsubTitle.hidden=YES;
        }
    }
    return [photoIdsArray count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    for (UIView *vi in [[cell contentView] subviews]) {
        [vi removeFromSuperview];
    }
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    imgView.tag=101+indexPath.row;
    imgView.contentMode=UIViewContentModeScaleAspectFill;
    imgView.layer.masksToBounds=YES;
    
    @try {
        
        if(photoArray.count>indexPath.row)
        {
            UIImage *image=[photoArray objectAtIndex:indexPath.row];
            imgView.image=image;
       
            [cell.contentView addSubview:imgView];
            
            if([selectedImagesIndex containsObject:[NSNumber numberWithInteger:[indexPath row]]])
            {
                UIImageView *checkBoxImg=[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width-25,15, 20, 20)];
                checkBoxImg.layer.masksToBounds=YES;
                checkBoxImg.image=[UIImage imageNamed:@"tick_circle.png"];
                checkBoxImg.tag=1001;
                [cell.contentView addSubview:checkBoxImg];
            }
        }
        else
        {
            UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityIndicator startAnimating];
            activityIndicator.tag=1101+indexPath.row;
            activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |                                        UIViewAutoresizingFlexibleRightMargin |                                        UIViewAutoresizingFlexibleTopMargin |                                        UIViewAutoresizingFlexibleBottomMargin);
            activityIndicator.center = CGPointMake(CGRectGetWidth(cell.bounds)/2, CGRectGetHeight(cell.bounds)/2);
            [cell.contentView addSubview:activityIndicator];
            [cell.contentView addSubview:imgView];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception Name : %@",exception.name);
        NSLog(@"Exception Description : %@",exception.description);
    }
    return cell;
}



#pragma mark - Aviary Editor Methods

- (void) launchEditorWithAsset:(ALAsset *)asset
{
    UIImage * editingResImage = [self editingResImageForAsset:asset];
    UIImage * highResImage = [self highResImageForAsset:asset];
    
    [self launchPhotoEditorWithImage:editingResImage highResolutionImage:highResImage];
}


/**
 *  Photo editor creation and presentation
 */

- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [SVProgressHUD dismiss];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Init photo editor and set delegate
    
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    photoEditor.view.frame=CGRectMake(0, 100, 320, 300);
    [photoEditor setDelegate:self];
    
    // On high res image, create high res context for image & photo editor
    if (highResImage) {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    }
    
    // Presents photo editor
    [self presentViewController:photoEditor animated:NO completion:nil];
}

- (void) setupHighResContextForPhotoEditor:(AFPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage
{
    // Capture editor session reference for further usage
    __block AFPhotoEditorSession *session = [photoEditor session];
    
    // Add sessions in session array
    [[self sessions] addObject:session];
    
    // Create context from session for high res image
    AFPhotoEditorContext *context = [session createContextWithImage:highResImage];
    
    __block PhotoGalleryViewController * blockSelf = self;
    
    [context render:^(UIImage *result) {
        if (result) {
            // UIImageWriteToSavedPhotosAlbum(result, nil, nil, NULL);
        }
        
        [[blockSelf sessions] removeObject:session];
        
        blockSelf = nil;
        session = nil;
        
    }];
}

#pragma Photo Editor Delegate Methods

/**
 *  This method is called when user taps "DONE" in photo editor
 */
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
   
    imageData = UIImagePNGRepresentation(image);
    editedImage=image;
   
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissModals];
  
    [self goToPhotoDetailViewControler];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}
/**
 *  This method is called when user taps "CANCEL" in photo editor
 */
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissModals];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

/**
 *  Photo editor customization
 */

- (void) setPhotoEditorCustomizationOptions
{
    // Set tool order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set custom crop sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    // Set supported orientation
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
    UIImageOrientation orientations = (UIImageOrientation)[representation orientation];
    CGFloat scale = [representation scale];
    
    return [UIImage imageWithCGImage:image scale:scale orientation:orientations];
}

-(void)dismissModals
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

/**
 *  Get location methods
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
#pragma mark - CLLocationManager delegate Methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    // Reverse geocoding to get location
    
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


#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    UIButton *button =[navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    UIButton *searchBtn=[navnBar navBarRightButton:@"Search"];
    [searchBtn addTarget:self action:@selector(searchViewOpen) forControlEvents:UIControlEventTouchUpInside];
    
    
    if(self.isPublicFolder==YES)
    {
        CGFloat titleY;
        CGFloat subtitleY;
        CGFloat subtitleWidth;
        CGFloat subFont;
        if([manager isiPad])
        {
            titleY=20;
            subtitleY=30;
            subFont=16;
            subtitleWidth=100;
        }
        else
        {
            titleY=8;
            subtitleY=16;
            subFont=7.8;
            subtitleWidth=80;
        }
        UILabel *navTitle = [navnBar navBarTitleLabel:@"123 Public"];
        navTitle.backgroundColor=[UIColor clearColor];
        
        CGRect navframe=navTitle.frame;
        navframe.origin.y=navframe.origin.y-titleY;
        navTitle.frame=navframe;
        
        CGRect backFrame=button.frame;
        backFrame.origin.y=backFrame.origin.y-titleY;
        button.frame=backFrame;
        
        CGRect searchFrame=searchBtn.frame;
        searchFrame.origin.y=searchFrame.origin.y-titleY;
        searchBtn.frame=searchFrame;
        
        
        navsubTitle = [navnBar navBarTitleLabel:@"(Click search for pictures using key words via Title & Description)"];
        navsubTitle.backgroundColor=[UIColor clearColor];
        navframe.origin.y=navframe.origin.y+subtitleY;
        navframe.origin.x=navframe.origin.x-(subtitleWidth/2);
        navframe.size.width=navframe.size.width+subtitleWidth;
        navsubTitle.frame=navframe;
        navsubTitle.font=[UIFont systemFontOfSize:subFont];
        
        
        [navnBar addSubview:navTitle];
        [navnBar addSubview:navsubTitle];
        [navnBar addSubview:searchBtn];
        
    }
    else
    {
        UILabel *foldernamelabel=[[UILabel alloc] init];
        if([manager isiPad])
        {
            foldernamelabel.frame=CGRectMake(self.view.frame.size.width-310, NavBtnYPosForiPad, 300.0, NavBtnHeightForiPad);
            foldernamelabel.font=[UIFont fontWithName:@"Verdana" size:23.0f];
        }
        else
        {
            foldernamelabel.frame=CGRectMake(90.0, NavBtnYPosForiPhone, 220.0, NavBtnHeightForiPhone);
            foldernamelabel.font=[UIFont fontWithName:@"Verdana" size:17.0f];
        }
        foldernamelabel.text=self.folderName;
        
        foldernamelabel.textAlignment=NSTextAlignmentRight;
        foldernamelabel.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
        [navnBar addSubview:foldernamelabel];
    }
    
    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
}

-(void)navBackButtonClick{
    
   if(![[self navigationController] popViewControllerAnimated:YES])
   {
       [self.tabBarController setSelectedIndex:3];
       [[self navigationController] popViewControllerAnimated:YES];
   }
}

@end
