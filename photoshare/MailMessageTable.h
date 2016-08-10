// 
// MailMessageTable.h
// photoshare
// 
// Created by ignis3 on 29/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "NavigationBar.h"
@class ContentManager;
@interface MailMessageTable : UIViewController <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    ContentManager *objManager;
    NavigationBar *navnBar;
    NSMutableArray *checkBoxBtn_Arr;
    
    IBOutlet UIButton *select_deseletBtn;
    IBOutlet UILabel *showTheSelectBtnDisableLbl;
    IBOutlet UISearchBar *searchbar;
}
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableDictionary *contactDictionary;
@property (nonatomic, strong) NSString *filterType;


@end
