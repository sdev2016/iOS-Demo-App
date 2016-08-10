// 
// PhotoShareController.m
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "PhotoShareController.h"
#import "NavigationBar.h"
#import "ContentManager.h"
#import "SVProgressHUD.h"
#import "MailMessageTable.h"

@interface PhotoShareController ()

@end

@implementation PhotoShareController
{
    NSString *userSelectedEmail;
    NSString *userSelectedPhone;
    NSMutableDictionary *firendDictionary;
    NSMutableArray *FBEmailID;
    NSMutableArray *twiiterListArr;
    int totalCount;
    int countVar;
    NSArray *sttt;
    NSString *tweetFail;
    BOOL grant;
    NSNumber *userID;
    WebserviceController *webSwevice;
    NSMutableArray *ImageCollection;
    NSString *messageStr;
    int imageCount;
    int imageLoaded;
    BOOL webServiceStart;
    NSMutableDictionary *contactData;
    NSMutableArray *contactSelectedArray;
    NSMutableArray *contactNoSelectedArray;
    int messagecount;
    int mailSent;
}

@synthesize sharedImage, sharedImagesArray, otherDetailArray;
@synthesize shareEmailStr,sharePhoneStr,shareValue;

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
        [[NSBundle mainBundle] loadNibNamed:@"PhotoShareController_iPad" owner:self options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"PhotoShareController" owner:self options:nil];
    }
    
    // Custom initialization
    
    manager = [ContentManager sharedManager];
    
    [self addCustomNavigationBar];
    [self setUIForIOS6];
    imageView.layer.masksToBounds=YES;
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.image = sharedImage;
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
	grant = NO;
    messagecount =0;
    contactSelectedArray = [[NSMutableArray alloc] init];
    contactNoSelectedArray = [[NSMutableArray alloc] init];
    
    toolkitlink= [NSString stringWithFormat:@"http://my.123friday.com/my123/live/toolkit/1/%@",[manager getData:@"user_username"]];
    
    messageStr= [NSString stringWithFormat:@"I've just joined 123friday. Watch my short video. http://my.123friday.com/my123/live/toolkit/1/%@",[manager getData:@"user_username"]];
    
    messageStrforMail=[NSString stringWithFormat:@"I've just joined 123friday. <a href=http://my.123friday.com/my123/live/toolkit/1/%@>Watch my short video.</a>",[manager getData:@"user_username"]];
    
    ImageCollection = [[NSMutableArray alloc] init];
    
    if(sharedImage== nil || sharedImage == NULL)
    {
        if (sharedImagesArray.count > 0)
        {
            webSwevice = [[WebserviceController alloc] init];
            webSwevice.delegate = self;
            imageCount = sharedImagesArray.count;
            imageLoaded = 0;
            
            [self getImageFromServer:0];
            webServiceStart = YES;
            
        }
        else if(sharedImagesArray.count == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No photo to share" message:@"No photos are there to shared." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
        
            [alert show];
        }
    }
    if(webServiceStart)
    {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Attaching 1 of %d photos",imageCount] maskType:SVProgressHUDMaskTypeBlack];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Custom initialization when view appears

    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    
    // For Mail
    if([shareValue isEqualToString:@"Share Mail"])
    {
        userSelectedEmail = shareEmailStr;
        NSArray *arr = [shareEmailStr componentsSeparatedByString:@","];
        contactSelectedArray = [NSMutableArray arrayWithArray:arr];
        mailFilter = YES;
        NSString *objFirst = [arr objectAtIndex:0];
        if(objFirst.length == 0)
        {
            [manager showAlert:@"No Contact" msg:@"No contact available to mail" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Composing Mail" maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(mailTofun) withObject:self afterDelay:3.0];
        }
        
    }
    
    // For SMS
    else if ([shareValue isEqualToString:@"Share Text"])
    {
        userSelectedPhone = sharePhoneStr;
        NSArray *arr = [sharePhoneStr componentsSeparatedByString:@", "];
        contactNoSelectedArray = [NSMutableArray arrayWithArray:arr];
        smsFilter = YES;
        NSString *objFirst = [arr objectAtIndex:0];
        if(objFirst.length == 0)
        {
            [manager showAlert:@"No Contact" msg:@"No contact available for text" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Composing Message" maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(sendInAppSMS) withObject:self afterDelay:0.0];
        }
    }

}

-(void)setUIForIOS6
{
    // Set view for IOS 6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        imageView.frame=CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y-20, imageView.frame.size.width, imageView.frame.size.height+70);
        shareBtnContainerView.frame=CGRectMake(shareBtnContainerView.frame.origin.x, shareBtnContainerView.frame.origin.y+50, shareBtnContainerView.frame.size.width, shareBtnContainerView.frame.size.height);
    }
    
}

/**
 *  Get Photo From Server
 */
-(void)getImageFromServer:(NSInteger)index
{
    NSDictionary *dicData = @{@"user_id":[otherDetailArray objectAtIndex:0],@"photo_id":[sharedImagesArray objectAtIndex:index],@"get_image":@"1",@"collection_id":[otherDetailArray objectAtIndex:1],@"image_resize":@"500"};
    [webSwevice call:dicData controller:@"photo" method:@"get"];
}

#pragma mark - WebService Delegate Methods

-(void)webserviceCallbackImage:(UIImage *)image
{
    // Attaches images brought from server to post
    
    [ImageCollection addObject:image];
    [SVProgressHUD dismissWithSuccess:@"Attached"];
    imageView.image = image;
    imageLoaded++;
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Attaching %d of %d photos",imageLoaded+1,imageCount] maskType:SVProgressHUDMaskTypeBlack];
    if(imageCount == imageLoaded)
    {
        [SVProgressHUD dismissWithSuccess:@"Photos Attached"];
        webServiceStart = NO;
    }
    else
    {
        [self getImageFromServer:imageLoaded];
    }
}

/**
 *  Filter reference - Action defination
 */
#pragma mark - Action for filters
- (IBAction)fbFilter_Btn:(id)sender {
    fbFilter = YES;
    twFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
    [self postTofacebook];
}

- (IBAction)twFilter_Btn:(id)sender {
    twFilter = YES;
    fbFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
    [self postToTwitter];
}

- (IBAction)emailFilter_Btn:(id)sender {
    mailFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    smsFilter = NO;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Select Email-Id from Contacts", @"Manually input Email", nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)smsFilter_Btn:(id)sender {
    smsFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Select from Contacts", @"Manually enter contact", nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheet delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self ContactSelectorMethod];
            break;
        case 1:
            [self actionsheetCheeker];
            break;
        case 2:
            [actionSheet setHidden:YES];
            NSLog(@"Cancelled");
            break;
    }
}

