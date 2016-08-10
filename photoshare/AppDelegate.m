
// AppDelegate.m
// photoshare
//
// Created by Dhiru on 22/01/14.  22.67
// Copyright (c) 2014 ignis. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ReferFriendViewController.h"
#import "EarningViewController.h"
@implementation AppDelegate
@synthesize window,tbc,photoGalNav;
@synthesize navControlleraccount,navControllercommunity,navControllerearning,navControllerhome,navControllercamera,isSetDeviceTokenOnServer,useridforsetdevicetoken;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    objManager = [ContentManager sharedManager];
    dmc=[[DataMapperController alloc] init];
    self.isSetDeviceTokenOnServer=NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    LoginViewController *lg = [[LoginViewController alloc] init];
    
    // FBLogin View Class
    [FBLoginView class];
    
    // Register for Push Notifications
    [self registerThepushNotification:application];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window.rootViewController = lg;
    [self.window makeKeyAndVisible];
    return YES;
}

/**
 *  Register For Push Notification
 */

-(void)registerThepushNotification:(UIApplication *)application
{
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
}


/**
 *  Push Notification Register response With Device Token
 */

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    _token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"My token is: %@", _token);
    @try {
        if(self.isSetDeviceTokenOnServer)
        {
            self.isSetDeviceTokenOnServer=NO;
            [self setDevieTokenOnServer:_token userid:self.useridforsetdevicetoken];
        }
    }
    @catch (NSException *exception) {
        
    }
}

/**
 *  When Application Receive Push Notification
 */

#pragma mark - 1

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self receiveNotification:application userInfo:userInfo];
}

#pragma mark - 2

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self receiveNotification:application userInfo:userInfo];
}


/**
 *  Perform Action on Receive Push Notification
 */

-(void)receiveNotification :(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
    NSString *message=[[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    NSString *type=[userInfo objectForKey:@"type"];
    NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
    numberOfBadges -=1;
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
    
    // For Video Related Notifications
    if([type isEqualToString:@"video"])
    {
        if (application.applicationState==UIApplicationStateActive) {
            UIAlertView * notificationAlert = [[UIAlertView alloc] initWithTitle:@"Notification !" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View", nil];
            [notificationAlert setTag:101];
            [notificationAlert show];
        }
        else if (application.applicationState==UIApplicationStateInactive || application.applicationState==UIApplicationStateBackground) {
            ReferFriendViewController *rvc=[[ReferFriendViewController alloc] init];
            [self.navControllerhome pushViewController:rvc animated:YES];
        }
    }
    
    // For Earning Related Notifications
    else if ([type isEqualToString:@"earn"])
    {
        if (application.applicationState==UIApplicationStateActive)
        {
            UIAlertView * notificationAlert = [[UIAlertView alloc] initWithTitle:@"Notification !" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View", nil];
            [notificationAlert setTag:102];
            [notificationAlert show];
        }
        else if (application.applicationState==UIApplicationStateInactive || application.applicationState==UIApplicationStateBackground) {
            @try
            {
                [self.tbc setSelectedIndex:1];
            }
            @catch (NSException *exception)
            {
                
            }
        }
    }
    // For Other Types Notifications
    else
    {
        if (application.applicationState==UIApplicationStateActive)
        {
            UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"Notification !" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [notificationAlert show];
        }
    }
}


#pragma mark - UIAlertView delegate method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // For Video Related Notifications
    if (alertView.tag == 101) {
        NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
        numberOfBadges -=1;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
        if (buttonIndex == 1)
        {
            @try
            {
                ReferFriendViewController *rvc=[[ReferFriendViewController alloc] init];
                [self.navControllerhome pushViewController:rvc animated:YES];
            }
            @catch (NSException *exception)
            {
                
            }
        }
    }
    // For Earning Related Notifications
    else if (alertView.tag == 102) {
        EarningViewController *earnView=[[EarningViewController alloc] init];
        if (buttonIndex == 1)
        {
            @try
            {
                self.navControllerearning.viewControllers=[[NSArray alloc] initWithObjects:earnView, nil];
                [self.tbc setSelectedIndex:1];
            }
            @catch (NSException *exception)
            {
                
            }
        }
        else if (buttonIndex==0)
        {
            @try
            {
                [earnView getIncomeFromServer];
            }
            @catch (NSException *exception)
            {
                
            }
        }
    }
}



- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error.description);
}

/**
 *  Set Device Token On Server with User ID
 */

-(void)setDevieTokenOnServer:(NSString *)devToken userid:(NSString *)user_id{
    webservices=[[WebserviceController alloc] init];
    webservices.delegate=self;
    NSDictionary *dic=@{@"user_id":user_id,@"device_token":devToken,@"platform":@"3"};    // Platfom 3-IOS and 4-Android
    NSString *controller=@"push";
    NSString *method=@"register_device";
    [webservices call:dic controller:controller method:method];
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Device_Token is Register On Server -:%@",data);
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Crash" message:@"Your application is crash" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:Nil, nil];
    [alert show];
}


#pragma mark - FaceBook AppCall

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Parse the incoming URL to look for a target_url parameter
                                      NSString *query = [url fragment];
                                      if (!query) {
                                          query = [url query];
                                      }
                                      NSDictionary *params = [self parseURLParams:query];
                                      
                                      // Check if target URL exists
                                      
                                      NSString *targetURLString = [params valueForKey:@"target_url"];
                                      if (targetURLString) {
                                          
                                          // Directs users to appropriate flow within our app
                                          
                                          [[[UIAlertView alloc] initWithTitle:@"Received link:"                                                                      message:targetURLString                                                                     delegate:self                                                            cancelButtonTitle:@"OK"                                                            otherButtonTitles:nil] show];
                                      }
                                  }];
    return urlWasHandled;
}

/**
 *  A function for parsing URL parameters
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}
@end