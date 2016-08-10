
// 
// WebserviceController.m
// photoshare
// 
// Created by Dhiru on 26/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "WebserviceController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"
#import "ContentManager.h"
@interface WebserviceController ()
{
    BOOL isGetPhoto;
}
@end

@implementation WebserviceController

@synthesize delegate;

-(id)init
{
    manager = [AFHTTPRequestOperationManager manager];
     apiUrl=@"api.staging.123friday.com/v/2";

    return self;
}

/**
 * Save Data On Server
 */

-(void) call:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method
{
    NSMutableDictionary *parameters = [postData mutableCopy];
    
    // Making a AFHTTPRequestOperationManager request to fetch data from server
    
   if(![method isEqual:@"login"])
   {
       [manager.requestSerializer setValue:[[ContentManager sharedManager] getData:@"token"] forHTTPHeaderField:@"X-123-Token"];
   }
   if([controller isEqualToString:@"photo"] && [method isEqualToString:@"get"])
   {
        isGetPhoto=YES;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"image/png",@"image/jpeg",@"image/jpg", nil];
        
        [manager setResponseSerializer:[AFImageResponseSerializer new]];
   }
    
    [manager POST:[NSString stringWithFormat:@"http://%@/%@/%@",apiUrl,controller,method ] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if(isGetPhoto)
        {
            isGetPhoto=NO;
            [self.delegate webserviceCallbackImage:responseObject];
        }
        else
        {
            NSDictionary *JSON = (NSDictionary *) responseObject;
            [self.delegate webserviceCallback:JSON];
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        if(isGetPhoto)
        {
            UIImage *img=NULL;
             isGetPhoto=NO;
             [self.delegate webserviceCallbackImage:img];
        }
        else
        {
            [self.delegate webserviceCallback:[NSDictionary dictionaryWithObject:@0 forKey:@"exit_code"]];
        }
    }];
}

/**
 *Save File On Server
 */

-(void)saveFileData:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method filePath:(NSData *)imageData{
    
   NSMutableDictionary *parameters = [postData mutableCopy];
    [manager.requestSerializer setValue:[[ContentManager sharedManager] getData:@"token"] forHTTPHeaderField:@"X-123-Token"];
    [manager POST:[NSString stringWithFormat:@"http://%@/%@/%@",apiUrl,controller,method ] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:imageData name:@"file" fileName:@"photo.png" mimeType:@"image/png"];
    
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSDictionary *JSON = (NSDictionary *) responseObject;
        [self.delegate webserviceCallback:JSON];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        [self.delegate webserviceCallback:[NSDictionary dictionaryWithObject:@0 forKey:@"exit_code"]];
            }];    
}

/**
 * Get Shared Collection List
 * @params have the Shared Collection List which has Write Permission
 */
-(void) getSharedCollectionList:(NSArray *)sharedCollection userid:(NSNumber *)userid
{
    
    NSMutableArray *sharedCollIdArray=[[NSMutableArray alloc] init];
     NSMutableArray *sharedCollNameArray=[[NSMutableArray alloc] init];
    for (int i=0;i<sharedCollection.count; i++)
    {
        NSDictionary *parameters =@{
                                    @"user_id":userid,
                                    @"collection_id":[sharedCollection objectAtIndex:i]
                                    };
        [manager.requestSerializer setValue:[[ContentManager sharedManager] getData:@"token"] forHTTPHeaderField:@"X-123-Token"];
        [manager POST:[NSString stringWithFormat:@"http://%@/%@/%@",apiUrl,@"collection",@"get" ] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSDictionary *JSON = (NSDictionary *) responseObject;
             NSDictionary *outPutDta=[JSON objectForKey:@"output_data"];
             NSArray *colper=[outPutDta objectForKey:@"collection_write_user_ids"];
             
             @try {
                 if([colper containsObject:userid])
                 {
                     [sharedCollIdArray addObject:[outPutDta objectForKey:@"collection_id"]];
                     [sharedCollNameArray addObject:[outPutDta objectForKey:@"collection_name"]];
                 }
                 if(i==sharedCollection.count-1)
                 {
                     [self.delegate responseShareWritePermissionCollectionList:sharedCollIdArray colNameArr:sharedCollNameArray];
                 }
             }
             @catch (NSException *exception) {
                 
             }
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [self.delegate responseShareWritePermissionCollectionList:sharedCollIdArray colNameArr:sharedCollNameArray];
             [sharedCollIdArray removeAllObjects];
             [sharedCollNameArray removeAllObjects];
         }];
    }
    
    NSLog(@"Array Val %@",sharedCollNameArray);
}

@end
