// 
// CollectionViewCell.h
// photoshare
// 
// Created by ignis2 on 24/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell{
    
}

@property (nonatomic, retain)IBOutlet UIImageView *folder_imgV;
@property (nonatomic, retain)IBOutlet UIImageView *icon_img;
@property (nonatomic, retain)IBOutlet UILabel *folder_name;

@end
