// 
// FinanceCalculatorViewController.h
// photoshare
// 
// Created by ignis3 on 25/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "NavigationBar.h"
@class ContentManager;
@interface FinanceCalculatorViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UILabel *amountCalculated;
    IBOutlet UILabel *currencySetter;
    IBOutlet UITextField *border1; // for 1st gem
    IBOutlet UITextField *border2; // for 2nd gem
    IBOutlet UITextField *border3; // for 3rd gem
    IBOutlet UILabel *firstGem; 
    IBOutlet UILabel *secondGem;
    IBOutlet UILabel *thirdGem;
    IBOutlet UIButton *firstGemUP_btn;
    IBOutlet UIButton *firstGemDown_btn;
    IBOutlet UIButton *secondGemUP_btn;
    IBOutlet UIButton *secondGemDown_btn;
    IBOutlet UIButton *thirdGemUP_btn;
    IBOutlet UIButton *thirdGemDown_btn;
    IBOutlet UIView *cutomView;
    IBOutlet UIScrollView *scrollView;
    
    ContentManager *objManager;
    NavigationBar *navnBar;
    
}
@property (nonatomic, strong) IBOutlet UIPickerView *myPickerView;
@property (nonatomic, retain) IBOutlet UIView *cutomView;
-(IBAction)segmentedControlIndexChanged;
@end
