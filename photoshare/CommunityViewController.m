// 
// CommunityViewController.m
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "CommunityViewController.h"
#import "CollectionViewCell.h"
#import "HomeViewController.h"
#import "AddEditFolderViewController.h"
#import "PhotoGalleryViewController.h"

#import "SVProgressHUD.h"

@interface CommunityViewController ()

@end

@implementation CommunityViewController
@synthesize isInNavigation,updateCollectionDetails;
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
    NSString *nibName;
    
    // Detect device and load nib
    
    if([[ContentManager sharedManager] isiPad])
    {
        [[NSBundle mainBundle] loadNibNamed:@"CommunityViewController_iPad" owner:self options:nil];
        nibName=@"CommunityCollectionCell_iPad";
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"CommunityViewController" owner:self options:nil];
        nibName=@"CommunityCollectionCell";
    }
    [self initializeTheObject];
    [self addCustomNavigationBar];
    [self setUIForIOS6];
    
    
    UINib *nib=[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
    [collectionview registerNib:nib forCellWithReuseIdentifier:@"CVCell"];
    
    
    // Add TapGesture and LongPressGesture on Collection view
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc ]initWithTarget:self action:@selector(tapHandle:)];
    UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
    longPressGesture.minimumPressDuration=0.6;

    [collectionview addGestureRecognizer:tapGesture];
    [collectionview addGestureRecognizer:longPressGesture];   
    
    sharingIdArray=[[NSMutableArray alloc] init];
    collectionArrayWithSharing=[[NSMutableArray alloc] init];
    collectionDefaultArray=[[NSMutableArray alloc] init];
    collectionIdArray=[[NSMutableArray alloc] init];
    collectionNameArray=[[NSMutableArray alloc] init];
    collectionSharedArray=[[NSMutableArray alloc] init];
    collectionSharingArray=[[NSMutableArray alloc] init];
    collectionUserIdArray=[[NSMutableArray alloc] init];
    
    updateCollectionDetails=YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    [self getCollectionInfoFromUserDefault];
    [self getStorageFromServer];
    
    // Show Tabbar Item Selected
    [self.tabBarController setSelectedIndex:3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *  For IOS6
 */
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        collectionview.frame=CGRectMake(collectionview.frame.origin.x, collectionview.frame.origin.y-20, collectionview.frame.size.width, collectionview.frame.size.height+70);
        progressView.frame=CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y+45, progressView.frame.size.width, progressView.frame.size.height);
        diskSpaceTitle.frame=CGRectMake(diskSpaceTitle.frame.origin.x, diskSpaceTitle.frame.origin.y+45, diskSpaceTitle.frame.size.width, diskSpaceTitle.frame.size.height);
    }
}

-(void)initializeTheObject
{
    searchController=[[SearchPhotoViewController alloc] init];
    manager=[ContentManager sharedManager];
    
    webservices=[[WebserviceController alloc] init];
    dmc=[[DataMapperController alloc] init];
    
    
    userid=[manager getData:@"user_id"];
}

/**
 *  Get Collection Details From NSUser Defaults
 */

