// 
// EditPhotoDetailViewController.m
// photoshare
// 
// Created by ignis2 on 06/02/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "EditPhotoDetailViewController.h"
#import "NavigationBar.h"
#import "LaunchCameraViewController.h"
#import "AppDelegate.h"
@interface EditPhotoDetailViewController ()

@end

@implementation EditPhotoDetailViewController
@synthesize photoId,collectionId,selectedIndex,isPhotoAdd,isLaunchCamera;

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
        [[NSBundle mainBundle] loadNibNamed:@"EditPhotoDetailViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"EditPhotoDetailViewController" owner:self options:nil];
    }
    
    manager=[ContentManager sharedManager];

    home=[[HomeViewController alloc] init];
    userid =[manager getData:@"user_id"];
    
    [self addCustomNavigationBar];

    [photoTitletxt setDelegate:self];
    [photoDescriptionTxt setDelegate:self];
    [photoTag setDelegate:self];
    [photoTitletxt setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    photoDescriptionTxt.layer.borderWidth=0.3;
    if([manager isiPad])
    {
        photoDescriptionTxt.layer.borderWidth=0.8;
    }
    [self setUIForIOS6];
    photoDescriptionTxt.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    // Set controllers and view
    
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    saveButton.layer.cornerRadius=4;
    saveButton.layer.borderColor=btnBorderColor.CGColor;
    saveButton.layer.borderWidth=1;
    cancelButton.layer.cornerRadius=4;
    cancelButton.layer.borderColor=btnBorderColor.CGColor;
    cancelButton.layer.borderWidth=1;
    cancelButton.hidden=YES;
    if(!self.isPhotoAdd && !self.isLaunchCamera)
    {
        @try {
            NSArray *photoDetail=[NSKeyedUnarchiver unarchiveObjectWithData:[manager getData:@"photoInfoArray"]];
            photoTitletxt.text=[[photoDetail  objectAtIndex:self.selectedIndex] objectForKey:@"collection_photo_title"];
            photoDescriptionTxt.text=[[photoDetail  objectAtIndex:self.selectedIndex] objectForKey:@"collection_photo_description"];
        }
        @catch (NSException *exception) {
            
        }
    }
    if(isLaunchCamera || isPhotoAdd)
    {
        cancelButton.hidden=NO;
    }
    
    photoDescriptionTxt.delegate = self;
    if(photoDescriptionTxt.text.length == 0)
    {
        photoDescriptionTxt.text = @"Now describe your picture \ne.g. what is it a picture of? Who is in the picture?";
        photoDescriptionTxt.textColor = [UIColor darkGrayColor];
    }
    
   
    // Added TapGesture to dismiss keyboard
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self checkOrientation];
    
    photoLocationString=@"";
     [navnBar setTheTotalEarning:manager.weeklyearningStr];
    [self callGetLocation];
    
}

/**
 *  For IOS 6
 */
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        photoDescriptionTxt.layer.borderWidth=1;
    }
}

/**
 *  Tap Gesture Method
 */
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [self.view endEditing:YES];
}

#pragma mark - Device Orientation Methods

-(void)checkOrientation
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,270);
            scrollView.scrollEnabled=NO;
            
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,270);
            scrollView.scrollEnabled=NO;
        }
    }
    else {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,240);
            scrollView.scrollEnabled=YES;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,240);
            scrollView.scrollEnabled=YES;
        }
        else if ([manager isiPad])
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,500);
            scrollView.scrollEnabled=YES;
        }
    }
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self checkOrientation];
}

/**
 *  Save Photo Details On Server
 */

