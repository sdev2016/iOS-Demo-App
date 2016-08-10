// 
// EditProfileViewController.h
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
@interface EditProfileViewController : UIViewController <WebserviceDelegate, UITextFieldDelegate>
{

    IBOutlet UITextField *name ;
    IBOutlet UITextField *email;
    IBOutlet UITextField *pass;
    IBOutlet UIButton *save;
    IBOutlet UIScrollView *scrollView;
    
    ContentManager *objManager;    
    WebserviceController *wc ;
    DataMapperController *dmc;
    NavigationBar *navnBar;
    
    NSString *calltype ;
    
}
-(IBAction)saveProfile:(id)sender ;
-(IBAction)userCancelButton:(id)sender;


@end
