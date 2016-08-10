// 
// PhotoShareController.h
// photoshare
// 
// Created by Dhiru on 22/01/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "WebserviceController.h"
#import "NavigationBar.h"
@class ContentManager;
@interface PhotoShareController : UIViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,WebserviceDelegate, UIActionSheetDelegate>
{
    ContentManager *manager;
    IBOutlet UIImageView *imageView;
    IBOutlet UIView *shareBtnContainerView;
    BOOL fbFilter, twFilter, mailFilter, smsFilter;
    NavigationBar *navnBar;
    NSString *messageStrforMail;
     NSString *toolkitlink;
}

@property (nonatomic, strong) UIImage *sharedImage;
@property (nonatomic, strong) NSArray *sharedImagesArray;
@property (nonatomic, strong) NSArray *otherDetailArray;
@property (nonatomic, strong) NSString *shareEmailStr;
@property (nonatomic, strong) NSString *sharePhoneStr;
@property (nonatomic, strong) NSString *shareValue;

@end

