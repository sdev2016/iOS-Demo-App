// 
// UserSecurityViewController.h
// photoshare
// 
// Created by Dhiru on 28/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"
#import "NavigationBar.h"
@class ContentManager;
@interface UserSecurityViewController : UIViewController <WebserviceDelegate, UITextFieldDelegate>
{
    IBOutlet UITextField *oldpass ;
    IBOutlet UITextField *newpass ;
    IBOutlet UIScrollView *scrollView;
    
    WebserviceController *wc ;
    DataMapperController *dmc ;
    ContentManager *objManager;
    NavigationBar *navnBar;
    
}

- (IBAction)changepassword:(id)sender ;
- (IBAction)userCancelButton:(id)sender ;

@end
