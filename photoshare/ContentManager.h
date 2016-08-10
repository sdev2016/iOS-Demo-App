// 
// ContentManager.h
// schudio
// 
// Created by ignis3 on 16/01/14.
// Copyright (c) 2014 ignis2. All rights reserved.
// 

#import <Foundation/Foundation.h>

@interface ContentManager:NSObject{

}
@property (nonatomic, strong) NSDictionary *loginDetailsDict;
@property (nonatomic, strong) NSString *weeklyearningStr;

+(ContentManager *)sharedManager;

-(void)storeData:(id)storedObj :(NSString *)storeKey;
-(id)getData:(NSString *)getKey;
-(void)showAlert:(NSString *)alrttittle msg:(NSString *)msg cancelBtnTitle:(NSString *)btnTittle otherBtn:(NSString *)otherBtn;
-(void)removeData :(NSString *)keysString;

-(BOOL)isiPad;
@end