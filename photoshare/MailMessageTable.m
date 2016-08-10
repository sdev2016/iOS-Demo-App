// 
// TMailMessageTable.m
// photoshare
// 
// Created by ignis3 on 29/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "MailMessageTable.h"
#import "SVProgressHUD.h"
#import "ReferralStageFourVC.h" // for text and mail composition
#import "PhotoShareController.h" // for text and mail composition
#import "ContentManager.h"
#import "SVProgressHUD.h"

@interface MailMessageTable ()

@end

@implementation MailMessageTable
{
    NSMutableArray *contactName;
    NSMutableArray *contactEmail;
    NSMutableArray *contactPhone;
    NSMutableArray *selectedUserArr;
    NSMutableArray *finalSelectArr;
    NSMutableString *StringTweet;
    NSMutableArray *arSelectedRows;
    NSMutableArray *searchSelectedIndexArr;
    NSTimer *timer;
    
    BOOL check;
    BOOL isSearching;
    
    CGRect frame;
    NSMutableArray *filteredList;
    NSMutableArray *filteredContact;
    NSMutableArray *filteredPhone;

}
@synthesize table;
@synthesize contactDictionary,filterType;

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
    objManager = [ContentManager sharedManager];
    // Do any additional setup after loading the view from its nib.
    [self setUIForIOS6];
    check = YES;
    isSearching = NO;
    
    // Initialize
    filteredList = [[NSMutableArray alloc] init];
    filteredContact = [[NSMutableArray alloc] init];
    filteredPhone = [[NSMutableArray alloc] init];
    checkBoxBtn_Arr = [[NSMutableArray alloc] init];
    arSelectedRows = [[NSMutableArray alloc] init];
    contactName = [[NSMutableArray alloc] init];
    contactEmail = [[NSMutableArray alloc] init];
    contactPhone = [[NSMutableArray alloc] init];
    selectedUserArr = [[NSMutableArray alloc] init];
    finalSelectArr = [[NSMutableArray alloc] init];
    searchSelectedIndexArr=[[NSMutableArray alloc] init];
    [SVProgressHUD showWithStatus:@"Loading Contacts" maskType:SVProgressHUDMaskTypeBlack];

    if([filterType isEqualToString:@"Refer Mail"] || [filterType isEqualToString:@"Share Mail"])
    {
        [select_deseletBtn setHidden:NO];
        [showTheSelectBtnDisableLbl setHidden:YES];
        if(contactDictionary.count >0)
        {
            for(int i=0;i<contactDictionary.count;i++)
            {
                NSDictionary *demo = [contactDictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
                
                NSArray *splitEmail = [[demo objectForKey:@"email"] componentsSeparatedByString:@","];
                
                for(int j=0;j<splitEmail.count;j++)
                {
                    NSString *test =[NSString stringWithFormat:@"%@",[splitEmail objectAtIndex:j]];
                    if(test.length != 0)
                    {
                        [contactName addObject:[demo objectForKey:@"name"]];
                        [contactEmail addObject:[splitEmail objectAtIndex:j]];
                    }
                }
            }
        }
    }
    else if([filterType isEqualToString:@"Refer Text"] || [filterType isEqualToString:@"Share Text"])
    {
        [select_deseletBtn setHidden:YES];
        [showTheSelectBtnDisableLbl setHidden:NO];
        if(contactDictionary.count >0)
        {
            for(int i=0;i<contactDictionary.count;i++)
            {
                NSDictionary *demo = [contactDictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
                
                
                NSArray *splitPhone = [[demo objectForKey:@"phone"] componentsSeparatedByString:@","];
                
                for(int j=0;j<splitPhone.count;j++)
                {
                    NSString *test =[NSString stringWithFormat:@"%@",[splitPhone objectAtIndex:j]];
                    if(test.length != 0)
                    {
                        [contactName addObject:[demo objectForKey:@"name"]];
                        [contactPhone addObject:[splitPhone objectAtIndex:j]];
                    }
                }
            }
        }
    }
    [SVProgressHUD dismissWithSuccess:@"Contacts Loaded"];
    [SVProgressHUD dismiss];
    [self addCustomNavigationBar];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
    [self detectDeviceOrientation];
}

/**
 *  For IOS6
 */
-(void)setUIForIOS6
{
   
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
    
        searchbar.frame=CGRectMake(searchbar.frame.origin.x, searchbar.frame.origin.y-20,searchbar.frame.size.width, searchbar.frame.size.height);
        select_deseletBtn.frame=CGRectMake(select_deseletBtn.frame.origin.x, select_deseletBtn.frame.origin.y-20,select_deseletBtn.frame.size.width, select_deseletBtn.frame.size.height);
        showTheSelectBtnDisableLbl.frame=CGRectMake(showTheSelectBtnDisableLbl.frame.origin.x, showTheSelectBtnDisableLbl.frame.origin.y-20,showTheSelectBtnDisableLbl.frame.size.width, showTheSelectBtnDisableLbl.frame.size.height);
        table.frame=CGRectMake(table.frame.origin.x, table.frame.origin.y-20,table.frame.size.width, table.frame.size.height);
    }
    
}

