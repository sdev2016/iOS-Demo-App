// 
// SearchPhotoViewController.m
// photoshare
// 
// Created by ignis2 on 13/02/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "SearchPhotoViewController.h"
#import "SVProgressHUD.h"

@interface SearchPhotoViewController ()

@end

@implementation SearchPhotoViewController
@synthesize searchType;
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
        [[NSBundle mainBundle] loadNibNamed:@"SearchPhotoViewController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"SearchPhotoViewController" owner:self options:nil];
    }
    
    [self setUIForIOS6];
    
    // Set search bar as first responder
    
    [searchBarForPhoto becomeFirstResponder];
    manager =[ContentManager sharedManager];
    webservice =[[WebserviceController alloc] init];
   
    dmc = [[DataMapperController alloc] init];
    userid=[manager getData:@"user_id"];
    
    searchResultArray = [[NSArray alloc] init];
    photoArray =[[NSMutableArray alloc] init];
    photDetailArray =[[NSMutableArray alloc] init];
    
    // Register cell for UICollectionView
    
    [collectionViewForPhoto registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CVCell"];
    
    // Add UITapGestureRecognizer on view For dismiss Keyboard
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [collectionViewForPhoto addGestureRecognizer:tapGesture];
    UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
    longPressGesture.minimumPressDuration=0.6;
    [collectionViewForPhoto addGestureRecognizer:longPressGesture];
    
    [self addCustomNavigationBar];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden=NO;
    [navnBar setTheTotalEarning:manager.weeklyearningStr];

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
        searchBarForPhoto.frame=CGRectMake(searchBarForPhoto.frame.origin.x, searchBarForPhoto.frame.origin.y-20, searchBarForPhoto.frame.size.width, searchBarForPhoto.frame.size.height);
        collectionViewForPhoto.frame=CGRectMake(collectionViewForPhoto.frame.origin.x, collectionViewForPhoto.frame.origin.y-20, collectionViewForPhoto.frame.size.width, collectionViewForPhoto.frame.size.height+65);
    }
}

#pragma mark - UISearchBar Delegate methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    isStartGetPhoto=NO;
    [photoArray removeAllObjects];
    [photDetailArray removeAllObjects];
    
    [collectionViewForPhoto reloadData];
    
    [searchBar resignFirstResponder];
    NSLog(@"search bar text %@",searchBar.text);
    
    searchString=searchBar.text;
    [self searchPhotoOnServer];
    
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchString=searchBar.text;
    
}

/**
 *  Search Photo on Server by SearchBar Text
 */

-(void)searchPhotoOnServer
{
    isSearchPhoto=YES;
    webservice=[[WebserviceController alloc] init];
    webservice.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid,@"search_term":searchString};
    [webservice call:dicData controller:@"photo" method:@"search"];
}

/**
 *  Get Photo From Server By Photo id
 */

