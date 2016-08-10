// 
// DataMapperController.h
// photoshare
// 
// Created by Dhiru on 29/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "ContentManager.h"

// For Device Version Detect
#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height==568)
#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height==480)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define BTN_FONT_COLOR [UIColor colorWithRed:0.12 green:0.478 blue:1.0 alpha:1]
#define BTN_BORDER_COLOR [UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1]
// For navigation bar
#define NavBtnYPosForiPhone 52.0f
#define NavBtnYPosForiPad 110.0f
#define NavBtnHeightForiPhone 25
#define NavBtnHeightForiPad 50
#define MAIN_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

#define NAVLEFT_BTN_FRAME_IPHONE CGRectMake(10, NavBtnYPosForiPhone, MAIN_SCREEN_WIDTH/4-10, NavBtnHeightForiPhone)
#define NAVTITLE_LABEL_FRAME_IPHONE CGRectMake(MAIN_SCREEN_WIDTH/4, NavBtnYPosForiPhone, MAIN_SCREEN_WIDTH/2, NavBtnHeightForiPhone)
#define NAVRIGHT_BTN_FRAME_IPHONE CGRectMake(MAIN_SCREEN_WIDTH-(MAIN_SCREEN_WIDTH/4)-10, NavBtnYPosForiPhone, MAIN_SCREEN_WIDTH/4, NavBtnHeightForiPhone)
#define NAVLEFT_BTN_FRAME_IPAD CGRectMake(10.0, NavBtnYPosForiPad,MAIN_SCREEN_WIDTH/4-10,NavBtnHeightForiPad)
#define NAVTITLE_LABEL_FRAME_IPAD CGRectMake(MAIN_SCREEN_WIDTH/4, NavBtnYPosForiPad, MAIN_SCREEN_WIDTH/2, NavBtnHeightForiPad)
#define NAVRIGHT_BTN_FRAME_IPAD CGRectMake(MAIN_SCREEN_WIDTH-(MAIN_SCREEN_WIDTH/4)-10, NavBtnYPosForiPad, MAIN_SCREEN_WIDTH/4, NavBtnHeightForiPad)


@interface DataMapperController : UIViewController
{
    ContentManager *objManager;
}

-(void) setUserId:(NSString *)userid ;
-(void) setUserDetails:(NSDictionary *) dic;
-(void) setUserName:(NSString *)username;
-(void) setRememberMe:(NSString *)value;
-(void) setRememberFields:(NSDictionary *)dict;
-(void) sethomeIndex;
-(BOOL) gethomeIndex;
-(void) resetHomeIndex;
-(void)setCollectionDataList :(NSMutableArray *)collectionArray;
-(void)removeAllData;

-(NSMutableArray *)getCollectionDataList;

-(NSString * ) getUserId ;
-(NSDictionary *) getUserDetails ;
-(NSString *)getUserName;
-(NSString *)getRemeberMe;
-(NSDictionary *)getRememberFields;

@end