/**
 *  Filter contact for search string
 */
- (void)filterListForSearchText:(NSString *)searchText
{
    [filteredList removeAllObjects];
    [filteredContact removeAllObjects];
    [filteredPhone removeAllObjects];
    
    for (int i=0; i<contactName.count; i++) {
        NSString *title=[contactName objectAtIndex:i];
        NSRange nameRange = [title rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (nameRange.location != NSNotFound) {
            [filteredList addObject:title];
            if([filterType isEqualToString:@"Refer Mail"] || [filterType isEqualToString:@"Share Mail"])
            {
                [filteredContact addObject:[contactEmail objectAtIndex:i]];
            }
            else if([filterType isEqualToString:@"Refer Text"] || [filterType isEqualToString:@"Share Text"])
            {
                [filteredPhone addObject:[contactPhone objectAtIndex:i]];
            }
        }

    }
}

#pragma mark - UITableView delegate and datasource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching)
        return [filteredList count];
    else
    {
        if([contactName count] == 0)
            return 0;
        else
            return contactName.count;
    }
}

/**
 *  This method is used to select contacts where we will be sending invitaion
 */

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identitifier = @"demoTableViewIdentifier";
    UITableViewCell * cell = [self.table dequeueReusableCellWithIdentifier:identitifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identitifier];
        UIImageView *checkBoxImg=[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width-40,2, 20,20)];
        checkBoxImg.tag=1001;
        checkBoxImg.layer.masksToBounds=YES;
        checkBoxImg.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
        checkBoxImg.layer.borderWidth=1;
        checkBoxImg.layer.borderColor=BTN_BORDER_COLOR.CGColor;
        [cell.contentView addSubview:checkBoxImg];
    }
    cell.textLabel.frame=CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width-45, cell.textLabel.frame.size.height);
    cell.detailTextLabel.frame=CGRectMake(cell.detailTextLabel.frame.origin.x, cell.detailTextLabel.frame.origin.y, cell.detailTextLabel.frame.size.width-50, cell.detailTextLabel.frame.size.height);
    // For E-mail
    if([filterType isEqualToString:@"Refer Mail"] || [filterType isEqualToString:@"Share Mail"])
    {
        NSString *title;
        NSString *contacts;
        if (isSearching && [filteredList count]) {
            
            // If the user is searching, use the list in our filteredList array.
            title = [filteredList objectAtIndex:indexPath.row];
            contacts = [filteredContact objectAtIndex:indexPath.row];
            
        } else {
            title = [contactName objectAtIndex:indexPath.row];
            contacts = [contactEmail objectAtIndex:indexPath.row];
        }
        if([title isEqualToString:@"(null)"])
        {
            title=@"Unknown";
        }
        if(contacts==NULL)
        {
            contacts=@"";
        }
        cell.textLabel.text = title;
        cell.detailTextLabel.text = contacts;
    }
    // For SMS
    else if([filterType isEqualToString:@"Refer Text"] || [filterType isEqualToString:@"Share Text"])
    {
        NSString *title;
        NSString *contacts;
        if (isSearching && [filteredList count]) {
            // If the user is searching, use the list in our filteredList array.
            title = [filteredList objectAtIndex:indexPath.row];
            contacts = [filteredPhone objectAtIndex:indexPath.row];
            
        } else {
            title = [contactName objectAtIndex:indexPath.row];
            contacts = [contactPhone objectAtIndex:indexPath.row];
        }
        if([title isEqualToString:@" (null)"])
        {
            title=@"Unknown";
        }
        if(contacts==NULL)
        {
            contacts=@"";
        }
        cell.textLabel.text = title;
        cell.detailTextLabel.text = contacts;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
   
    UIImageView *checkBoxImg=(UIImageView *)[cell viewWithTag:1001];
    
    // If searching contact list
    if(isSearching)
    {
        @try {
            
            if([filterType isEqualToString:@"Refer Mail"] || [filterType isEqualToString:@"Share Mail"])
            {
                if([selectedUserArr containsObject:[filteredContact objectAtIndex:indexPath.row]])
                {
                    checkBoxImg.image=[UIImage imageNamed:@"iconr3.png"];
                }
                else
                {
                    checkBoxImg.image=[UIImage imageNamed:@"iconr3_uncheck.png"];
                }
            }
            else
            {
                if([selectedUserArr containsObject:[filteredPhone objectAtIndex:indexPath.row]])
                {
                    checkBoxImg.image=[UIImage imageNamed:@"iconr3.png"];
                }
                else
                {
                    checkBoxImg.image=[UIImage imageNamed:@"iconr3_uncheck.png"];
                }
            }
        }
        @catch (NSException *exception) {
            
        }
    }
    else
    {
        if([arSelectedRows containsObject:[NSNumber numberWithInt:[indexPath row]]])
        {
            checkBoxImg.image=[UIImage imageNamed:@"iconr3.png"];
        }
        else
        {
            checkBoxImg.image=[UIImage imageNamed:@"iconr3_uncheck.png"];
        }
    }
    return cell;
}
/**
 *  Implements functionaly to not let select above
 *  maximum limit and to ensure non duplicacy of selection
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL isSelect;
    UIImageView *imgView=(UIImageView *)[cell viewWithTag:1001];
    
    // For Contact Searching
    if(isSearching)
    {
        if(![searchSelectedIndexArr containsObject:[NSNumber numberWithInt:indexPath.row]])
        {
            isSelect=YES;
        }
        else
        {
            isSelect=NO;
        }
    }
    else
    {
        if(![arSelectedRows containsObject:[NSNumber numberWithInt:indexPath.row]])
        {
            isSelect=YES;
        }
        else
        {
            isSelect=NO;
        }
    }
    
    
    if([filterType isEqualToString:@"Refer Mail"] || [filterType isEqualToString:@"Share Mail"])
    {
        NSMutableString *tweetString = [[NSMutableString alloc] init];
    
        if(isSelect)
        {
            imgView.image=[UIImage imageNamed:@"iconr3.png"];
            
            NSLog(@"Index path is %d",indexPath.row);
            int index;
            if(isSearching)
            {
               index =[contactEmail indexOfObject:[filteredContact objectAtIndex:indexPath.row]];
                [selectedUserArr addObject:[filteredContact objectAtIndex:indexPath.row]];
                [searchSelectedIndexArr addObject:[NSNumber numberWithInt:indexPath.row]];
                
            }
            else
            {
                index = indexPath.row;
                [selectedUserArr addObject:[contactEmail objectAtIndex:indexPath.row]];
            }
            @try {
                // Remove duplicates from array
                NSMutableArray *uniqueArray = [NSMutableArray array];
                
                [uniqueArray addObjectsFromArray:[[NSSet setWithArray:selectedUserArr] allObjects]];
                selectedUserArr=[uniqueArray mutableCopy];
            }
            @catch (NSException *exception) {
                
            }
            for(int i=0;i<[selectedUserArr count];i++)
            {
                if([tweetString length])
                {
                    [tweetString appendString:@", "];
                }
                [tweetString appendString:[selectedUserArr objectAtIndex:i]];
            }
            finalSelectArr = [NSMutableArray arrayWithArray:selectedUserArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            [arSelectedRows addObject:[NSNumber numberWithInt:index]];
            
        }
        else {
            imgView.image=[UIImage imageNamed:@"iconr3_uncheck.png"];
           
            int index=indexPath.row;
            tweetString = [NSMutableString stringWithString:@""];
            [finalSelectArr removeAllObjects];
            for(NSString *match in selectedUserArr)
            {
                NSLog(@"%@",match);
                if(isSearching)
                {
                    if([match isEqualToString:[filteredContact objectAtIndex:indexPath.row]])
                    {
                        index=[contactEmail indexOfObject:match];
                        NSLog(@"Match Found");
                    }
                    else
                    {
                        if([tweetString length])
                        {
                            [tweetString appendString:@", "];
                        }
                        [tweetString appendFormat:@"%@",match];
                        [finalSelectArr addObject:match];
                    }
                }
                else
                {
                    if([match isEqualToString:[contactEmail objectAtIndex:indexPath.row]])
                    {
                        NSLog(@"Match Found");
                    }
                    else
                    {
                        if([tweetString length])
                        {
                            [tweetString appendString:@", "];
                        }
                        [tweetString appendFormat:@"%@",match];
                        [finalSelectArr addObject:match];
                    }
                }
            
            }
            [selectedUserArr removeAllObjects];
            selectedUserArr = [NSMutableArray arrayWithArray:finalSelectArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            if(isSearching)
            {
                [searchSelectedIndexArr removeObject:[NSNumber numberWithInt:indexPath.row]];
            }
            [arSelectedRows removeObject:[NSNumber numberWithInt:index]];
        
        }
    }
    else if([filterType isEqualToString:@"Refer Text"] || [filterType isEqualToString:@"Share Text"])
    {
        UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
        NSMutableString *tweetString = [[NSMutableString alloc] init];
        
        if(isSelect)
        {
            imgView.image=[UIImage imageNamed:@"iconr3.png"];
            
            NSLog(@"Index path is %d",indexPath.row);
            int index = 0;
            if(isSearching)
            {
                index =[contactPhone indexOfObject:[filteredPhone objectAtIndex:indexPath.row]];
                [selectedUserArr addObject:[filteredPhone objectAtIndex:indexPath.row]];
                [searchSelectedIndexArr addObject:[NSNumber numberWithInt:indexPath.row]];
            }
            else
            {
                index = indexPath.row;
                [selectedUserArr addObject:[contactPhone objectAtIndex:indexPath.row]];
            }
            @try {
                // Remove Duplicates From Array
                NSMutableArray *uniqueArray = [NSMutableArray array];
                
                [uniqueArray addObjectsFromArray:[[NSSet setWithArray:selectedUserArr] allObjects]];
                selectedUserArr=[uniqueArray mutableCopy];
            }
            @catch (NSException *exception) {
                
            }
            for(int i=0;i<[selectedUserArr count];i++)
            {
                if([tweetString length])
                {
                    [tweetString appendString:@", "];
                }
                [tweetString appendString:[selectedUserArr objectAtIndex:i]];
            }
            finalSelectArr = [NSMutableArray arrayWithArray:selectedUserArr];
            [arSelectedRows addObject:[NSNumber numberWithInt:index]];
            
            // Checks maximum number of selectable contacts
            
            if(arSelectedRows.count > 10)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum limit reached" message:@"You can select only 10 contacts per text." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                [alert show];
                [arSelectedRows removeLastObject];
                cell.accessoryType = UITableViewCellAccessoryNone;
                imgView.image=[UIImage imageNamed:@"iconr3_uncheck.png"];
            }
            else
            {
                StringTweet = [NSMutableString stringWithString:tweetString];
            }
        }
        else {
            imgView.image=[UIImage imageNamed:@"iconr3_uncheck.png"];
           
            int index=indexPath.row;
            tweetString = [NSMutableString stringWithString:@""];
            [finalSelectArr removeAllObjects];
            for(NSString *match in selectedUserArr)
            {
                
                NSLog(@"%@",match);
                if(isSearching)
                {
                    if([match isEqualToString:[filteredPhone objectAtIndex:indexPath.row]])
                    {
                        NSLog(@"Match Found");
                        index=[contactPhone indexOfObject:match];
                    }
                    else
                    {
                        if([tweetString length])
                        {
                            [tweetString appendString:@", "];
                        }
                        [tweetString appendFormat:@"%@",match];
                        [finalSelectArr addObject:match];
                    }
                }
                else
                {
                    if([match isEqualToString:[contactPhone objectAtIndex:indexPath.row]])
                    {
                        NSLog(@"Match Found");
                    }
                    else
                    {
                        if([tweetString length])
                        {
                            [tweetString appendString:@", "];
                        }
                        [tweetString appendFormat:@"%@",match];
                        [finalSelectArr addObject:match];
                    }
                }
                
            }
            [selectedUserArr removeAllObjects];
            selectedUserArr = [NSMutableArray arrayWithArray:finalSelectArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            if(isSearching)
            {
                [searchSelectedIndexArr removeObject:[NSNumber numberWithInt:indexPath.row]];
            }
            [arSelectedRows removeObject:[NSNumber numberWithInt:index]];
        }
    }
    
}

/**
 *  Done Button Click
 */

