// 
// CustomCelliPad.h
// schudio
// 
// Created by ignis2 on 07/01/14.
// Copyright (c) 2014 ignis2. All rights reserved.
// 

#import <UIKit/UIKit.h>

@interface CustomCelliPad : UITableViewCell

@property(nonatomic,retain)IBOutlet UITableViewCell *cells;
@property(nonatomic,retain)IBOutlet UIImageView *imageView;
@property (nonatomic , retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *joinStatus;
@property (nonatomic, retain) IBOutlet UILabel *joinedDate;
@property (nonatomic, retain) IBOutlet UILabel *userAmmount;

@end