-(void)savePhotoDetailOnServer
{
    NSString *photodes;
    NSString *photoTitle;
    NSString *photoTagstr;;
    @try {
        photodes=photoDescriptionTxt.text;
        
        photoTitle=photoTitletxt.text;
        photoTagstr=photoTag.text;
    }
    @catch (NSException *exception) {
        
    }
    
    if([photodes isEqualToString:@"Now describe your picture \ne.g. what is it a picture of? Who is in the picture?"])
        photodes=@"";        
        
    if(photoTitle.length==0)
        photoTitle=@"Untitled";
    else
        photoTitle = photoTitletxt.text;
    
    if(photoTagstr.length==0) photoTagstr=@"";
    
    if(self.isPhotoAdd || isLaunchCamera)
    {
        NSDictionary *photoDetail=@{@"photo_title":photoTitle,@"photo_description":photodes,@"photo_tags":photoTagstr};
        manager=[ContentManager sharedManager];
       [manager storeData:@"YES" :@"isfromphotodetailcontroller"];
        [manager storeData:photoDetail :@"takephotodetail"];
    }
    else
    {
        isPhotoDetailSaveOnServer=YES;
        // Saves photos on server and the details in NSUserDefaults
        
        @try {
            NSMutableArray *photoinfoarray=[NSKeyedUnarchiver unarchiveObjectWithData:[[manager getData:@"photoInfoArray"] mutableCopy]];
            
            NSDictionary *photoDetail=[photoinfoarray objectAtIndex:self.selectedIndex];
            
            NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
            [dic setObject:[photoDetail objectForKey:@"collection_photo_added_date"] forKey:@"collection_photo_added_date"];
            [dic setObject:photodes forKey:@"collection_photo_description"];
            [dic setObject:photoTitle forKey:@"collection_photo_title"];
            [dic setObject:self.photoId forKey:@"collection_photo_id"];
            [dic setObject:[photoDetail objectForKey:@"collection_photo_filesize"] forKey:@"collection_photo_filesize"];
            [dic setObject:userid forKey:@"collection_photo_user_id"];

            // Update photo info array in NSUserDefaults
            
            [photoinfoarray replaceObjectAtIndex:self.selectedIndex withObject:dic];
            
            NSData *data=[NSKeyedArchiver archivedDataWithRootObject:photoinfoarray];
            [manager storeData:data :@"photoInfoArray"];
            
            NSDictionary *dicData=@{@"user_id":userid,@"photo_id":self.photoId,@"photo_title":photoTitle,@"photo_description":photodes,@"photo_location":photoLocationString,@"photo_tags":photoTag.text,@"photo_collections":self.collectionId};
            [manager storeData:@"YES" :@"editphotodetails"];
            [manager storeData:photoTitle :@"phototitle"];
            
            // Calls webservice to save photos on server
            
            webservices=[[WebserviceController alloc] init];
            webservices.delegate=self;
            [webservices call:dicData controller:@"photo" method:@"change"];
        }
        @catch (NSException *exception) {
            
        }      
    }
    [self.navigationController popViewControllerAnimated:YES];

}
#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data{
    NSLog(@"Response %@",data);
}

#pragma mark - UIButton Action Methods

-(IBAction)savePhotoDetail:(id)sender
{
    @try {
        [self savePhotoDetailOnServer];
    }
    @catch (NSException *exception) {
        
    }
}
-(IBAction)cancelPhotoDetail:(id)sender
{
    @try {
        photoTitletxt.text=@"";
        photoDescriptionTxt.text=@"";
        photoTag.text=@"";
       if(self.isLaunchCamera)
       {
           // Set ups previous view controller and moves back to it
           
           AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
           [manager storeData:@"YES" :@"istabcamera"];
           delgate.navControllerhome.viewControllers=[NSArray arrayWithObjects:home, nil];
           [delgate.tbc setSelectedIndex:0];
       }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    // Sets custom back button on navbar
    
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    UILabel *titleLabel=[navnBar navBarTitleLabel:@"Photo Details"];
    if(!self.isLaunchCamera && !self.isPhotoAdd)
    {
         [navnBar addSubview:button];
    }
    [navnBar addSubview:titleLabel];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    // Reverse Geocoding to resolve address
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            NSString *location = [NSString stringWithFormat:@"%@,%@,%@",  placemark.locality,placemark.administrativeArea,                                  placemark.country];
            
            photoLocationString=location;
            NSLog(@"Current location is %@",location);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
    [locationManager stopUpdatingLocation];
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Set scroll view offset when textfield in it is edited
    
    if([manager isiPad])
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,textField.center.y-70) animated:NO];
        }
    }
    else
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [scrollView setContentOffset:CGPointMake(0,textField.center.y-30) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,textField.center.y-30) animated:NO];
        }
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextView Delegate Methods

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    // Set scroll view offset when textView in it is edited
    
    if([manager isiPad])
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,textView.center.y-80) animated:NO];
        }
    }
    else
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,textView.center.y-30) animated:NO];
        }
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if([photoDescriptionTxt.text isEqualToString:@"Now describe your picture \ne.g. what is it a picture of? Who is in the picture?"])
        photoDescriptionTxt.text = @"";
    
    photoDescriptionTxt.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(photoDescriptionTxt.text.length == 0){
        photoDescriptionTxt.textColor = [UIColor darkGrayColor];
        photoDescriptionTxt.text = @"Now describe your picture \ne.g. what is it a picture of? Who is in the picture?";
        [photoDescriptionTxt resignFirstResponder];
    }
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if(photoDescriptionTxt.text.length == 0){
        photoDescriptionTxt.textColor = [UIColor darkGrayColor];
        photoDescriptionTxt.text = @"Now describe your picture \ne.g. what is it a picture of? Who is in the picture?";
        [photoDescriptionTxt resignFirstResponder];
    }
    
    return YES;
}

@end