-(void)getPhotoFromServer :(int)photoIdIndex imageResize:(NSString *)resize
{
    
    NSDictionary *dicData;
    
    @try {
        if(photDetailArray.count>0)
        {
            isStartGetPhoto=YES;
            NSNumber *colId=[[photDetailArray objectAtIndex:photoIdIndex] objectForKey:@"photo_collection_id"];
            
            NSNumber *photoId=[[photDetailArray objectAtIndex:photoIdIndex] objectForKey:@"photo_id"];
            
            webservice.delegate=self;
            NSNumber *num = [NSNumber numberWithInt:1] ;
            
            dicData = @{@"user_id":userid,@"photo_id":photoId,@"get_image":num,@"collection_id":colId,@"image_resize":resize};
            [webservice call:dicData controller:@"photo" method:@"get"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is found :%@",exception.description);
    }
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Call bAck Data %@",data);

    // Search Photo Response
    if(isSearchPhoto)
    {
        [photDetailArray removeAllObjects];
        [photoArray removeAllObjects];
        
        searchResultArray=[data objectForKey:@"output_data"];
         NSString *publicColId=[manager getData:@"public_collection_id"];
        NSMutableArray *collection=[dmc getCollectionDataList];
        NSMutableArray *colidsArray=[[NSMutableArray alloc] init];
        for (NSDictionary *dic in collection) {
            [colidsArray addObject:[dic objectForKey:@"collection_id"]];
        }
        [colidsArray removeObject:publicColId];

        

        @try {
            // Search For 123Public Folder
                if([self.searchType isEqualToString:@"public"])
                {
                    for (int i=0; i<searchResultArray.count; i++)
                    {
                        @try {
                            NSNumber *searchSharingId=[[searchResultArray objectAtIndex:i] objectForKey:@"collection_sharing"];
                            
                            
                            if(searchSharingId.integerValue==1)
                            {
                                [photDetailArray addObject:[searchResultArray objectAtIndex:i]];
                            }
                        }
                        @catch (NSException *exception) {
                            
                        }
                    }
                }
            // Search For My Folders
                else if ([self.searchType isEqualToString:@"myfolders"])
                {
                    for (int i=0; i<searchResultArray.count; i++)
                    {
                        @try {
                            NSNumber *searchSharingId=[[searchResultArray objectAtIndex:i] objectForKey:@"collection_sharing"];
                            
                            if(searchSharingId.integerValue==0)
                            {
                                [photDetailArray addObject:[searchResultArray objectAtIndex:i]];
                            }
                    }
                    @catch (NSException *exception) {
                        
                    }
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception in search %@",exception.description);
        }
        
        isSearchPhoto=NO;
        // If search photo found
        if(photDetailArray.count>0)
        {
            photoCount=0;
            isGetPhotoFromServer=YES;
            [collectionViewForPhoto reloadData];
            [self getPhotoFromServer:0 imageResize:@"80"];
        }
        else
        {
            [manager showAlert:@"Message" msg:@"No Photo Found" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
    }
}

-(void)webserviceCallbackImage:(UIImage *)image
{
    // Dismiss the progress bar
     [SVProgressHUD dismiss];
    
    // Photo Response
    if(isGetPhotoFromServer)
    {
        // If null image recieved, then set error image
        if(image==NULL)
        {
            image=[UIImage imageNamed:@"error.png"];
        }
        [photoArray addObject:image];
        photoCount++;
        int count=photoArray.count;
        
        NSLog(@"Photo Array Count is : %d",count);
        UIImageView *imgView=(UIImageView *)[collectionViewForPhoto viewWithTag:100+count];
        UIActivityIndicatorView *indicator=(UIActivityIndicatorView *)[collectionViewForPhoto viewWithTag:1100+count];
        [indicator removeFromSuperview];
        imgView.backgroundColor=[UIColor clearColor];
        imgView.contentMode=UIViewContentModeScaleAspectFit;
        imgView.layer.masksToBounds=YES;
        imgView.image=image;
        
        [collectionViewForPhoto reloadData];
        
        if(photoCount<photDetailArray.count)
        {
            isGetPhotoFromServer=YES;

            // If pop is done from this Controller, then stop get photo from server
            if(isPopFromSearchPhoto)
            {
                isPopFromSearchPhoto=NO;
            }
            else
            {
                if(isStartGetPhoto)
                {
                    [self getPhotoFromServer:photoCount imageResize:@"80"];
                }
            }
        }
        else
        {
            isGetPhotoFromServer=NO;
        }
    }
}



#pragma mark - UICollectionView Datasource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return photDetailArray.count ;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    for (UIView *vi in [cell.contentView subviews]) {
        [vi removeFromSuperview];
    }
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height-25)];
    
    int row=indexPath.row;
    
    imgView.tag=101+row;
    imgView.layer.masksToBounds=YES;
    imgView.contentMode=UIViewContentModeScaleAspectFill;
    
    // Add Search Photo Title
    UILabel *photoTitleLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-25, cell.frame.size.width, 25)];
    photoTitleLbl.font=[UIFont fontWithName:@"Verdana" size:10];
    photoTitleLbl.numberOfLines=0;
    photoTitleLbl.textAlignment=NSTextAlignmentCenter;
    photoTitleLbl.text=[[photDetailArray objectAtIndex:row] objectForKey:@"photo_title"];
    
    @try {
        // If photo is recieve then set in UIImageView
        if(photoArray.count>indexPath.row)
        {
            UIImage *image=[photoArray objectAtIndex:indexPath.row];
            imgView.image=image;
        }
        // If photo is not recieved then set loading indicator
        else
        {
            UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityIndicator startAnimating];
            activityIndicator.tag=1101+indexPath.row;
            activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |                                        UIViewAutoresizingFlexibleRightMargin |                                        UIViewAutoresizingFlexibleTopMargin |                                        UIViewAutoresizingFlexibleBottomMargin);
            activityIndicator.center = CGPointMake(CGRectGetWidth(imgView.bounds)/2, CGRectGetHeight(imgView.bounds)/2);
            [cell.contentView addSubview:activityIndicator];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception Name : %@",exception.name);
        NSLog(@"Exception Description : %@",exception.description);
    }
    
    [cell.contentView addSubview:imgView];
    [cell.contentView addSubview:photoTitleLbl];
    return cell;
}

