// 
// AddFolderViewController.h
// photoshare
// 
// Created by ignis2 on 24/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "ContentManager.h"
#import "NavigationBar.h"
@interface AddEditFolderViewController : UIViewController<UITextFieldDelegate,UINavigationBarDelegate, UINavigationControllerDelegate,WebserviceDelegate,UIAlertViewDelegate>
{
    IBOutlet UIView *folderNameView;
    IBOutlet UIButton *addButton;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *deleteButton;
    IBOutlet UITextField *folderName;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UILabel *collectionOwnerNameLbl;
    IBOutlet UIButton *shareForWritingWithBtn;
    IBOutlet UIButton *shareForReadingWithBtn;
    IBOutlet UIButton *crossBtnForTF;
    
    NSNumber *userid;
    ContentManager *manager;
    WebserviceController *webservices;
    NavigationBar *navnBar;

    NSNumber *newCollectionId;
    
    BOOL isAdd;
    BOOL isSave;
    BOOL isDelete;
    BOOL isGetPhotoIdFromServer;
    BOOL isGetCollectionDetails;
    BOOL isGetCollectionOwnername;
    BOOL isDeletePhotoMode;
    BOOL isGetTheOwnCollectionListData;
    BOOL isGetTheSharingCollectionListData;
    BOOL isGetSharingUserId;
    BOOL isDeleteAllPhoto;
    
    int countSharing;
    
    NSString *collectionOwnerName;
    UITextField *activeField;
    
    NSMutableArray *photoIdArray;
    NSMutableDictionary *collectionDetail;
    NSMutableArray *searchUserList;
    
    NSString *user_message;
    
    NSMutableArray *collectionArrayWithSharing;
    NSMutableArray *sharingIdArray;
    
    NSDictionary *collectionUsersDetail;

    UIInterfaceOrientation orientation;
}

@property(nonatomic,assign)BOOL isAddFolder;
@property(nonatomic,assign)BOOL isEditFolder;
@property(nonatomic,assign)BOOL isFromLaunchCamera;

@property(nonatomic,assign)NSNumber *collectionId;
@property(nonatomic,retain)NSString *setFolderName;
@property(nonatomic,assign)NSNumber *collectionOwnerId;

-(IBAction)clearTextField:(id)sender;
-(IBAction)addFolder:(id)sender;
-(IBAction)saveFolder:(id)sender;
-(IBAction)deleteFolder:(id)sender;

-(IBAction)shareForWritingWith:(id)sender;
-(IBAction)shareForReadingWith:(id)sender;

@end
