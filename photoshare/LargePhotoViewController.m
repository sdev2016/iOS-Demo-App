// 
// LargePhotoViewController.m
// photoshare
// 
// Created by ignis2 on 13/03/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "LargePhotoViewController.h"
#import "ContentManager.h"
@interface LargePhotoViewController ()

@end

@implementation LargePhotoViewController
@synthesize photoId,colId,imageLoaded,isFromPhotoViewC;
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
    
    // Detect device and load nib
    
    if([[ContentManager sharedManager] isiPad])
    {
        [[NSBundle mainBundle] loadNibNamed:@"LargePhotoViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"LargePhotoViewController" owner:self options:nil];
    }
    
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    
    // Set The Loading Indicator
    activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [imgView addSubview:activityIndicator];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden=YES;
     [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    
    // Check if called from PhotoViewController or SearchPhotoViewController
    if(self.isFromPhotoViewC)
    {
        imgView.image=self.imageLoaded;
    }
    else
    {
        imgView.image=nil;
        
        [activityIndicator startAnimating];
        activityIndicator.tag=1100;
        activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |                                        UIViewAutoresizingFlexibleRightMargin |                                        UIViewAutoresizingFlexibleTopMargin |                                        UIViewAutoresizingFlexibleBottomMargin);
        activityIndicator.center = CGPointMake(CGRectGetWidth(imgView.bounds)/2, CGRectGetHeight(imgView.bounds)/2);
        [activityIndicator setAlpha:1];
        
        
        [self getPhoto];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.tabBarController.tabBar.hidden=NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *  Request Large image from server
 */

-(void)getPhoto
{
    isGetOriginalPhotoFromServer=YES;
    NSString *resize=@"0";
   
    [self getPhotoFromServer:resize];
}
-(void)getPhotoFromServer :(NSString *)resize
{
    // Get Larger version photo from server
    
    NSDictionary *dicData;
    
    @try {
        webservices.delegate=self;
        NSNumber *num = [NSNumber numberWithInt:1] ;
        
        dicData = @{@"user_id":[manager getData:@"user_id"],@"photo_id":self.photoId,@"get_image":num,@"collection_id":self.colId,@"image_resize":resize};
        [webservices call:dicData controller:@"photo" method:@"get"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is found :%@",exception.description);
    }
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallbackImage:(UIImage *)image
{
    // Displays the incoming requsted image from server
    if(isGetOriginalPhotoFromServer)
    {
        [activityIndicator setAlpha:0];
        
        imgView.image=image;
        isGetOriginalPhotoFromServer=NO;
    }
}
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Call Back In Large Image view %@",data);
}

/**
 *  Back Button Action
 */
-(IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.tabBarController.tabBar.hidden=NO;
}

@end
