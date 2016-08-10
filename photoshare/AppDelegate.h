// 
// AppDelegate.h
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"
#import <FacebookSDK/FacebookSDK.h>
@class ContentManager;
@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,WebserviceDelegate>
{
    ContentManager *objManager;
    WebserviceController *webservices;
    DataMapperController *dmc;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)UITabBarController *tbc;
@property (strong, nonatomic) UINavigationController *navControllerhome,*navControllerearning,*navControllercamera,*navControllercommunity,*navControlleraccount,*photoGalNav;

@property(nonatomic,assign)BOOL isSetDeviceTokenOnServer,isGoToReferFriendController;
@property(nonatomic,retain)NSString *useridforsetdevicetoken;
// For Push Notifications
@property (strong, nonatomic) NSString *token;
-(void)setDevieTokenOnServer:(NSString *)devToken userid:(NSString *)user_id;
@end