-(void)actionsheetCheeker
{
    if(mailFilter)
    {
        [self mailTofun];
    }
    else if(smsFilter)
    {
        [self sendInAppSMS];
    }
}

/**
 *  Facebook Post Method
 */
- (void)postTofacebook{
    
    // Uses SLComposeViewController of type facebook to post/share
    
    [SVProgressHUD showWithStatus:@"Fetching Facebook Account" maskType:SVProgressHUDMaskTypeBlack];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        [SVProgressHUD dismissWithSuccess:@"Done"];
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"I've just joined 123friday. Watch my short video."];
        [controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://my.123friday.com/my123/live/toolkit/1/%@",[manager getData:@"user_username"]]]];
        if(sharedImage != NULL || sharedImage != nil)
        {
            [controller addImage:sharedImage];
        }
        if(sharedImagesArray.count > 0)
        {
            for(int i=0;i<sharedImagesArray.count;i++)
            {
                [controller addImage:[ImageCollection objectAtIndex:i]];
            }
        }
        [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    [manager showAlert:@"Post Cancelled" msg:@"Share photo on facebook cancelled." cancelBtnTitle:@"Ok" otherBtn:Nil];
                    [self dismissModals];
                    break;
                case SLComposeViewControllerResultDone:
                    [manager showAlert:@"Post Cancelled" msg:@"Your photo has been shared successfully." cancelBtnTitle:@"Ok" otherBtn:Nil];
                    break;
                    
                default:
                    break;
            }
        }];
        [self presentViewController:controller animated:YES completion:Nil];
    }
    else{
        [SVProgressHUD dismissWithError:@"No Facebook Account Found"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook not Found" message:@"Your Facebook account in not configured. Please Configure your facebook account from settings." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
}

/**
 * Twitter Post Method
 */
- (void)postToTwitter {
    [SVProgressHUD showWithStatus:@"Fetching Twitter Account" maskType:SVProgressHUDMaskTypeBlack];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        [SVProgressHUD dismissWithSuccess:@"Done"];
        
        SLComposeViewController *tweetsheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetsheet setInitialText:@"I've just joined 123friday. Watch my short video."];
        [tweetsheet addURL:[NSURL URLWithString:toolkitlink]];
        
        if(sharedImage != NULL || sharedImage != nil)
        {
            [tweetsheet addImage:sharedImage];
        }
        if(sharedImagesArray.count > 0)
        {
            for(int j=0;j<sharedImagesArray.count;j++)
            {
                [tweetsheet addImage:[ImageCollection objectAtIndex:j]];
            }
        }
        [tweetsheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    [manager showAlert:@"Tweet Cancelled" msg:@"Share photo on Twitter cancelled." cancelBtnTitle:@"Ok" otherBtn:Nil];
                    [self dismissModals];
                    break;
                case SLComposeViewControllerResultDone:
                    [manager showAlert:@"Tweet Succuessfully" msg:@"Your photo has been shared successfully." cancelBtnTitle:@"Ok" otherBtn:Nil];
                    break;
                default:
                    break;
            }
        }];
        [self presentViewController:tweetsheet animated:YES completion:Nil];
    }
    else
    {
        [SVProgressHUD dismissWithError:@"No Twitter Account Found"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter not Found" message:@"Your Twitter account is not configured. Please Configure your twitter account from settings." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
}

/**
 *  Send Email
 */

-(void)mailTofun {
    
    [SVProgressHUD dismissWithSuccess:@"Composed"];
    
    shareValue = @"";
    
    // Email subject
    
    NSString *emailTitle = @" ";
    
    /**
     *  Email content
     *  Change the message body to HTML
     */
    NSString *messageBody = [NSString stringWithFormat:@"%@",messageStrforMail];
    
    // "TO" address
    NSArray *toRecipents = [NSArray arrayWithArray:contactSelectedArray];
    
    MFMailComposeViewController *mfMail = [[MFMailComposeViewController alloc] init];
    mfMail.mailComposeDelegate = self;
    
    if(sharedImagesArray.count>0)
    {
        for(int k=0;k<sharedImagesArray.count;k++)
        {
            NSData *data = UIImagePNGRepresentation([ImageCollection objectAtIndex:k]);
            [mfMail addAttachmentData:data mimeType:@"image/png" fileName:[NSString stringWithFormat:@"Photo%d",k]];
        }
    }
    else
    {
        NSData *data = UIImagePNGRepresentation(sharedImage);
        [mfMail addAttachmentData:data mimeType:@"image/png" fileName:@""];
    }
    
    [mfMail setSubject:emailTitle];
    [mfMail setMessageBody:messageBody isHTML:YES];
    
    if(toRecipents.count>0)
    {
        [mfMail setToRecipients:[NSArray arrayWithObject:[toRecipents objectAtIndex:0]]];
        NSMutableArray *torec=[toRecipents mutableCopy];
        if(torec.count>1)
        {
            [torec removeObjectAtIndex:0];
            [mfMail setBccRecipients:torec];
        }
    }
    
    // Present MailViewController on screen
    
    [[self navigationController] presentViewController:mfMail animated:YES completion:nil];
    
}

#pragma mark - MFMailComposeViewController delegate Method

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your photo has been shared successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [manager showAlert:@"Cancelled" msg:@"Mail cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactSelectedArray removeAllObjects];
            break;
        case MFMailComposeResultSaved:
            [manager showAlert:@"Saved" msg:@"You mail is saved in draft" cancelBtnTitle:@"Ok" otherBtn:nil];
            break;
            [contactSelectedArray removeAllObjects];
        case MFMailComposeResultSent:
            [alert show];
            [contactSelectedArray removeAllObjects];
            [self sendToServer];
            break;
        case MFMailComposeResultFailed:
            [manager showAlert:@"Mail sent failure" msg:[error localizedDescription] cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactSelectedArray removeAllObjects];
            break;
        default:
            break;
    }
    
    
    [self dismissModals];
}

