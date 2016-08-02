//
//  SecondViewController.m
//  PhotoMapp
//
//  Created by Bob Feng on 7/19/16.
//  Copyright © 2016 Bob Feng. All rights reserved.
//
@import CoreMotion;
@import ImageIO;
@import CoreLocation;
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
#import <CoreMotion/CMPedometer.h>





@interface SecondViewController ()
// The is the reference of the pedometer
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation SecondViewController

CLLocationManager *locationManager;

static NSString *la;
static NSString *lo;
static NSString *laRef;
static NSString *loRef;
static NSString *weather;
static NSString *place;
static NSString *ti;
static NSString *geocode;
static NSString *year;
static NSString *month;
static NSString *day;
static NSString *realLocation;
static NSString *steps;
static int judge = 0;


// These functions are trying to move the views up when keyboard pops out.
// Reference: http://stackoverflow.com/questions/1247113/iphone-keyboard-covers-uitextfield
- (void)textViewDidBeginEditing:(UITextView *)textField
{
    NSLog(@"xxx");
    [self animateTextView: textField up: YES];
}


- (void)textViewDidEndEditing:(UITextView *)textField
{
    NSLog(@"yyy");
    [self animateTextView: textField up: NO];
}

- (void) animateTextView: (UITextView*) textField up: (BOOL) up
{
    const int movementDistance = 150; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}





- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}



// These functions are used for pedometer. Reference: http://pinkstone.co.uk/how-to-access-the-step-counter-and-pedometer-data-in-ios-9/
- (CMPedometer *)pedometerInitial {
    NSLog(@"aaaaaaaaaaa");
    if (!_pedometer) {
        _pedometer = [[CMPedometer alloc]init];
    }
    return _pedometer;
}

- (IBAction)Tracking:(id)sender {
        
        // start live tracking
        [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *_Nullable pedometerData, NSError * _Nullable error) {
            NSLog(@"sss");
        // this block is called for each live update
        [self updateLabels:pedometerData];
            
    }];
}


- (void)updateLabels:(CMPedometerData *)pedometerData {
    NSLog(@"sssssss4");

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.maximumFractionDigits = 2;
    
    // step counting
    if ([CMPedometer isStepCountingAvailable]) {
        NSLog(@"%@",[NSString stringWithFormat:@"Steps walked: %@", [formatter stringFromNumber:pedometerData.numberOfSteps]]);
        steps = [formatter stringFromNumber:pedometerData.numberOfSteps];
    } else {
        NSLog(@"Step Counter not available.");
    }
    
    // distance
    if ([CMPedometer isDistanceAvailable]) {
        NSLog(@"%@",[NSString stringWithFormat:@"Distance travelled: \n%@ meters", [formatter stringFromNumber:pedometerData.distance]]);
    } else {
        NSLog(@"Distance estimate not available.");
    }
    
    // pace
    if ([CMPedometer isPaceAvailable] && pedometerData.currentPace) {
        NSLog(@"%@",[NSString stringWithFormat:@"Current Pace: \n%@ seconds per meter", [formatter stringFromNumber:pedometerData.currentPace]]);
    } else {
        NSLog(@"Pace not available.");
    }
    
    // cadence
    if ([CMPedometer isCadenceAvailable] && pedometerData.currentCadence) {
        NSLog(@"%@",[NSString stringWithFormat:@"Cadence: \n%@ steps per second", [formatter stringFromNumber: pedometerData.currentCadence]]);
    } else {
        NSLog(@"Cadence not available.");
    }
    
    // flights climbed
    if ([CMPedometer isFloorCountingAvailable] && pedometerData.floorsAscended) {
        NSLog(@"%@",[NSString stringWithFormat:@"Floors ascended: %@", pedometerData.floorsAscended]);
    } else {
        NSLog(@"Floors ascended\nnot available.");
    }
    
    if ([CMPedometer isFloorCountingAvailable] && pedometerData.floorsDescended) {
        NSLog(@"%@", [NSString stringWithFormat:@"Floors descended: %@", pedometerData.floorsDescended]);
    } else {
        NSLog(@"Floors descended\nnot available.");
    }
    
}




