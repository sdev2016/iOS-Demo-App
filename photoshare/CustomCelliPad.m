// 
// CustomCelliPad.m
// schudio
// 
// Created by ignis2 on 07/01/14.
// Copyright (c) 2014 ignis2. All rights reserved.
// 

#import "CustomCelliPad.h"

@implementation CustomCelliPad
@synthesize name,joinStatus,joinedDate,userAmmount,imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
