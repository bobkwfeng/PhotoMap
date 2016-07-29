//
//  SecondViewController.m
//  PhotoMapp
//
//  Created by Bob Feng on 7/19/16.
//  Copyright © 2016 Bob Feng. All rights reserved.
//

#import "SecondViewController.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SIPhoto.h"
// This is for the photo information
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import "MapViewController.h"
@import ImageIO;

@interface SecondViewController ()

@end

@implementation SecondViewController

static NSString *la;
static NSString *lo;
static NSString *weather;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // This is for the keyboard can disappear
    self.photoInfor.delegate = self;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    
    // This is to handle the image clicked
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:singleTap];
    
    [self fetchGreeting];
    
    
}



- (IBAction)fetchGreeting;
{
    NSURL *url = [NSURL URLWithString:@"https://www.metaweather.com/api/location/44418/2013/4/27/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             
             //id key = [[greeting allKeys] objectAtIndex:0]; // Assumes 'message' is not empty
             //id object = [greeting objectForKey:key];
             //NSString *x =  [[greeting objectForKey:@"weather_state_name"] stringValue];
              NSEnumerator *enumerator = [greeting objectEnumerator];
              NSDictionary *instance = [enumerator nextObject];
              NSLog(@"%@",[instance objectForKey:@"weather_state_name"]);
             
              weather = [instance objectForKey:@"weather_state_name"];
             //NSString *y = [greeting objectForKey:@"content"];
             //NSLog(x);
             //NSLog(y);
         }
     }];
}




// This is to handle the image clicked
-(void)tapDetected{
    NSLog(@"single Tap on imageview");
}



- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}


// This is trying to make the keyboard disappear.

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];

}







// After Picking The Photo, show it on the view and share with FaceBook(This need the phone has a native Facebook app)
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;
    
    // This is trying to fill the image as it is.
    [self.imageView setImage:chosenImage];
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y,
                                 chosenImage.size.width, chosenImage.size.height);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    
    // This is what is going to be shared on facebook
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = image;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    
    FBSDKShareButton *button = [[FBSDKShareButton alloc] init];
    button.shareContent = content;
    
    //Adjust the position of the button
    CGPoint sharePosition;
    sharePosition.x = 180;
    sharePosition.y = 580;
    button.center = sharePosition;
    [self.view addSubview:button];
    
    
//    [FBSDKShareDialog showFromViewController:self
//                                 withContent:content
//                                    delegate:nil];
    
    // Share the link example
//    FBSDKShareLinkContent *content2 = [[FBSDKShareLinkContent alloc] init];
//    content2.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
    
    
    
    NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSDictionary *metadata = rep.metadata;
        //NSLog(@"This is the Exif: %@", metadata);
        NSLog(@"%@",metadata.allKeys);
        NSLog(@"%@",metadata);
        // Print all the keys in the nsarray
        //NSString *xxx = [metadata objectForKey:@""];
        
        // This is for getting the gps information;
        NSDictionary *GPSInfo = [metadata valueForKey:@"{GPS}"];
        
        NSString *longtitu = [GPSInfo valueForKey:@"Longitude"];
        NSString *latitu = [GPSInfo valueForKey:@"Latitude"];
        
        NSLog(@"This is the Longtitude: %@", longtitu);
        NSLog(@"This is the Latitude: %@", latitu);
        
        la = latitu;
        lo = longtitu;
        
        // This is for getting the time information;
        NSDictionary *TimeInfo = [metadata valueForKey:@"{TIFF}"];
        NSString *time = [TimeInfo valueForKey:@"DateTime"];
        
        
        
        // Put the information is the textField
        NSString *text = @"This photo contains precious memory. I still remember on that day the weather is";
            text = [NSString stringWithFormat:@"%@ %@%@", text, weather, @"."];
        if (longtitu == NULL || latitu == NULL) {
            text = [NSString stringWithFormat:@"%@ %@", text, @"Although I don't know where is was taken."];
        } else {
            text = [NSString stringWithFormat:@"%@ %@ %@ %@", text, @"It was taken at the position of",longtitu,latitu];
        }
        
        if (time == NULL) {
            text = [NSString stringWithFormat:@"%@ %@", text, @"On the other hand I don't know when it were took."];
        } else {
            text = [NSString stringWithFormat:@"%@ %@ %@", text, @"It were took at ", time];
        }
        self.photoInfor.text = text;
        
        
        NSLog(@"%@",@"hhhh");
        //self.photoInfor.text = xxx;
        CGImageRef iref = [rep fullScreenImage] ;
        if (iref) {
            self.imageView.image = [UIImage imageWithCGImage:iref];
        }
    } failureBlock:^(NSError *error) {
        // error handling
    }];
    
    // This is tring to call the REST API
    
    
    
}

// This is for passing GPS location
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"pushGPSSegue"]){
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        controller.latitude = la;
        controller.longtitude = lo;
    }
}


// Testing the get REST







- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



@end
