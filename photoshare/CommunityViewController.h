// 
// CommunityViewController.h
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "ContentManager.h"
#import "WebserviceController.h"
#import "DataMapperController.h"
#import "NavigationBar.h"
#import "SearchPhotoViewController.h"
@class CollectionViewCell;
@interface CommunityViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource, UINavigationControllerDelegate,WebserviceDelegate>
{
    IBOutlet UICollectionView *collectionview;
    IBOutlet UIProgressView *progressView;
    IBOutlet UILabel *diskSpaceTitle;
    
    NSMutableArray *collectionArrayWithSharing;
    NSMutableArray *collectionDefaultArray;
    NSMutableArray *collectionIdArray;
    NSMutableArray *collectionNameArray;
    NSMutableArray *collectionSharingArray;
    NSMutableArray *collectionSharedArray;
    NSMutableArray *collectionUserIdArray;
    NSMutableArray *sharingIdArray;
    
    NSInteger selectedFolderIndex;
    
    WebserviceController *webservices;
    ContentManager *manager;
    DataMapperController *dmc;
    NavigationBar *navnBar;
    CollectionViewCell *obj_Cell;
    SearchPhotoViewController *searchController;
    
    NSNumber *userid;
    UIActivityIndicatorView *indicator;
    
    BOOL isGetStorage;
    BOOL isGetCollectionInfo;
    BOOL isGetTheOwnCollectionListData;
    BOOL isGetTheSharingCollectionListData;
    BOOL isGetSharingUserId;
    
    int countSharing;
    
}
@property (nonatomic,assign)BOOL isInNavigation;
@property (nonatomic,assign)BOOL updateCollectionDetails;

@end
