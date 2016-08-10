// 
// TwitterTable.h
// photoshare
// 
// Created by ignis3 on 29/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "NavigationBar.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
@class ContentManager;
@interface TwitterTable : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    ContentManager *objManager;
    NavigationBar *navnBar;
    
    NSMutableArray *twiiterListArr;
    BOOL isPopFromSelf;
    NSDictionary *twitterFriendListWithId;
}
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) NSArray *tweetUserName;

// 
@property (nonatomic, strong) NSArray *tweetUserIDsArray;
@property (nonatomic, strong)ACAccountStore *accountStore;
@property (nonatomic, strong)ACAccountType *accountType;
@end
