// 
// ShareWithUserViewController.m
// photoshare
// 
// Created by ignis2 on 10/02/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "ShareWithUserViewController.h"
#import "NavigationBar.h"
#import "SVProgressHUD.h"

@interface ShareWithUserViewController ()

@end

@implementation ShareWithUserViewController
{
    NavigationBar *navnBar;
}
@synthesize isEditFolder,isWriteUser,collectionId,collectionOwnerId, collectionUserDetails;

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
        [[NSBundle mainBundle] loadNibNamed:@"ShareWithUserViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"ShareWithUserViewController" owner:self options:nil];
    }
    
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    
     userid=[manager getData:@"user_id"];
    [self addCustomNavigationBar];
    [self setUIForIOS6];
    
    sharingUserListCollView.layer.borderColor=[UIColor darkGrayColor].CGColor;
    sharingUserListCollView.layer.borderWidth=1;
    
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    float btnBorderWidth=2;
    float btnCornerRadius=8;
    saveBtn.layer.cornerRadius=btnCornerRadius;
    saveBtn.layer.borderWidth=btnBorderWidth;
    saveBtn.layer.borderColor=btnBorderColor.CGColor;
    
   
    // User Search Table
    if(searchViewTable == nil)
    {
        searchViewTable = [[UITableView alloc] initWithFrame:CGRectMake(shareSearchView.frame.origin.x-5, shareSearchView.frame.origin.y+shareSearchView.frame.size.height, shareSearchView.frame.size.width, 180.0f) style:UITableViewStylePlain];
        
    }
    searchViewTable.delegate = self;
    searchViewTable.dataSource = self;
    searchViewTable.layer.borderColor = [UIColor grayColor].CGColor;
    searchViewTable.layer.borderWidth = 1.0f;
    
    searchViewTable.autoresizingMask= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [scrollView addSubview:searchViewTable];
    [searchViewTable setHidden:TRUE];
    [searchViewTable reloadData];
    
    searchUserListResult=[[NSMutableArray alloc] init];
    searchUserIdResult=[[NSMutableArray alloc] init];
    searchUserRealNameResult = [[NSMutableArray alloc] init];
    
    sharingUserNameArray=[[NSMutableArray alloc] init];
    sharingUserIdArray=[[NSMutableArray alloc] init];
    
    // Register Cell for collectionView
    [sharingUserListCollView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CVCell"];
    NSLog(@"Is edit %d",self.isEditFolder);
    
    shareSearchView.hidden=NO;
    saveBtn.hidden=NO;
    sharingUserListCollView.userInteractionEnabled=YES;
    
        // Check for the Edit Folder option
        if(self.isEditFolder)
        {
            // If the shared folder
            if(self.collectionOwnerId.integerValue!=userid.integerValue)
            {
                shareSearchView.hidden=YES;
                saveBtn.hidden=YES;
                sharingUserListCollView.userInteractionEnabled=NO;
            }
        }
   
    // Check the type of sharing pemission "Write Permission" or "Read Permission"
    if(self.isWriteUser)
    {
        [self getWriteSharingUserList];
    }
    else
    {
        [self getReadSharingUserList];
    }
    
    // Add TapGesture on View For Dismiss KeyBoard
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self checkOrientation];
    
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    manager = [ContentManager sharedManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * For IOS6
 */
-(void)setUIForIOS6
{
    
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        [[searchBarForUserSearch.subviews objectAtIndex:0] removeFromSuperview];
        scrollView.frame=CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height+60);
    }
}

/**
 *  Handle Tap Gesture
 */
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}


#pragma mark - UISearchBar Delegate Methods


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *str=searchBar.text;
    // Check String length is greater than two
    if(str.length>2)
    {
        webservices.delegate=self;
        isSearchUserList=YES;
        
        // Search the user by search text. Call webservices
        NSDictionary *dicData=@{@"user_id":userid,@"target_username":str,@"target_user_emailaddress":@""};
        [webservices call:dicData controller:@"user" method:@"search"];
    }
    else
    {
        // Hide the Search Table
        [searchViewTable setHidden:TRUE];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([searchBar.text isEqualToString:@""]) {
        [searchViewTable setHidden:TRUE];
    }
}

#pragma mark - Device Orientation Methods

-(void)checkOrientation
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,300);
            scrollView.scrollEnabled=NO;
            
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
    
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,300);
            scrollView.scrollEnabled=NO;
            
        }
        else if ([manager isiPad])
        {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,500);
            scrollView.scrollEnabled=NO;
        }
    }
    else {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,270);
            scrollView.scrollEnabled=YES;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,270);
            scrollView.scrollEnabled=YES;
        }
        else if ([manager isiPad])
        {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,500);
            scrollView.scrollEnabled=YES;
        }
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
       [self checkOrientation];
}

