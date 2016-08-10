// 
// UploadMultiplePhotoOnServerViewController.h
// photoshare
// 
// Created by ignis2 on 01/05/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"

@protocol UploadMultiplePhotoOnServerViewControllerDelegate <NSObject>

-(void)responseForMultiPleImageUpload:(UIImage *)img imgid:(NSNumber *)imgid colId:(NSNumber *)colId;
-(void)uploadStatus:(BOOL)status;

@end
@interface UploadMultiplePhotoOnServerViewController : UIViewController
{
    NSUInteger totalPhoto;
    NSUInteger countUploadPhoto;
    NSUInteger countUploadTotalPhoto;
    UIBackgroundTaskIdentifier *bacctaskIde;
    NSArray *photoArrayColl;
    NSNumber *userIdT;
    NSNumber *colIdT;
    
    AFHTTPRequestOperationManager *manager ;
    UIView *view;
    UILabel *statusLabel;
    NSString *apiUrl;
    
    NSMutableDictionary *postData1;
    NSData *imgData1;
}
@property(nonatomic,retain)id<UploadMultiplePhotoOnServerViewControllerDelegate>delegate;

+(UploadMultiplePhotoOnServerViewController *)sharedMultipleUpload;
-(void)uploadMultiplePhoto:(NSArray *)photoArray userId:(NSNumber *)userId collectionId:(NSNumber *)colId;
@end
