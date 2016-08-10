// 
// TermConditionViewController.m
// photoshare
// 
// Created by Dhiru on 28/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "TermConditionViewController.h"
#import "ContentManager.h"

@interface TermConditionViewController ()

@end

@implementation TermConditionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Detect device and load nib
    
    if([[ContentManager sharedManager] isiPad])
    {
        [[NSBundle mainBundle] loadNibNamed:@"TermConditionViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"TermConditionViewController" owner:self options:nil];
    }
    
    objManager = [ContentManager sharedManager];
    // Do any additional setup after loading the view from its nib.
    
  
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"term" ofType:@"html"]isDirectory:NO]]];
    
    [self addCustomNavigationBar];
    [self setUIForIOS6];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUIForIOS6
{
    // Set for IOS 6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        webview.frame=CGRectMake(webview.frame.origin.x, webview.frame.origin.y-20,webview.frame.size.width, webview.frame.size.height+90);
        headingLabel.frame=CGRectMake(headingLabel.frame.origin.x, headingLabel.frame.origin.y-20,headingLabel.frame.size.width, headingLabel.frame.size.height);
    }
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    // Add custom navigation back button
    
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


@end
