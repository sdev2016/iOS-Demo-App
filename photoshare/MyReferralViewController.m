// 
// MyReferralViewController.m
// photoshare
// 
// Created by ignis3 on 25/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "MyReferralViewController.h"
#import "CustomCell.h"
#import "SVProgressHUD.h"
#import "ContentManager.h"
#import "CustomCelliPad.h"

@interface MyReferralViewController ()
{
    CustomCell *cell;
    CustomCelliPad *cells;
    WebserviceController *webServiceHlpr;
    NSNumber *userID;
    NSMutableArray *userNameArr;
    NSMutableArray *userActiveArr;
    NSMutableArray *userDateArr;
}
@end

@implementation MyReferralViewController
@synthesize tableViews;

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
        [[NSBundle mainBundle] loadNibNamed:@"MyReferralViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"MyReferralViewController" owner:self options:nil];
    }
    
    // Custom initializations
    
    [self addCustomNavigationBar];
    dmc = [[DataMapperController alloc] init];
    ObjManager = [ContentManager sharedManager];
    userID = [NSNumber numberWithInteger:[[dmc getUserId]integerValue]];
  
    userNameArr = [[NSMutableArray alloc] init];
    userActiveArr = [[NSMutableArray alloc] init];
    userDateArr = [[NSMutableArray alloc] init];
    
    [self.navigationItem setTitle:@"My Referrals"];
    webServiceHlpr = [[WebserviceController alloc] init];
    webServiceHlpr.delegate = self;
    
    NSDictionary *dictData = @{@"user_id":userID};
    [webServiceHlpr call:dictData controller:@"user" method:@"getearningsdetails"];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    tableViews.autoresizesSubviews = UIViewAutoresizingFlexibleWidth;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:ObjManager.weeklyearningStr];
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    // Here webservice delegate method populates arrays according to which tableView gets loaded
    
    NSLog(@"%@",data);
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    
    if(exitCode == 0){
        [SVProgressHUD dismissWithError:@"Failed to load data from Server"];
    } else if([data count] == 0){
        [SVProgressHUD dismissWithError:@"Failed to load data from Server"];
    }
    else {
        NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
        NSMutableDictionary *dOne = [outPutData valueForKey:@"user_referrals"];
        NSMutableDictionary *userSubScribeDict = [dOne valueForKey:@"subscribed"];
        
        for(NSDictionary *val in userSubScribeDict)
        {
            NSLog(@"%@",val);
            [userNameArr addObject:[val valueForKey:@"user_realname"]];
            [userDateArr addObject:@""];
            NSString *activeState = [NSString stringWithFormat:@"%@",[val valueForKey:@"user_active"]];
            if([activeState isEqualToString:@"1"])
            {
                [userActiveArr addObject:@"joined"];
            }
        }
        
        [tableViews reloadData];
        if(userNameArr.count == 0)
        {
            [SVProgressHUD dismiss];
            [ObjManager showAlert:@"Message" msg:@"Zero referrals" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            [SVProgressHUD dismissWithSuccess:@"Done"];
        }
    }
}

#pragma mark - UITableView delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(userActiveArr.count == 0)
    {
        return 0;
    }
    else
    {
        return userNameArr.count;
    }
}

/**
 *  This delegate method enlists all successful referals made by user
 */

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CustomCell";
    
    NSString * nib_name= @"CustomCell";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        nib_name = @"CustomCelliPad";
  
    }
    CustomCell *cell_obj = [tableViews dequeueReusableCellWithIdentifier:identifier];
    
    if(cell_obj==nil)
    {
        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:nib_name owner:self options:nil];
        cell_obj=[nib objectAtIndex:0];
    }
    cell_obj.name.text = [userNameArr objectAtIndex:indexPath.row];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        cell_obj.name.font = [UIFont systemFontOfSize:12.0f];
    }
    cell_obj.joinStatus.text = [userActiveArr objectAtIndex:indexPath.row];
    cell_obj.joinedDate.text = [userDateArr objectAtIndex:indexPath.row];
    cell_obj.imageView.image = [UIImage imageNamed:@"icon-person.png"];
    cell_obj.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell_obj;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
         return 130;
     }
    else
    {
        return 65;
    }
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self action:@selector(navBackButtonClick) forControlEvents:UIControlEventTouchDown];
    
    CGFloat titleY;
    CGFloat subtitleY;
    CGFloat subtitleWidth;
    CGFloat subFont;
    
    // Set attributes according to device
    
    if([ObjManager isiPad])
    {
        titleY=20;
        subtitleY=30;
        subFont=18;
        subtitleWidth=100;
    }
    else
    {
        titleY=8;
        subtitleY=16;
        subFont=9;
        subtitleWidth=80;
    }
    
    // Set Customized titles for controller
    
     UILabel *navTitle = [navnBar navBarTitleLabel:@"My Referrals"];
    navTitle.backgroundColor=[UIColor clearColor];
    CGRect frame=navTitle.frame;
    CGRect backFrame=button.frame;
    backFrame.origin.y=backFrame.origin.y-titleY;
    button.frame=backFrame;
    frame.origin.y=frame.origin.y-titleY;
    navTitle.frame=frame;
    UILabel *navsubTitle = [navnBar navBarTitleLabel:@"(Friends signed up directly through you)"];
    navsubTitle.backgroundColor=[UIColor clearColor];
    frame.origin.y=frame.origin.y+subtitleY;
    frame.origin.x=frame.origin.x-(subtitleWidth/2);
    frame.size.width=frame.size.width+subtitleWidth;
    navsubTitle.frame=frame;
    navsubTitle.font=[UIFont systemFontOfSize:subFont];
    [navnBar addSubview:navTitle];
    [navnBar addSubview:navsubTitle];
    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:ObjManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
