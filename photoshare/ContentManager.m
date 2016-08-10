// 
// ContentManager.m
// schudio
// 
// Created by ignis3 on 16/01/14.
// Copyright (c) 2014 ignis2. All rights reserved.
// 

#import "ContentManager.h"
#import "NavigationBar.h"



@implementation ContentManager
@synthesize loginDetailsDict;
@synthesize weeklyearningStr;

static ContentManager *objContantManager = nil;

+(ContentManager *)sharedManager {
    if(objContantManager == Nil) {
        objContantManager = [[ContentManager alloc] init];
    }
    return objContantManager;
}

/**
 *Store data on Nsuser Defaults
 */

-(void)storeData:(id)storeObj :(NSString *)storeKey{
    
    
    @try {
        NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
        [defaultData setObject:storeObj forKey:storeKey];
        
        [defaultData synchronize];
       
    }
    @catch (NSException *exception) {
       
    }
}

/**
 *Get Data from NSUserDefaults by keyString
 */

-(id)getData:(NSString *)getKey{
    id getData = nil;
     getData = [[NSUserDefaults standardUserDefaults] objectForKey:getKey];
    return getData;
}

/**
 *Remove Data from NSUserDefaults by keyString
 */

-(void)removeData :(NSString *)keysString
{
    @try {
        NSArray *keyArray=[keysString componentsSeparatedByString:@","];
        
        for (int i=0; i<keyArray.count; i++) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[keyArray objectAtIndex:i]];
            
        }
        [[NSUserDefaults standardUserDefaults]synchronize ];
    }
    @catch (NSException *exception) {
        NSLog(@"Execption in Remove Data from nsuser default is %@",exception.description);
    }
}

/**
 *Show Alert Message
 */

-(void)showAlert:(NSString *)alrttittle msg:(NSString *)msg cancelBtnTitle:(NSString *)btnTittle otherBtn:(NSString *)otherBtn{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alrttittle message:msg delegate:nil cancelButtonTitle:btnTittle otherButtonTitles:otherBtn, nil];
    [alert show];
}

// CHECKS IF DEVICE IS IPAD

-(BOOL)isiPad
{
    if ( [(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] )
    {
        return YES;
    } else {
        return NO;
    }
}


@end
