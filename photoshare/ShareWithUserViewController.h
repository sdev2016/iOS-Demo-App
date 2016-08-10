// 
// ShareWithUserViewController.h
// photoshare
// 
// Created by ignis2 on 10/02/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "ContentManager.h"
#import "WebserviceController.h"
@interface ShareWithUserViewController : UIViewController<WebserviceDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    
    IBOutlet UIButton *userAddButton;
    IBOutlet UIButton *saveBtn;
    IBOutlet UICollectionView *sharingUserListCollView;
    IBOutlet UIView *shareSearchView;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UISearchBar *searchBarForUserSearch;
    
    ContentManager *manager;
    WebserviceController *webservices;
    
    NSNumber *userid;
        
    BOOL isGetCollectionDetails;
    BOOL isSearchUserList;
    BOOL isShareForWritingWith;
    BOOL isShareForReadingWith;

    NSNumber *selectedUserId;
    NSString *selecteduserName;
    
   
    NSMutableArray *searchUserListResult;
    NSMutableArray *searchUserIdResult;
    NSMutableArray *searchUserRealNameResult;
    UIButton *searchList;
    
    NSMutableArray *searchUserList;    
   
    NSMutableArray *sharingUserNameArray;
    NSMutableArray *sharingUserIdArray;
    
    UIView *searchView;

    // Creating Table for user List
    UITableView *searchViewTable;
    
    // check orientation
    UIInterfaceOrientation orientation;
}
@property(nonatomic,assign)BOOL isEditFolder;
@property(nonatomic,assign)BOOL isWriteUser;
@property(nonatomic,assign)NSNumber *collectionId;
@property(nonatomic,assign)NSNumber *collectionOwnerId;
@property(nonatomic,retain)NSDictionary *collectionUserDetails;
-(IBAction)addUserInSharing:(id)sender;
-(IBAction)saveSharingUser:(id)sender;
@end