// This is the camera function, Reference: https://www.appcoda.com/ios-programming-camera-iphone-app/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
    
    NSLog(@"sssssss");
    [self pedometerInitial];
    // start live tracking
    
    NSLog(@"sssssss2");

    
    
    NSLog(@"sssssss3");

    
}



// Reference: https://spring.io/guides/gs/consuming-rest-ios/
// Get the location Geocode calling api,
- (IBAction)fetchLocation;
{
    NSString *position = [NSString stringWithFormat:@"%@%@%@%@",@"?lattlong=",la, @",",lo];
    NSString *theURL = [NSString stringWithFormat:@"%@%@",@"https://www.metaweather.com/api/location/search/",position];
    NSURL *url = [NSURL URLWithString:theURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             
             //id key = [[greeting allKeys] objectAtIndex:0]; // Assumes 'message' is not empty
             //id object = [greeting objectForKey:key];
             //NSString *x =  [[greeting objectForKey:@"weather_state_name"] stringValue];
             NSEnumerator *enumerator = [info objectEnumerator];
             NSDictionary *instance = [enumerator nextObject];
             NSLog(@"%@",[instance objectForKey:@"title"]);
             
             // This is the place name of that location
             place = [instance objectForKey:@"title"];
             geocode = [instance objectForKey:@"woeid"];
            
         }
     }];
}


// Make sure the fetchWeather is called after the fetchLocation Method, because weather will need the geoCode information from fetchLocation.
// Reference : https://spring.io/guides/gs/consuming-rest-ios/
- (IBAction)fetchWeather;
{
    // Here is the code to make a restful api call
    NSString *weatherURL = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"https://www.metaweather.com/api/location/",geocode,@"/",year,@"/",month,@"/",day];
    
    NSLog(@"%@", weatherURL);
    
    NSURL *url = [NSURL URLWithString:weatherURL];
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
             //geocode = [instance objectForKey:@"woeid"];
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

// This is the camera function, Reference: https://www.appcoda.com/ios-programming-camera-iphone-app/
- (IBAction)takePhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    judge = 1;
}

// This is the camera function, Reference: https://www.appcoda.com/ios-programming-camera-iphone-app/
- (void)takePhoto2 {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    judge = 1;
}

// This is the camera function, Reference: https://www.appcoda.com/ios-programming-camera-iphone-app/
- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    judge = 2;
}


// GPS helper method, reference: http://stackoverflow.com/questions/4152003/how-can-i-get-current-location-from-user-in-ios

