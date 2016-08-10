// 
// SearchPhotoViewController.h
// photoshare
// 
// Created by ignis2 on 13/02/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "ContentManager.h"
#import "WebserviceController.h"
#import "NavigationBar.h"
#import "DataMapperController.h"
#import "LargePhotoViewController.h"
// for mail send
#import <MessageUI/MFMailComposeViewController.h>
@interface SearchPhotoViewController : UIViewController<UISearchBarDelegate,WebserviceDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate>
{
    IBOutlet UISearchBar *searchBarForPhoto;
    IBOutlet UICollectionView *collectionViewForPhoto;
       
    WebserviceController *webservice;
    ContentManager *manager;
    DataMapperController *dmc;
    NavigationBar *navnBar;
    LargePhotoViewController *largePhoto;
    
    NSNumber *userid;
    NSString *searchString;
    NSArray *searchResultArray;
    NSMutableArray *photoArray;
    NSMutableArray *photDetailArray;
    
    int photoCount;
    
    BOOL isSearchPhoto;
    BOOL isGetPhotoFromServer;
    BOOL isPopFromSearchPhoto;
    BOOL isStartGetPhoto;
    BOOL isViewLargeImageMode;

    NSInteger selectedIndex;
    UIImageView *imgView1;
    UIView *backBtnContainerView;
}
@property(nonatomic,retain)NSString *searchType;
@end