/**
 *  Get Write Permission users List from NSUserDefaults
 */
-(void)getWriteSharingUserList
{
    NSArray *writeuseridarray=[[manager getData:@"writeUserId"] componentsSeparatedByString:@","];
    
    if(![[writeuseridarray objectAtIndex:0] isEqualToString:@""])
    {
        for (int i=0; i<writeuseridarray.count; i++) {
            if(![[writeuseridarray objectAtIndex:i] isEqualToString:@"0"])
            {
                NSLog(@"Collection user details %@",self.collectionUserDetails);
                NSDictionary *userDetail=[self.collectionUserDetails objectForKey:[writeuseridarray objectAtIndex:i]];
                if(userDetail==nil)
                {
                    userDetail=[[manager getData:@"temp_user_details"] objectForKey:[writeuseridarray objectAtIndex:i]];
                }
            [sharingUserNameArray addObject:[userDetail objectForKey:@"user_username"]];
            [sharingUserIdArray addObject:[userDetail objectForKey:@"user_id"]];
            }
        }
    }
}

/**
 *  Get Read Permission users List from NSUser defaults
 */
-(void)getReadSharingUserList
{
    NSArray *readuseridarray=[[manager getData:@"readUserId"] componentsSeparatedByString:@","];
    
   if(![[readuseridarray objectAtIndex:0] isEqualToString:@""])
    {
        for (int i=0; i<readuseridarray.count; i++) {
            if(![[readuseridarray objectAtIndex:i] isEqualToString:@"0"])
            {
                NSDictionary *userDetail=[self.collectionUserDetails objectForKey:[readuseridarray objectAtIndex:i]];
                if(userDetail==nil)
                {
                    userDetail=[[manager getData:@"temp_user_details"] objectForKey:[readuseridarray objectAtIndex:i]];
                }
                [sharingUserNameArray addObject:[userDetail objectForKey:@"user_username"]];
                [sharingUserIdArray addObject:[userDetail objectForKey:@"user_id"]];
            }
            
        }
    }
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    [SVProgressHUD dismiss];
    
    // Searchg User Response
    if (isSearchUserList)
    {        
        if(exitCode ==1)
        {
            NSArray *outPutData=[data objectForKey:@"output_data"];
        
            // Remove all objects from Array
            [searchUserIdResult removeAllObjects];
            [searchUserListResult removeAllObjects];
            
            for (int i=0; i<outPutData.count; i++) {
                [[outPutData objectAtIndex:i] objectForKey:@"user_username"];
                NSLog(@"search user List %@", [[outPutData objectAtIndex:i] objectForKey:@"user_username"]);
                
                [searchUserRealNameResult addObject:[[outPutData objectAtIndex:i] objectForKey:@"user_realname"]];
                [searchUserListResult addObject:[[outPutData objectAtIndex:i] objectForKey:@"user_username"]];
                [searchUserIdResult addObject:[[outPutData objectAtIndex:i] objectForKey:@"user_id"]];
            }
            [searchViewTable setHidden:FALSE];
            [searchViewTable reloadData];
        }
        
        // Reset BOOL Value
        isShareForWritingWith=NO;
        isShareForReadingWith=NO;
        isSearchUserList=NO;
    }
}

