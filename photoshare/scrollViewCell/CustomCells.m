// 
// CustomCells.m
// wxe
// 
// Created by ignis3 on 25/12/13.
// Copyright (c) 2013 ignis3. All rights reserved.
// 

#import "CustomCells.h"

@implementation CustomCells
@synthesize mylabel = _mylabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    /**
     *  Customize collection cells according to device
     */
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            _mylabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 250.0f, 80.0f)];
        }
        else
        {
            _mylabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 40.0f)];
        }
        _mylabel.clipsToBounds = YES;
        _mylabel.backgroundColor = [UIColor colorWithRed:0.106 green:0.518 blue:0.776 alpha:1];
        _mylabel.textColor = [UIColor whiteColor];
        _mylabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.mylabel];
    }
    return self;
}

@end
