// 
// HomeViewController.h
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"
#import "ContentManager.h"

@protocol homeDelagate <NSObject>

-(void)earningView;

@end
@class ContentManager;
@interface HomeViewController : UIViewController<WebserviceDelegate>
{
    IBOutlet UIImageView *profilePicImgView;
    IBOutlet UILabel *welcomeName;
    IBOutlet UIView *folderIconViewContainer;
    
    UINavigationController *navController;
    NSNumber *publicCollectionId;
    NSNumber *colOwnerId;
    
    ContentManager *manager;
    WebserviceController *webservices;
    DataMapperController *dmc ;
    
    int folderIndex;
    BOOL isGetTheNoOfImagesInPublicFolder;
    NSNumber *userid;
}
@property(nonatomic,retain) id<homeDelagate>delegate;

-(IBAction)goToReferFriend:(id)sender;
-(IBAction)goToCommunity:(id)sender;
-(IBAction)goToPublicFolder:(id)sender;


@end
