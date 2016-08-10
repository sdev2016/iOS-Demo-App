// 
// CameraViewController.h
// photoshare
// 
// Created by ignis2 on 27/03/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "LaunchCameraViewController.h"
#import "ContentManager.h"
@interface CameraViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>
{
    AppDelegate *delegate;
    LaunchCameraViewController *lcam;
    ContentManager *manager;
    
    UIImagePickerController *imagePicker;
}
@property(nonatomic,retain)UIPopoverController *popover;
@end