/**
 *  Handle tap gesture method for UICollectionView
 */
-(void)tapHandle :(UITapGestureRecognizer *)gesture
{
    [searchBarForPhoto resignFirstResponder];
    CGPoint p = [gesture locationInView:collectionViewForPhoto];
    
    NSIndexPath *indexPath = [collectionViewForPhoto indexPathForItemAtPoint:p];
    if(indexPath!=Nil)
    {
        // If selected photo index is not recieve then show alert
        if(photoArray.count<=indexPath.row)
        {
            [manager showAlert:@"Message" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            NSNumber *colId=[[photDetailArray objectAtIndex:indexPath.row] objectForKey:@"photo_collection_id"];
            
            NSNumber *photoId=[[photDetailArray objectAtIndex:indexPath.row] objectForKey:@"photo_id"];
            largePhoto=[[LargePhotoViewController alloc] init];
            largePhoto.photoId=photoId;
            largePhoto.colId=colId;
            largePhoto.isFromPhotoViewC=NO;
            [self.navigationController pushViewController:largePhoto animated:YES];
        }
    }
}
/**
 *  Handle Longpress method for UICollectionView
 */
-(void)longPressHandle:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionViewForPhoto];
    
    NSIndexPath *indexPath = [collectionViewForPhoto indexPathForItemAtPoint:p];
    selectedIndex=indexPath.row;
    
     UICollectionViewCell *cell=[collectionViewForPhoto cellForItemAtIndexPath:indexPath];
    CGRect frameForMenuController;
    if([manager isiPad])
    {
        frameForMenuController=CGRectMake(50,40, 50, 50);
    }
    else
    {
        frameForMenuController=CGRectMake(25,40, 50, 50);
    }
    
    // Show report Abuse if search type is Public photo
    if([self.searchType isEqualToString:@"public"])
    {
        UIMenuItem *reportAbuse = [[UIMenuItem alloc] initWithTitle:@"Report Abuse" action:@selector(reportAbuse:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:reportAbuse,nil]];
        [menu setTargetRect:frameForMenuController inView:cell];
        [menu setMenuVisible:YES animated:YES];
        NSLog(@"Read Permission");
    }
}

/**
 *  For UIMenuController check what selected action can it perform
 */
- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(reportAbuse:))
        return YES;
    return NO;
    
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

/**
 *  Send Report Abuse Mail
 */

- (void)reportAbuse:(id)sender {
    
    if([self.searchType isEqualToString:@"public"])
    {
       MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
       controller.mailComposeDelegate = self;
       [controller setToRecipients:[NSArray arrayWithObject:@"reportabuse@123friday.com"]];
       [controller setSubject:@"Report Abuse"];
       
       // Get details of owner, owner's photo and collection
    
       NSNumber *photoOwnerId=[[photDetailArray objectAtIndex:selectedIndex] objectForKey:@"photo_owner_id"];
       NSNumber *photoColId=[[photDetailArray objectAtIndex:selectedIndex] objectForKey:@"photo_collection_id"];
       NSNumber *photoId=[[photDetailArray objectAtIndex:selectedIndex] objectForKey:@"photo_id"];
       
       
       NSString *body=[NSString stringWithFormat:@"Photo Owner Id :%@\nCollection Name:%@\nCollection Id:%@\nPhoto Id:%@",photoOwnerId,@"123Public",photoColId,photoId];
       
       [controller setMessageBody:body isHTML:NO];
       
       if (controller)
       {
           [self presentViewController:controller animated:YES completion:nil];
       }

   }
}

#pragma mark - mailComposeDelegate Method

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
        [manager showAlert:@"Message" msg:@"Mail Successfully sent" cancelBtnTitle:@"Ok" otherBtn:Nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    // Set title and custom back button for navigation bar
    
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    UILabel *titleLabel =[navnBar navBarTitleLabel:@"Search Photos"];
    
    [navnBar addSubview:titleLabel];
    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}
-(void)navBackButtonClick{
    isPopFromSearchPhoto=YES;
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