#pragma mark - UITableView delegate and dataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(searchUserListResult.count > 0)
        return searchUserListResult.count;
    else
        return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SearchList";
    
    UITableViewCell *cell = [searchViewTable dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [searchUserRealNameResult objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [searchUserListResult objectAtIndex:indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    searchBarForUserSearch.text=[searchUserListResult objectAtIndex:indexPath.row];
    selectedUserId=[searchUserIdResult objectAtIndex:indexPath.row];
    selecteduserName=[searchUserListResult objectAtIndex:indexPath.row];
    [searchViewTable setHidden:TRUE];
    
    [searchUserListResult removeAllObjects];
    [searchUserIdResult removeAllObjects];
}

/**
 *  Save Sharing Details
 */
-(IBAction)saveSharingUser:(id)sender
{
    NSString *useridstr;
    if(sharingUserIdArray.count > 0)
    {
        useridstr = [sharingUserIdArray componentsJoinedByString:@","];
    }
    else if(sharingUserIdArray.count == 0)
    {
        useridstr = nil;
    }
    
    NSMutableDictionary *tempuserDetails=[[NSMutableDictionary alloc] init];
    
    for (int i=0; i<sharingUserIdArray.count;i++) {
        [tempuserDetails setObject:[NSDictionary dictionaryWithObjectsAndKeys:[sharingUserIdArray objectAtIndex:i],@"user_id",[sharingUserNameArray objectAtIndex:i],@"user_username", nil] forKey:[sharingUserIdArray objectAtIndex:i]];
    }
    
    [manager storeData:tempuserDetails :@"temp_user_details"];
    // For Permission Type Write
    if(isWriteUser)
    {
        [manager storeData:useridstr :@"writeUserId"];
    }
    else // For Permission Type Read
    {
        [manager storeData:useridstr :@"readUserId"];
    }
      
    [self.navigationController popViewControllerAnimated:NO];
}

/**
 *  Add user in sharing view
 */
-(IBAction)addUserInSharing:(id)sender
{
    if(searchBarForUserSearch.text.length>0)
    {
        if([searchUserListResult containsObject:searchBarForUserSearch.text])
        {
            int index=[searchUserListResult indexOfObject:searchBarForUserSearch.text];
            if(index!=-1)
            {
                selectedUserId=[searchUserIdResult objectAtIndex:index];
                selecteduserName=[searchUserListResult objectAtIndex:index];
            }
        }
        
        if([searchBarForUserSearch.text isEqualToString:selecteduserName])
        {
            if(selectedUserId.integerValue==userid.integerValue)
            {
                [manager showAlert:@"Message" msg:@"You can not share to yourself!" cancelBtnTitle:@"Ok" otherBtn:Nil];
                searchBarForUserSearch.text=@"";
            }
            else
            {
                if([sharingUserIdArray containsObject:selectedUserId])
                {
                [manager showAlert:@"Message" msg:@"Already Share this User" cancelBtnTitle:@"Ok" otherBtn:Nil];
                    searchBarForUserSearch.text=@"";
                }
                else
                {
                    [sharingUserIdArray addObject:selectedUserId];
                    [sharingUserNameArray addObject:selecteduserName];
                    [sharingUserListCollView reloadData];
                    searchBarForUserSearch.text=@"";
                }
            }
        }
        else
        {
            [manager showAlert:@"Message" msg:@"Enter correct User Name" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
    }
    else
    {
        [manager showAlert:@"Message" msg:@"Enter User Name" cancelBtnTitle:@"Ok" otherBtn:Nil];
    }
    
    [searchViewTable setHidden:YES];
}

#pragma mark - UICollectionView DataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return sharingUserNameArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // Remove subviews before adding new subview
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    UILabel *username=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width-10, cell.frame.size.height-5)];
    username.lineBreakMode=NSLineBreakByWordWrapping;
    username.textColor=[UIColor blackColor];
    username.layer.cornerRadius=5;
    username.layer.borderWidth=1;
    username.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    username.textAlignment=NSTextAlignmentCenter;
    username.font=[UIFont fontWithName:@"verdana" size:13];
    username.text=[sharingUserNameArray objectAtIndex:indexPath.row];
    
    
     [cell.contentView addSubview:username];

    // For Edit Folder Option
    if(self.isEditFolder)
    {
        // Cross Button For Remove User
        if(self.collectionOwnerId.integerValue==userid.integerValue)
        {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width-15, 0, 15, 15)];
            btn.tag=indexPath.row;
            [btn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(removeShareUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
        }
    }
    // For Add New Folder option
    else
    {
        // Cross Button to remove User
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width-15, 0, 15, 15)];
        btn.tag=indexPath.row;
        [btn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(removeShareUser:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
    }
    return cell;
}

/**
 *  Remove the user if cross button  click
 */
-(void)removeShareUser :(id)sender
{
    UIButton *btn=(UIButton *)sender;
   
    @try {
        
        // Remove From Array
        [sharingUserNameArray removeObjectAtIndex:btn.tag];
        [sharingUserIdArray removeObjectAtIndex:btn.tag];
        [sharingUserListCollView reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"Execption is %@",exception.description);
    }
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    UIButton *button =[navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    CGFloat titleY;
    CGFloat subtitleY;
    CGFloat subtitleWidth;
    CGFloat subFont;
    
    // Set navbar attributes accordng to device
    
    if([manager isiPad])
    {
        titleY=30;
        subtitleY=30;
        subFont=18;
        subtitleWidth=130;
    }
    else
    {
        titleY=8;
        subtitleY=16;
        subFont=9;
        subtitleWidth=110;
    }
    
    // Add custom titles for the Navbar
    
    UILabel *navTitle = [navnBar navBarTitleLabel:@"Share with User"];
    navTitle.backgroundColor=[UIColor clearColor];
    CGRect frame=navTitle.frame;
    CGRect backFrame=button.frame;
    backFrame.origin.y=backFrame.origin.y-titleY;
    button.frame=backFrame;
    frame.origin.y=frame.origin.y-titleY;
    navTitle.frame=frame;
    UILabel *navsubTitle = [navnBar navBarTitleLabel:@"(Search the user, press on the username and then select add +)"];
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
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}


@end
