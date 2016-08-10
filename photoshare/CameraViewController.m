// 
// CameraViewController.m
// photoshare
// 
// Created by ignis2 on 27/03/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "CameraViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController
@synthesize popover;
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
    delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    lcam=[[LaunchCameraViewController alloc] init];
    manager=[ContentManager sharedManager];
}
-(void)viewWillAppear:(BOOL)animated
{
    imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.delegate=self;
    
    // Check camera on device
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:NO completion:nil];
    }
    else
    {
        [self showStatusBar];
        [manager showAlert:@"Error !" msg:@"Camera is Not Available" cancelBtnTitle:@"Ok" otherBtn:nil];
        self.tabBarController.selectedIndex=0;
    }
}

#pragma mark - UIImagePicker Controller Delegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    @try {
        if(picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        {
            image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
        }
    }
    @catch (NSException *exception) {
        
    }
    lcam.pickerimage=image;
    
    // Dismisses ImagePicker so as we can directly visit LanchCamera Controller
    
    [manager storeData:@"YES" :@"reset_camera"];
    [manager removeData:@"is_add_folder,isfromphotodetailcontroller,istabcamera"];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [self.navigationController pushViewController:lcam animated:NO];
    
    [self showStatusBar];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Settings to visit the direct parent view in the previous TabBar
    
    [self dismissViewControllerAnimated:NO completion:nil];
    delegate.tbc.selectedIndex=0;
    [self showStatusBar];
}

/**
 *  Show status Bar
 */

-(void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