-(void)getCollectionInfoFromUserDefault
{
    
    NSMutableArray *collection= [dmc getCollectionDataList];
    
    NSMutableArray *unshared=[[NSMutableArray alloc]init];
    int incu=0;
    NSMutableArray *sharedByOthers=[[NSMutableArray alloc]init];
    int inco=0;
    for(int itr=0;itr<collection.count;itr++)
    {
        @try {
            
            //  Check and Remove Public Collecton From Collections List
            if(![[[collection objectAtIndex:itr] objectForKey:@"collection_name"] isEqualToString:@"Public"]&& ![[[collection objectAtIndex:itr] objectForKey:@"collection_name"] isEqualToString:@"public"])
            {
                
                if([[[collection objectAtIndex:itr] objectForKey:@"collection_shared"] isEqual:@1])
                {
                    [sharedByOthers insertObject:[collection objectAtIndex:itr]atIndex:inco++];
                    
                }
                else
                {
                    [unshared insertObject:[collection objectAtIndex:itr]atIndex:incu++];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Execption is %@",exception.description);
        }
    }
    
    [collectionDefaultArray removeAllObjects];
    [collectionIdArray removeAllObjects];
    [collectionNameArray removeAllObjects];
    [collectionSharedArray removeAllObjects];
    [collectionSharingArray removeAllObjects];
    [collectionUserIdArray removeAllObjects];
    
    // Arranging COLLECTION in Order Unshared then Shared
    
    for (int i=0;i<unshared.count; i++)
    {
        @try {
             
            if(![[[unshared objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"Public"]&& ![[[unshared objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"public"])
            {
                [collectionDefaultArray addObject:[[unshared objectAtIndex:i] objectForKey:@"collection_default"]];
                [collectionIdArray addObject:[[unshared objectAtIndex:i] objectForKey:@"collection_id"]];
                [collectionNameArray addObject:[[unshared objectAtIndex:i] objectForKey:@"collection_name"]];
                [collectionSharedArray addObject:[[unshared objectAtIndex:i] objectForKey:@"collection_shared"]];
                [collectionSharingArray addObject:[[unshared objectAtIndex:i] objectForKey:@"collection_sharing"]];
                [collectionUserIdArray addObject:[[unshared objectAtIndex:i] objectForKey:@"collection_user_id"]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Execption is %@",exception.description);
        }
    }
    
    for (int i=0;i<sharedByOthers.count; i++)
    {
        @try {
            
            if(![[[sharedByOthers objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"Public"]&& ![[[sharedByOthers objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"public"])
            {
                [collectionDefaultArray addObject:[[sharedByOthers objectAtIndex:i] objectForKey:@"collection_default"]];
                [collectionIdArray addObject:[[sharedByOthers objectAtIndex:i] objectForKey:@"collection_id"]];
                [collectionNameArray addObject:[[sharedByOthers objectAtIndex:i] objectForKey:@"collection_name"]];
                [collectionSharedArray addObject:[[sharedByOthers objectAtIndex:i] objectForKey:@"collection_shared"]];
                [collectionSharingArray addObject:[[sharedByOthers objectAtIndex:i] objectForKey:@"collection_sharing"]];
                [collectionUserIdArray addObject:[[sharedByOthers objectAtIndex:i] objectForKey:@"collection_user_id"]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Execption is %@",exception.description);
        }
    }
    [collectionview reloadData];
}

/**
 *  Get Storage From Server
 */

-(void)getStorageFromServer
{
    @try {
        if(updateCollectionDetails)
        {
            [SVProgressHUD showWithStatus:@"Downloading" maskType:SVProgressHUDMaskTypeBlack];
            
        }
        isGetStorage=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid};
        [webservices call:dicData controller:@"storage" method:@"get"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
}

/**
 *  Get Sharing Collection users id From Server
 */

-(void)getSharingusersId
{
    @try {
        
        isGetSharingUserId=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid};
        [webservices call:dicData controller:@"collection" method:@"sharing"];
    }
    @catch (NSException *exception) {
        
    }
}

/**
 *  Get Own Collection List
 */

-(void)fetchOwnCollectionInfoFromServer
{
    @try {
        isGetTheOwnCollectionListData=YES;
            webservices.delegate=self;
            NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":userid};
            [webservices call:dicData controller:@"collection" method:@"getlist"];
        
    }
    @catch (NSException *exception) {
        
    }
}

/**
 *  Get Sharing Collection List
 */

-(void)fetchSharingCollectionInfoFromServer
{
    @try {
        if(sharingIdArray.count>0)
        {
            countSharing=0;
            for (int i=0; i<sharingIdArray.count; i++) {
                isGetTheSharingCollectionListData=YES;
                webservices.delegate=self;
                NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":[sharingIdArray objectAtIndex:i]};
                [webservices call:dicData controller:@"collection" method:@"getlist"];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}


#pragma mark - WebService Delegate Methods

-(void) webserviceCallback:(NSDictionary *)data
{   
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    
    // Storage Response
    if(isGetStorage)
    {
        if(exitCode.integerValue==1)
        {
            @try {
                NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
                
                NSDictionary *dic=[outPutData objectAtIndex:0];
                NSNumber *availableStorage=[dic objectForKey:@"storage_available"];
                NSNumber *usedStorage=[dic objectForKey:@"storage_used"];
                if(availableStorage==(id)NULL)
                {
                    availableStorage=@0;
                }
                if(usedStorage==(id)NULL)
                {
                    usedStorage=@0;
                }
                @try {
                    if(usedStorage.integerValue==0)
                    {
                        
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"Exception is %@",exception.description);
                    usedStorage=@0;
                }
                
                float availableSpaceInMB=(float)([availableStorage doubleValue]/(double)(1024*1024)) ;
                float usedSpaceInMB=(float)([usedStorage doubleValue]/(double)(1024*1024));
                
                // Sets the disk space percentage
                
                float progressPercent=(float)(usedSpaceInMB/availableSpaceInMB);
                NSString *diskTitle=[NSString stringWithFormat:@"Disk spaced used (%.2f%@)",(progressPercent*100),@"%"];
                diskSpaceTitle.text=diskTitle;
                progressView.progress=progressPercent;
                
            }
            @catch (NSException *exception) {
                
            }
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        isGetStorage=NO;
        if (updateCollectionDetails)
        {
            // To update collection info in NSUserDefaults
            updateCollectionDetails=NO;
            [self getSharingusersId];
        }
    }
    // Sharing collection user-ids response
    else if(isGetSharingUserId)
    {
        if(exitCode.integerValue==1)
        {
            @try {
                NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
                sharingIdArray=[outPutData valueForKey:@"user_id"];
            }
            @catch (NSException *exception) {
                
            }
        }
        isGetSharingUserId=NO;
        [self fetchOwnCollectionInfoFromServer];
        
    }
    // Own collection list response
    else if(isGetTheOwnCollectionListData)
    {
        [collectionArrayWithSharing removeAllObjects];
        if(exitCode.integerValue==1)
        {
            [collectionArrayWithSharing addObjectsFromArray:[data objectForKey:@"output_data"]] ;
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        isGetTheOwnCollectionListData=NO;
        if(sharingIdArray.count>0)
        {
            [self fetchSharingCollectionInfoFromServer];
        }
        else
        {
            [SVProgressHUD dismiss];
            [manager storeData:collectionArrayWithSharing :@"collection_data_list"];
            [self getCollectionInfoFromUserDefault];
        }
    }
    // Sharing collection list response
    else if (isGetTheSharingCollectionListData)
    {
        if(exitCode.integerValue==1)
        {
            [collectionArrayWithSharing addObjectsFromArray:[data objectForKey:@"output_data"]];
            
            NSString *dt=NSStringFromClass([self class]);
            for (int i=0; i<collectionArrayWithSharing.count; i++) {
                NSDictionary *temp = [collectionArrayWithSharing objectAtIndex:i];
                for(int k=i+1; k<collectionArrayWithSharing.count; k++)
                {
                    
                    NSDictionary *temp2 = [collectionArrayWithSharing objectAtIndex:k];
                    if([[temp valueForKey:@"collection_id"] isEqualToString:[temp2 valueForKey:@"collection_id"]])
                    {
                        [collectionArrayWithSharing removeObjectAtIndex:k];
                        dt=[NSString stringWithFormat:@"%@\nMatched index %d & %d",dt,i,k];
                    }
                }
            }NSLog(@"%@",dt);
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        countSharing++;
        
        // Check for all sharing collection list
        if(countSharing==sharingIdArray.count)
        {
            [SVProgressHUD dismiss];
            [manager storeData:collectionArrayWithSharing :@"collection_data_list"];
            [self getCollectionInfoFromUserDefault];
        }
    }
}

#pragma mark - UICollectionView Delegate and DataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{   
    return [collectionNameArray count]+1;
}
-(CollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"CVCell";
    obj_Cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    obj_Cell.folder_imgV.hidden=NO;
    obj_Cell.folder_imgV.layer.masksToBounds=YES;
    obj_Cell.icon_img.layer.masksToBounds=YES;
    @try {
        int index=indexPath.row-1;
        
        // Set Add Folder Icon
        if(indexPath.row==0)
        {
            obj_Cell.folder_imgV.image=[UIImage imageNamed:@"add_folder.png"];
            obj_Cell.icon_img.hidden=YES;
            obj_Cell.folder_name.text=@"Add Folder";
        }
        else
        {
            int shared=[[collectionSharedArray objectAtIndex:index] intValue];

            int colOwnerId=[[collectionUserIdArray objectAtIndex:index] integerValue];
            
            // For own collection
            if(userid.integerValue==colOwnerId)
            {
                
                if(shared==1)
                {
                    obj_Cell.icon_img.hidden=NO;
                    obj_Cell.icon_img.image=[UIImage imageNamed:@"shared-icon3.png"];
                }
                else
                {
                    obj_Cell.icon_img.hidden=YES;
                }
            }
            // For shared collection
            else
            {
                obj_Cell.icon_img.hidden=NO;
                obj_Cell.icon_img.image=[UIImage imageNamed:@"sharedIcon.png"];
            }
            obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
            obj_Cell.folder_name.text=[collectionNameArray objectAtIndex:index];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
        return obj_Cell;
}

#pragma mark - Gesture Handling Methods

/**
 *  Tap gesture handler method
 */

-(void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
        
        if(indexPath.row==0)
        {
            [self addFolder];
        }
        else
        {
            // Opens photo gallery view controller
            @try {
                int index=indexPath.row-1;
                PhotoGalleryViewController *photoGallery=[[PhotoGalleryViewController alloc] init];
                photoGallery.isPublicFolder=NO;
                photoGallery.selectedFolderIndex=index;
                photoGallery.folderName=[collectionNameArray objectAtIndex:index];
                photoGallery.collectionId=[collectionIdArray objectAtIndex:index];
                photoGallery.collectionOwnerId=[collectionUserIdArray objectAtIndex:index];
                [manager storeData:@"NO" :@"istabcamera"];
                
                [self.navigationController pushViewController:photoGallery animated:YES];
            }
            @catch (NSException *exception) {
                NSLog(@"Exception is %@",exception.description);
            }
            
        }
    }
}

/**
 *  Long press gesture handler method
 */

-(void)longPressHandle:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
       
        if(indexPath.row!=0)
        {
            selectedFolderIndex=indexPath.row;
            UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
           
            // Adds a custom menu controller to go to Edit folder option
            
            UIMenuItem *editPhoto = [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(editFolder:)];
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            CGRect menucontrollerFrame;
            if([manager isiPad])
            {
                menucontrollerFrame=CGRectMake(cell.frame.origin.x+50,cell.frame.origin.y+50, 50, 50);
            }
            else
            {
                menucontrollerFrame=CGRectMake(cell.frame.origin.x+15,cell.frame.origin.y+40, 50, 50);
            }
            [menu setMenuItems:[NSArray arrayWithObjects:editPhoto,nil]];
            [menu setTargetRect:menucontrollerFrame inView:cell.superview];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}

/**
 *  Action for UIMenu Controller
 */

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action==@selector(editFolder:))
    {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

/**
 *  Show Add Folder ViewController
 */

-(void)addFolder
{
    AddEditFolderViewController *aec1=[[AddEditFolderViewController alloc] init];
    
    aec1.isAddFolder=YES;
    aec1.isEditFolder=NO;
    [self.navigationController pushViewController:aec1 animated:YES];
   
}

/**
 *  Show Edit Folder ViewController
 */

-(void)editFolder:(id)sender
{
    int index=selectedFolderIndex-1;
    
    @try {
        AddEditFolderViewController *aec=[[AddEditFolderViewController alloc] init];
        
        aec.isAddFolder=NO;
        aec.isEditFolder=YES;
        aec.setFolderName=[collectionNameArray objectAtIndex:index];
        aec.collectionId=[collectionIdArray objectAtIndex:index] ;
        aec.collectionOwnerId=[collectionUserIdArray objectAtIndex:index];
        
        [self.navigationController pushViewController:aec animated:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"Execption is %@",exception.description);
    }
}

#pragma mark - Open SearchViewController

-(void)searchViewOpen
{
    searchController=nil;
    searchController=[[SearchPhotoViewController alloc] init];
    searchController.searchType=@"myfolders";
    [self.navigationController pushViewController:searchController animated:NO];
}


#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    // Setting custom navigation buttons
    
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
   
    UIButton *searchBtn=[navnBar navBarRightButton:@"Search"];
    [searchBtn addTarget:self action:@selector(searchViewOpen) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat titleY;
    CGFloat subtitleY;
    CGFloat subtitleWidth;
    CGFloat subFont;
    if([manager isiPad])
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
    
    // Set properties for custom navigation bar
    
    UILabel *navTitle = [navnBar navBarTitleLabel:@"Your Folders"];
    navTitle.backgroundColor=[UIColor clearColor];
    CGRect frame=navTitle.frame;
    CGRect backFrame=button.frame;
    backFrame.origin.y=backFrame.origin.y-titleY;
    button.frame=backFrame;
    CGRect searchFrame=searchBtn.frame;
    searchFrame.origin.y=searchFrame.origin.y-titleY;
    searchBtn.frame=searchFrame;
    
    frame.origin.y=frame.origin.y-titleY;
    navTitle.frame=frame;
    UILabel *navsubTitle = [navnBar navBarTitleLabel:@"(Press & hold your folders/photos to edit them)"];
    navsubTitle.backgroundColor=[UIColor clearColor];
    frame.origin.y=frame.origin.y+subtitleY;
    frame.origin.x=frame.origin.x-(subtitleWidth/2);
    frame.size.width=frame.size.width+subtitleWidth;
    navsubTitle.frame=frame;
    navsubTitle.font=[UIFont systemFontOfSize:subFont];
    [navnBar addSubview:navTitle];
    [navnBar addSubview:navsubTitle];
    [navnBar addSubview:button];
    [navnBar addSubview:searchBtn];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

-(void)navBackButtonClick{
    
    [self.tabBarController setSelectedIndex:0];
    updateCollectionDetails=YES;
}


@end
