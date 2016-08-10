// 
// EarningViewController.h
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"
#import "NavigationBar.h"
@class ContentManager;

@interface EarningViewController : UIViewController<WebserviceDelegate>
{
    IBOutlet UILabel *totalEarningLabel;
    IBOutlet UIScrollView *scrollView;
    
    DataMapperController *dmc;
    ContentManager *objManager;
    WebserviceController *webservice;
    NavigationBar *navnBar;
    
    BOOL isGetIcomeDetail;
    BOOL isGetEarning;
}
-(void)getIncomeFromServer;
@end