- (NSDictionary *) gpsDictionaryForLocation:(CLLocation *)location
{
    CLLocationDegrees exifLatitude  = location.coordinate.latitude;
    CLLocationDegrees exifLongitude = location.coordinate.longitude;
    
    NSString * latRef;
    NSString * longRef;
    if (exifLatitude < 0.0) {
        exifLatitude = exifLatitude * -1.0f;
        latRef = @"S";
    } else {
        latRef = @"N";
    }
    
    if (exifLongitude < 0.0) {
        exifLongitude = exifLongitude * -1.0f;
        longRef = @"W";
    } else {
        longRef = @"E";
    }
    
    NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
    
    [locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
    [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    [locDict setObject:longRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    [locDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
    [locDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    
    return locDict;
}








// After Picking The Photo, show it on the view and share with FaceBook(This need the phone has a native Facebook app)
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;
    NSMutableDictionary *imageMetadata = [[NSMutableDictionary alloc] initWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
    
    
    
    // This is trying to fill the image as it is.
    [self.imageView setImage:chosenImage];
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y,
                                 chosenImage.size.width, chosenImage.size.height);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    // judge == 1 means this photo is taken from camera. Save the image to gallary
    // reference : http://stackoverflow.com/questions/7965299/write-uiimage-along-with-metadata-exif-gps-tiff-in-iphones-photo-library
    if (judge == 1) {
        
        
        // create CLLocation for image
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        CLLocation * loc = [locationManager location];
        
        if (loc) {
            [imageMetadata setObject:[self gpsDictionaryForLocation:loc] forKey:(NSString*)kCGImagePropertyGPSDictionary];
        }
        
        // Get the assets library
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        // create a completion block for when we process the image
        ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
        ^(NSURL *newURL, NSError *error) {
            if (error) {
                NSLog( @"Error writing image with metadata to Photo Library: %@", error );
            } else {
                NSLog( @"Wrote image %@ with metadata %@ to Photo Library",newURL,imageMetadata);
            }
        };
        
        // Save the new image to the Camera Roll, using the completion block defined just above
        [library writeImageToSavedPhotosAlbum:[chosenImage CGImage] metadata:imageMetadata completionBlock:imageWriteCompletionBlock];
        
        
        
//        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
//        [library writeImageToSavedPhotosAlbum:[chosenImage CGImage] metadata:imageMetadata completionBlock:Nil];
        //[library release];
        
        
        //UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);
        self.photoInfor.text = @"Your photo has been saved, you can select photo and generate diary.";
        
    } else {
        // This is the toast message
        NSString *message = @"Generating Your Diary Template, Please Wait...";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        int duration = 5; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
        
        
        
        
        
        
        // This is what is going to be shared on facebook
        //UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImage *image = chosenImage;
        
        
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = image;
        photo.userGenerated = YES;
        
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
        
        
        
        
        //    NSURL *imageURL = [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/c/cd/Panda_Cub_from_Wolong,_Sichuan,_China.JPG"];
        //    FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:imageURL userGenerated:YES];
        //    NSDictionary *properties = @{
        //                                 @"og:type": @"welovephotomap:diary",
        //                                 @"og:title": @"Sample Diary",
        //                                 @"og:description": @"",
        //                                 @"og:url": @"http://samples.ogp.me/325643821156611",
        //                                 @"og:image": @[photo]
        //                                 };
        //    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
        //    FBSDKShareAPI *shareAPI = [[FBSDKShareAPI alloc] init];
        //    [shareAPI createOpenGraphObject:object];
        //
        //
        //    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
        //    action.actionType = @"welovephotomap:create";
        //    [action setString:@"http://samples.ogp.me/325643821156611" forKey:@"diary"];
        //    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
        //    content.action = action;
        //    content.previewPropertyName = @"diary";
        //    //FBSDKShareAPI *shareAPI = [[FBSDKShareAPI alloc] init];
        //    // optionally set the delegate
        //    // shareAPI.delegate = self;
        //    shareAPI.shareContent = content;
        //    [shareAPI share];
        
        
        
        
        FBSDKShareButton *button = [[FBSDKShareButton alloc] init];
        button.shareContent = content;
        
        //Adjust the position of the button
        CGPoint sharePosition;
        sharePosition.x = 185;
        sharePosition.y = 560;
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
            laRef = [GPSInfo valueForKey:@"LatitudeRef"];
            loRef = [GPSInfo valueForKey:@"LongitudeRef"];
            
            
            NSLog(@"This is the Longtitude: %@", longtitu);
            NSLog(@"This is the Latitude: %@", latitu);
            
            // Get the longtitude and the latitude.(Transmit + or - in it)
            if ([laRef  isEqual: @"S"]) {
                la =[NSString stringWithFormat:@"%@%@",@"-",latitu];
            } else {
                la = latitu;
            };
            if ([loRef  isEqual: @"W"]) {
                lo =[NSString stringWithFormat:@"%@%@",@"-",longtitu];
            } else {
                lo = longtitu;
            };
            
            
            CLLocation *locationa = [[CLLocation alloc]
                                     initWithLatitude:[la doubleValue]
                                     longitude:[lo doubleValue]];
            
            self.geo = [[CLGeocoder alloc] init];
            [self.geo reverseGeocodeLocation:locationa completionHandler:^(NSArray *placemarks, NSError *error){
                if (error == nil && placemarks.count >0) {
                    CLPlacemark *placemark = placemarks[0];
                    NSLog(@"ahahahahahahahahahahahaha : %@", placemark.locality);
                    realLocation = placemark.locality;
                }
                else if (error == nil && placemarks.count == 0){
                    NSLog(@"No results were returnd.");
                }
                else if (error != nil) {
                    NSLog(@"An error occurred = %@", error);
                }
            }];
            
            
            
            
            
            // This is for getting the time information;
            NSDictionary *TimeInfo = [metadata valueForKey:@"{TIFF}"];
            NSString *time = [TimeInfo valueForKey:@"DateTime"];
            ti = time;
            //
            NSArray *timeArray = [ti componentsSeparatedByString: @":"];
            NSLog(@"%@",timeArray[0]);
            NSLog(@"%@",timeArray[1]);
            NSLog(@"%@",timeArray[2]);
            
            year = timeArray[0];
            month = timeArray[1];
            day = [timeArray[2] substringToIndex:2];
            
            
            
            // This is for getting the steps
            
            NSString *dateString = [NSString stringWithFormat:@"%@%@%@%@%@ %@",day,@"-",month,@"-",year,@"00:00:00"];
            NSLog(@"The beginning date is %@", dateString);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd-MM-yyyy HH:mm:ss";
            NSDate *date3 = [dateFormatter dateFromString:dateString];
            
            NSString *dateString2 = [NSString stringWithFormat:@"%@%@%@%@%@ %@",day,@"-",month,@"-",year,@"23:59:59"];
            NSLog(@"The end date is %@", dateString2);
            NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
            dateFormatter2.dateFormat = @"dd-MM-yyyy HH:mm:ss";
            NSDate *date2 = [dateFormatter2 dateFromString:dateString2];
            
            //NSLog(@"%@",self.pedometer);
            
            //NSLog(@"%d", [CMPedometer isStepCountingAvailable]);
            if (day != NULL && month != NULL && year != NULL) {
                [self.pedometer queryPedometerDataFromDate:date3 toDate:date2 withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
                    //NSLog(@"sss");
                    //NSLog(@"%@",error);
                    // this block is called for each live update
                    [self updateLabels:pedometerData];
                    NSLog(@"%@", pedometerData);
                    
                }];
            }
            
            
            
            
            // Using API to check the location information.
            [self fetchLocation];
            
            //after fetch location 2 second, call fetchWeather(First get the location, then there is weather.)
            [NSTimer scheduledTimerWithTimeInterval:2.5
                                             target:self
                                           selector:@selector(doSomethingWhenTimeIsUp2:)
                                           userInfo:nil
                                            repeats:NO];
            
            
            
            // Try to wait for the information to setup the textfield
            
            NSLog(@"%@",@"hhhh");
            //self.photoInfor.text = xxx;
            CGImageRef iref = [rep fullScreenImage] ;
            if (iref) {
                self.imageView.image = [UIImage imageWithCGImage:iref];
            }
        } failureBlock:^(NSError *error) {
            // error handling
        }];

    }
    
    
}

// This is for passing GPS location
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"pushGPSSegue"]){
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        controller.latitude = la;
        controller.longtitude = lo;
    }
}


