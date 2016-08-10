// 
// WebserviceController.h
// photoshare
// 
// Created by Dhiru on 26/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"

@protocol WebserviceDelegate <NSObject>

@required
-(void) webserviceCallback: (NSDictionary *)data;

@optional
-(void) webserviceCallbackImage:(UIImage *)image ;
-(void)responseShareWritePermissionCollectionList:(NSArray *)colIdArray colNameArr:(NSArray *)colNameArr;
@end

@interface WebserviceController : NSObject <NSURLConnectionDelegate>
{
    id<WebserviceDelegate> delegate;
    AFHTTPRequestOperationManager *manager ;
    
    NSString *apiUrl;
}

@property (nonatomic,strong) id<WebserviceDelegate> delegate;
-(void) call:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method;
-(void)saveFileData:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method filePath:(NSData *)imageData;
// For Sharing Collection
-(void) getSharedCollectionList:(NSArray *)sharedCollection userid:(NSNumber *)userid;
@end