- (IBAction)doneBtnPressed:(id)sender {
    if([filterType isEqualToString:@"Refer Mail"])
    {
        ReferralStageFourVC *rf = (ReferralStageFourVC *)[self.navigationController.viewControllers objectAtIndex:2];
        rf.referEmailStr = StringTweet;
        rf.referredValue = @"Refer Mail";
        [self.navigationController popToViewController:rf animated:YES];
    }
    else if([filterType isEqualToString:@"Refer Text"])
    {
        ReferralStageFourVC *rf = (ReferralStageFourVC *)[self.navigationController.viewControllers objectAtIndex:2];
        rf.referPhoneStr = StringTweet;
        rf.referredValue = @"Refer Text";
        [self.navigationController popToViewController:rf animated:YES];
    }
    else if([filterType isEqualToString:@"Share Mail"])
    {
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:3];
            psVC.shareEmailStr = StringTweet;
            psVC.shareValue = @"Share Mail";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:2];
            psVC.shareEmailStr = StringTweet;
            psVC.shareValue = @"Share Mail";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:4];
            psVC.shareEmailStr = StringTweet;
            psVC.shareValue = @"Share Mail";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
    }
    else if([filterType isEqualToString:@"Share Text"])
    {
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:3];
            psVC.sharePhoneStr = StringTweet;
            psVC.shareValue = @"Share Text";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:2];
            psVC.sharePhoneStr = StringTweet;
            psVC.shareValue = @"Share Text";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:4];
            psVC.sharePhoneStr = StringTweet;
            psVC.shareValue = @"Share Text";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
    }
}