// The timer method

- (void) doSomethingWhenTimeIsUp:(NSTimer*)t {
    
    // Put the information is the textField
    NSString *text = @"This photo contains precious memory. I still remember on that day the weather was";
    if (weather == NULL) {
        text = [NSString stringWithFormat:@"%@ %@%@", text, @"uncertain", @"."];
    } else {
        text = [NSString stringWithFormat:@"%@ %@%@", text, weather, @"."];
    }
    
    if (lo == NULL || la == NULL) {
        text = [NSString stringWithFormat:@"%@ %@", text, @"Although I don't know where it was taken."];
    } else {
        text = [NSString stringWithFormat:@"%@ %@ %@%@", text, @"It was taken at",realLocation,@"."];
    }
    
    if (ti == NULL) {
        text = [NSString stringWithFormat:@"%@ %@", text, @"On the other hand I don't know when I took it."];
    } else {
        text = [NSString stringWithFormat:@"%@ %@ %@%@", text, @"The time was ", ti,@"."];
    }
    
    text = [NSString stringWithFormat:@"%@ %@ %@ %@", text, @"I walked", steps, @"steps on that day."];
    self.photoInfor.text = text;

}

- (void) doSomethingWhenTimeIsUp2:(NSTimer*)t {
    [self fetchWeather];
    [NSTimer scheduledTimerWithTimeInterval:2.5
                                     target:self
                                   selector:@selector(doSomethingWhenTimeIsUp:)
                                   userInfo:nil
                                    repeats:NO];

}





- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


@end