/**
 *  Send sms
 */
-(void)sendInAppSMS
{
    [SVProgressHUD dismissWithSuccess:@"Composed"];
    shareValue = @"";
    
	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = messageStr;
        
		controller.recipients = [NSArray arrayWithArray:contactNoSelectedArray];
        
        if (sharedImagesArray.count > 0) {
            for(int l=0;l<sharedImagesArray.count;l++)
            {
                NSData *data = UIImagePNGRepresentation([ImageCollection objectAtIndex:l]);
                [controller addAttachmentData:data typeIdentifier:(NSString *)kUTTypePNG filename:[NSString stringWithFormat:@"image%d.png",l]];
            }
        }
        else
        {
            NSData *data = UIImagePNGRepresentation(sharedImage);
            [controller addAttachmentData:data typeIdentifier:(NSString *)kUTTypePNG filename:@"image.png"];
		}
        
        controller.messageComposeDelegate = self;
		[[self navigationController] presentViewController:controller animated:NO completion:nil];
	}
}

#pragma mark - MFMessageComposeViewController delegate Method

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // Handles task according to result of message composer
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your photo has been shared successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
	switch (result) {
		case MessageComposeResultCancelled:
			[manager showAlert:@"Cancelled" msg:@"Message Composed Cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactNoSelectedArray removeAllObjects];
			break;
		case MessageComposeResultFailed:
			[manager showAlert:@"Failed" msg:@"Something went wrong!! Please try again" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactNoSelectedArray removeAllObjects];
            
            break;
		case MessageComposeResultSent:
                [alert show];
                [contactNoSelectedArray removeAllObjects];
			break;
		default:
			break;
	}
    
	[self dismissModals];
}

