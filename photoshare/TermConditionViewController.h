// 
// TermConditionViewController.h
// photoshare
// 
// Created by Dhiru on 28/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "NavigationBar.h"
@class ContentManager;
@interface TermConditionViewController : UIViewController
{
    IBOutlet UIWebView *webview ;
    IBOutlet UILabel *headingLabel;
    
    ContentManager *objManager;
    NavigationBar *navnBar ;
}

@end
