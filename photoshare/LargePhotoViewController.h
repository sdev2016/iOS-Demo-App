// 
// LargePhotoViewController.h
// photoshare
// 
// Created by ignis2 on 13/03/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "ContentManager.h"
@interface LargePhotoViewController : UIViewController<WebserviceDelegate>
{
    IBOutlet UIButton *backButton;
    IBOutlet UIImageView *imgView;
    
    WebserviceController *webservices;
    ContentManager *manager;
    
    BOOL isGetOriginalPhotoFromServer;
    
    UIActivityIndicatorView *activityIndicator;
}
@property(nonatomic,retain)NSNumber *photoId;
@property(nonatomic,retain)NSNumber *colId;
@property(nonatomic,assign)BOOL isFromPhotoViewC;
@property(nonatomic,retain)UIImage *imageLoaded;
@end
