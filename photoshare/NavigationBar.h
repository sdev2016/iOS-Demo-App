// 
// NavigationBar.h
// photoshare
// 
// Created by ignis3 on 04/02/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "DataMapperController.h"

@class ContentManager;
@interface NavigationBar : UINavigationBar
{
    UILabel *topBlueLbl;
    UIImageView *logoImg;
    UIView *homeController;
    UIView *totalEarningView;
    UILabel *totalEarningHeading;
    UILabel *totalEarning;
    DataMapperController *dmc;
    ContentManager *objManager;
    
    CGFloat navBarYPos;
    CGFloat navBarHeight;
    // Top Blue Label
    CGFloat topBlueLblHeight;
    CGFloat topBlueLblYpos;
    
    // For Home Logo
    CGFloat homeLogoWidth;
    CGFloat homeLogoHeight;
    CGFloat homeLogoYpos;
    // For Total Earning view
    CGFloat EarningLblYpos;
    CGFloat EarningLblWidth;
    CGFloat EarningLblHeight;
    
    // FonHeight
    CGFloat EarningHeadingFontSize;
    CGFloat EarningFontSize;
}

-(void)loadNav;
 -(void)goToEarningViewController;
-(void)setTheTotalEarning:(NSString *)earners;
-(void)goToHomeViewController;

// Nav Button
/**
 *Set and Return The Navigation Bar Left Button
 */
-(UIButton *)navBarLeftButton :(NSString *)title;
/**
 *Set and Return The Navigation Bar Title Label
 */
-(UILabel *)navBarTitleLabel :(NSString *)title;
/**
 *Set and Return The Navigation Bar Right Button
 */
-(UIButton *)navBarRightButton :(NSString *)title;
@end