/**
 *  Select All Contact Button Select
 */
- (IBAction)selectAllbtn:(id)sender {
    
    NSMutableString *tweetString = [[NSMutableString alloc] init];
    
    // For e-mail
    if([filterType isEqualToString:@"Refer Mail"] || [filterType isEqualToString:@"Share Mail"])
    {
        
        // If contact not selected then select all contact
        if(check)
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    UITableViewCell *cell=[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
                    
                    UIImageView *imgView=(UIImageView *)[cell viewWithTag:1001];
                    imgView.image=[UIImage imageNamed:@"iconr3.png"];
                    
                    [arSelectedRows addObject:[NSNumber numberWithInteger:r]];
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendString:[contactEmail objectAtIndex:r]];
                    [selectedUserArr addObject:[contactEmail objectAtIndex:r]];
                }
                StringTweet = [NSMutableString stringWithString:tweetString];
                
            }
            check = NO;
            [select_deseletBtn setTitle:@"Deselect All" forState:UIControlStateNormal];
        }
        // If contact selected then de-select all contact
        else
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    UITableViewCell *cell=[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
                    
                    UIImageView *imgView=(UIImageView *)[cell viewWithTag:1001];
                    imgView.image=[UIImage imageNamed:@"iconr3_uncheck.png"];
                    [arSelectedRows removeObject:[NSNumber numberWithInteger:r]];
                }
            }
            StringTweet = nil;
            check = YES;
            [selectedUserArr removeLastObject];
            [select_deseletBtn setTitle:@"Select All" forState:UIControlStateNormal];
        }
    }
    // For SMS
    else if([filterType isEqualToString:@"Refer Text"] || [filterType isEqualToString:@"Share Text"])
    {
        // If contact not selected then select all contact
        if(check)
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    UITableViewCell *cell=[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
                    
                    UIImageView *imgView=(UIImageView *)[cell viewWithTag:1001];
                    imgView.image=[UIImage imageNamed:@"iconr3.png"];
                    [arSelectedRows addObject:[NSNumber numberWithInteger:r]];
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendString:[contactPhone objectAtIndex:r]];
                    [selectedUserArr addObject:[contactPhone objectAtIndex:r]];
                }
                StringTweet = [NSMutableString stringWithString:tweetString];
            }
            check = NO;
            [select_deseletBtn setTitle:@"Deselect All" forState:UIControlStateNormal];
        }
        else // If contact are selected then de-select all contact
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    UITableViewCell *cell=[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
                    
                    UIImageView *imgView=(UIImageView *)[cell viewWithTag:1001];
                    imgView.image=[UIImage imageNamed:@"iconr3_uncheck.png"];
                    [arSelectedRows removeObject:[NSNumber numberWithInteger:r]];
                }
            }
            StringTweet = nil;
            check = YES;
            [selectedUserArr removeLastObject];
            [select_deseletBtn setTitle:@"Select All" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UISearchBar Controller Delegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    
    // When the user taps the search bar, this means that the controller will begin searching.
    isSearching = YES;
    [searchSelectedIndexArr removeAllObjects];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {

    [searchSelectedIndexArr removeAllObjects];
    isSearching = NO;

}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchSelectedIndexArr removeAllObjects];
    isSearching=NO;
    [table reloadData];
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterListForSearchText:searchString]; // The method we made in step 7
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterListForSearchText:[self.searchDisplayController.searchBar text]]; // The method we made in step 7
    
    return YES;
}


#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    // Add custom navigation buttons on navigation bar
    
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];

    UILabel *navTitle = [navnBar navBarTitleLabel:@"Contacts"];
    
    UIButton *buttonLeft = [navnBar navBarRightButton:@"Done >"];
    [buttonLeft addTarget:self action:@selector(doneBtnPressed:) forControlEvents:UIControlEventTouchDown];
    
    [navnBar addSubview:buttonLeft];
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Device Orientation Methods

-(void)detectDeviceOrientation
{
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
}
-(void)orient:(UIInterfaceOrientation)ott
{
    frame = table.frame;
    
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            frame.size.width = 480;
            table.frame = frame;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            frame.size.width = 568;
            table.frame = frame;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            frame.size.width = 320;
            table.frame = frame;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            frame.size.width = 320;
            table.frame = frame;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            frame.size.width = 768;
            table.frame = frame;
        }
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self orient:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
