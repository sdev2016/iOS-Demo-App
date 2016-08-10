// 
// UploadMultiplePhotoOnServerViewController.m
// photoshare
// 
// Created by ignis2 on 01/05/14.
// Copyright (c) 2014 ignis. All rights reserved.
// 

#import "UploadMultiplePhotoOnServerViewController.h"
#import "AppDelegate.h"
#import "ContentManager.h"
#import "SVProgressHUD.h"

static UploadMultiplePhotoOnServerViewController *multipleUpload=nil;

@interface UploadMultiplePhotoOnServerViewController ()

@end

@implementation UploadMultiplePhotoOnServerViewController
@synthesize delegate;
+(UploadMultiplePhotoOnServerViewController *)sharedMultipleUpload
{
    if(multipleUpload == nil)
    {
        multipleUpload=[[UploadMultiplePhotoOnServerViewController alloc] init];
        
    }
    return multipleUpload;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    manager = [AFHTTPRequestOperationManager manager];
    apiUrl=@"api.staging.123friday.com/v/2";
    
    //  Create frame with custom view
    
    if (self) {
        [self resetVariable];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width/2;
        
        view=[[UIView alloc] initWithFrame:CGRectMake(screenWidth-80, 0,160, 18)];
        statusLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 160, 13)];
        statusLabel.font=[UIFont fontWithName:@"verdana" size:8.5];
        view.backgroundColor=[UIColor clearColor];
        if(IS_OS_7_OR_LATER)
        {
            statusLabel.textColor=[UIColor blackColor];
            view.backgroundColor=[UIColor whiteColor];
            statusLabel.backgroundColor=[UIColor whiteColor];
        }
        else
        {
            statusLabel.textColor=[UIColor whiteColor];
             view.backgroundColor=[UIColor blackColor];
            statusLabel.backgroundColor=[UIColor blackColor];
        }

        view.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        
        statusLabel.textAlignment=NSTextAlignmentCenter;
        statusLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        statusLabel.numberOfLines=0;
        [view addSubview:statusLabel];
    }
    return self;
}


/**
 *Reset Variables
 */

-(void)resetVariable
{
    [self.delegate uploadStatus:YES];
    totalPhoto=0;
    countUploadPhoto=0;
    countUploadTotalPhoto=0;
    [self performSelector:@selector(removeview) withObject:nil afterDelay:5.0f];
    
}

/**
 * Remove Progress View
 */
