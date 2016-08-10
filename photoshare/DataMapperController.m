// 
// DataMapperController.m
// photoshare
// 
// Created by Dhiru on 29/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 
// 

#import "DataMapperController.h"
#import "ContentManager.h"
#import "AppDelegate.h"
@interface DataMapperController ()

@end

/**
 *  This class intefaces with ContentManager to store and retrieve form NSuserDefauts
 */
@implementation DataMapperController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
}
-(id)init
{
    objManager=[ContentManager sharedManager];
    return self;
}

/**
 *  Setter methods
 */

-(void) setUserId:(NSString *)userid
{
  
  [objManager storeData:userid :@"user_id"];
    
}

-(void) setUserName:(NSString *)username
{
    [objManager storeData:username :@"user_username"];
}

-(void) setUserDetails:(NSDictionary *) dic
{
    [objManager storeData:dic :@"user_details"];
    [objManager storeData:@"YES" :@"login"];

}

-(void) setRememberMe:(NSString *)value
{
    [objManager storeData:value :@"user_remember"];
}

-(void) setRememberFields:(NSDictionary *)dict
{
    [objManager storeData:dict :@"user_loginFields"];
}
-(void) sethomeIndex
{
    NSString *str= @"TRUE";
    [objManager storeData:str :@"setHomeIndex"];
}

/**
 *  Getter Methods
 */

-(NSString *) getUserId
{
    NSString  *userid = [objManager getData:@"user_id"];
    return userid;
}

-(NSDictionary *) getUserDetails
{
    NSDictionary *user_details = [objManager getData:@"user_details"];
    return user_details;
}

-(NSString *)getUserName
{
    NSString *username = [objManager getData:@"user_username"];
    return username;
}

-(NSString *)getRemeberMe
{
    NSString *remeber = [objManager getData:@"user_remember"];
    return remeber;
}

-(NSDictionary *)getRememberFields
{
    NSDictionary *dictionary = [objManager getData:@"user_loginFields"];
    return dictionary;
}
-(BOOL) gethomeIndex
{
    NSString *str = [objManager getData:@"setHomeIndex"];
    return (BOOL)str;
}
/**
 *  Getters
 */


-(void) resetHomeIndex
{
    NSString *str= @"FALSE";
    [objManager storeData:str :@"setHomeIndex"];
}

/**
 *  Stores collection data list
 */

-(void)setCollectionDataList :(NSMutableArray *)collectionArray
{
    [objManager storeData:collectionArray :@"collection_data_list"];
}
/**
 *  Gets collection data list
 */
-(NSMutableArray *)getCollectionDataList
{
    return [[objManager getData:@"collection_data_list"] mutableCopy];
}


/**
 *  Clears NSUserDefaults using ContentManager
 *  and deletes 123Friday folder from the device
 */

-(void)removeAllData
{
    [objManager storeData:@"NO" :@"login"];
       
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager removeItemAtPath:[documentsDirectoryPath stringByAppendingPathComponent:@"/123FridayImages"] error:nil])
    {
        NSLog(@"123FridayImages Cleared From Cache");
    }
    
    NSString *rememberMe=[self getRemeberMe];
    NSDictionary *remeberFeild=[self getRememberFields];
    
    // Removes all data from NSUserDefaults
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    // Sets remember me in NSUserDefaults
    
    [self setRememberMe:rememberMe];
    [self setRememberFields:remeberFeild];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