-(void)getEmail:(NSArray *)emails
{
    NSLog(@"%@",emails);
}

#pragma mark - UIAlertView delegate Methods

-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%li",(long)buttonIndex);
    NSLog(@"The %@ button was tapped.", [alert buttonTitleAtIndex:buttonIndex]);
    if(buttonIndex == 1)
    {
        if(mailFilter)
        {
            [self ContactSelectorMethod];
        }
        else if(smsFilter)
        {
            [self ContactSelectorMethod];
        }
    }
}

/**
 *  Contact Select Method
 */
-(void)ContactSelectorMethod
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted)
            {
                [self loadContacts];
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        [self loadContacts];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"You have denied to load contact for this app" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
    CFRelease(addressBook);
}

/**
 *  Load Contacts From ABAddressBookRef
 */

-(void)loadContacts
{
    CFErrorRef error = NULL;
    
    contactData = [[NSMutableDictionary alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    // Load contacts having phone number and email
    
    if (addressBook != (__bridge ABAddressBookRef)((id)[NSNull null]))
    {
        NSLog(@"Succesful.");
        
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            NSString *firstName = (__bridge_transfer NSString
                                   *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString
                                   *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            if(firstName.length == 0)
            {
                firstName = @"";
            }
            else if(lastName.length == 0)
            {
                lastName = @"";
            }
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",
                                  firstName, lastName];
            if(fullName.length<=1)
            {
                fullName=@"";
            }
            NSLog(@"Full Name: %@",fullName);
            
            NSString *concatStr = @"";
            NSString *concatStr2 = @"";
            
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            NSUInteger j = 0;
            for (j = 0; j < ABMultiValueGetCount(emails); j++)
            {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                if(concatStr.length == 0)
                {
                    concatStr = email;
                }
                else
                {
                    concatStr = [NSString stringWithFormat:@"%@,%@",concatStr,email];
                }
            }
            
            ABMutableMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSUInteger k = 0;
            for(k = 0;k< ABMultiValueGetCount(phones); k++)
            {
                NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, k);
                if(concatStr2.length == 0)
                {
                    concatStr2 = phone;
                }
                else
                {
                    concatStr2 = [NSString stringWithFormat:@"%@ , %@",concatStr2,phone];
                }
            }
            CFRelease(emails);
            CFRelease(phones);
            
            NSDictionary *dict = @{@"name":fullName,@"email":concatStr,@"phone":concatStr2};
            
            [contactData setObject:dict forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    CFRelease(addressBook);
    
    // Forwarding to controller
    
    if(mailFilter)
    {
        MailMessageTable *mmVC;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable_iPad" bundle:nil];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable" bundle:nil];
        }
        mmVC.contactDictionary = contactData;
        mmVC.filterType = @"Share Mail";
        
        [self.navigationController pushViewController:mmVC animated:YES];
    }
    else if (smsFilter)
    {
        MailMessageTable *mmVC;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable_iPad" bundle:nil];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable" bundle:nil];
        }
        mmVC.contactDictionary = contactData;
        mmVC.filterType = @"Share Text";
        
        [self.navigationController pushViewController:mmVC animated:YES];
    }
}

/**
 *  Dismiss modals
 */
-(void)dismissModals
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Add Custom Navigation Bar

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    UILabel *photoTitleLBL=[navnBar navBarTitleLabel:@"Share Your Photo"];    
    
    [navnBar addSubview:photoTitleLBL];
    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];

}
-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

/**
 *  Send Mail Details to Server
 */
-(void)sendToServer
{
    if(userSelectedEmail.length != 0)
    {
        webSwevice = [[WebserviceController alloc] init];
        webSwevice.delegate = self;
        mailSent = 0;
        for(int u=0;u<sharedImagesArray.count;u++)
        {
            NSDictionary *dictData = @{@"user_id":[otherDetailArray objectAtIndex:0],@"email_addresses":userSelectedEmail,@"message_title":@"Join 123 Friday",@"collection_id":[otherDetailArray objectAtIndex:1],@"photo_id":[sharedImagesArray objectAtIndex:u]};
    
            [webSwevice call:dictData controller:@"broadcast" method:@"sendphotomail"];
        }
    }
}

#pragma mark - WebService delegate Method

-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"%@",data);
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
