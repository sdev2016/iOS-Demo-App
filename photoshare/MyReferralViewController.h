// 
// MyReferralViewController.h
// photoshare
// 
// Created by ignis3 on 25/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"
#import "NavigationBar.h"
@class ContentManager;
@interface MyReferralViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,WebserviceDelegate>
{
    IBOutlet UITableView *tableViews;
    DataMapperController *dmc;
    ContentManager *ObjManager;
    NavigationBar *navnBar;
}
@property (nonatomic, strong) IBOutlet UITableView *tableViews;

@end