-(void)removeview
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    statusLabel.text=@"";
    [view removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Show Progress View
 */

-(void)showProgressBar
{
    [UIApplication sharedApplication].statusBarHidden = YES;
    AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    view.layer.zPosition=1001;
    [delgate.window bringSubviewToFront:view];
    [delgate.window.rootViewController.view addSubview:view];
}

/**
 * Uploading photo Process
 */

-(void)uploadingProcess
{
    NSDictionary *postData=[postData1 mutableCopy];
    NSData *imageData=imgData1;
    
    [postData setValue:[NSString stringWithFormat:@"%@",[[ContentManager sharedManager] getData:@"token"]] forKey:@"X-123-Token"];
    
    @try {
        NSDictionary *parameters = postData;
        
        // Making AFHTTPRequestOperationManager POST request to upload multiple photos
        
        [manager.requestSerializer setValue:[[ContentManager sharedManager] getData:@"token"] forHTTPHeaderField:@"X-123-Token"];
        [manager POST:[NSString stringWithFormat:@"http://%@/%@/%@",apiUrl,@"photo",@"store" ] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"photo.png" mimeType:@"image/png"];
            
        }
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Success: %@", responseObject);
                  NSDictionary *dic=(NSDictionary *)responseObject;
                  int exitcode=[[dic objectForKey:@"exit_code"] integerValue];
                  if(exitcode==1)
                  {
                      countUploadPhoto++;
                      statusLabel.text=[NSString stringWithFormat:@"Uploading %d/%d",countUploadPhoto,totalPhoto];
                      NSDictionary *outputData=[dic objectForKey:@"output_data"];
                      ALAsset *asset=[photoArrayColl objectAtIndex:countUploadPhoto-1];
                      
                      CGImageRef iref = asset.defaultRepresentation.fullScreenImage;
                      
                      UIImage *img = nil;
                     
                      img=[UIImage imageWithCGImage:iref scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                      
                      // Set the response for image upload
                      
                      [self.delegate responseForMultiPleImageUpload:img imgid:[outputData objectForKey:@"image_id"] colId:(NSNumber *)colIdT];
                      
                      // Check if all Photos are uploaded

                      if(totalPhoto>countUploadPhoto)
                      {
                          ALAsset *asset=[photoArrayColl objectAtIndex:countUploadPhoto];
                          
                          CGImageRef iref = asset.defaultRepresentation.fullResolutionImage;
                          
                          NSInteger width = CGImageGetWidth(iref);
                          
                          UIImage *img;
                          UIImage *resizeImage;
                          NSData *imgD;
                          
                          // If image width is larger then 1920, scale to 1024
                          
                          if(width >=1920)
                          {
                              img=[UIImage imageWithCGImage:iref scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                              
                              resizeImage = [self imageWithImage:img scaledToWidth:1024.0];
                              
                              imgD=UIImagePNGRepresentation(resizeImage);
                          }
                          else
                          {
                              img=[UIImage imageWithCGImage:iref scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                              
                              imgD=UIImagePNGRepresentation(img);
                          }
                          
                          postData1=[postData copy];
                          imgData1=imgD;
                          
                          dispatch_queue_t myBackgroundQ = dispatch_queue_create("com.romanHouse.backgroundDelay", NULL);
                          dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
                          dispatch_after(delay, myBackgroundQ, ^(void){
                              [self uploadingProcess];
                          });
                          
                      }
                  }
                  else
                  {
                      statusLabel.text=[NSString stringWithFormat:@"%d Photo is failed to upload",totalPhoto-countUploadPhoto];
                       [self resetVariable];
                  }
                  // If all Photos are uploaded then show success message
                  if(countUploadPhoto==totalPhoto)
                  {
                      statusLabel.text=@"Upload Success";
                       [self resetVariable];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", [error localizedDescription]);
                  statusLabel.text=[NSString stringWithFormat:@"%d Photo is failed to upload",totalPhoto-countUploadPhoto];
                   [self resetVariable];
              }];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

/**
 * Uplaoding Multiple Photos
 */

-(void)uploadMultiplePhoto:(NSArray *)photoArray userId:(NSNumber *)userId collectionId:(NSNumber *)colId
{
    // Check if a previous Uploading is in Progress
    
    if(countUploadPhoto==0 && countUploadTotalPhoto==0)
    {
        if(photoArray.count>0)
        {
            @try {
                [self showProgressBar];
               
                totalPhoto=photoArray.count;
                countUploadPhoto=0;
                countUploadTotalPhoto=0;
                photoArrayColl=photoArray;
                userIdT=userId;
                colIdT=colId;
                
                
                ALAsset *asset=[photoArray objectAtIndex:0];
                
                CGImageRef iref = asset.defaultRepresentation.fullResolutionImage;
                
                NSInteger width = CGImageGetWidth(iref);
    
                UIImage *img;
                UIImage *resizeImage;
                NSData *imgD;
                
                // If image width is larger than 1920, then scale to 1024
                
                if(width >=1920)
                {
                    img=[UIImage imageWithCGImage:iref scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                    
                    resizeImage = [self imageWithImage:img scaledToWidth:1024.0];
                    
                    imgD=UIImagePNGRepresentation(resizeImage);
                }
                else
                {
                    img=[UIImage imageWithCGImage:iref scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                    
                    imgD=UIImagePNGRepresentation(img);
                }
                
                NSDictionary *dic = @{@"user_id":userId,@"photo_collections":colId};
                postData1=[dic copy];
                imgData1=imgD;
                 statusLabel.text=[NSString stringWithFormat:@"Uploading %d/%d",countUploadPhoto,totalPhoto];
                [self uploadingProcess];
            }
            @catch (NSException *exception) {
                
            }
            
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Alert !" message:@"Photos Uploading in Progress" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
/**
 * Image scaling mechanism
*/
-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

@end
