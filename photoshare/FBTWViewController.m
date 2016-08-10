// 
// FBTWViewController.m
// photoshare
// 
// Created by ignis3 on 28/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "FBTWViewController.h"
#import "ContentManager.h"

@interface FBTWViewController ()

@end

@implementation FBTWViewController
@synthesize successType,success;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Detect device and load nib
    
    objManager = [ContentManager sharedManager];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"FBTWViewController_iPad" owner:self options:nil];
    }
    if([successType isEqualToString:@"fb"])
    {
        socialType.image = [UIImage imageNamed:@"facebook.png"];
    }
    else if([successType isEqualToString:@"tw"])
    {
        socialType.image = [UIImage imageNamed:@"twitter.png"];
    }
    [self addCustomNavigationBar];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    // Set back button on navigation bar
    
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
   [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}


-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
