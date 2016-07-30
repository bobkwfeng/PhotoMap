//
//  SecondViewController.m
//  PhotoMapp
//
//  Created by Bob Feng on 7/19/16.
//  Copyright © 2016 Bob Feng. All rights reserved.
//
@import CoreMotion;
@import ImageIO;
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

@end

@implementation SecondViewController

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
    
    NSLog(@"sssssss");
    [self pedometerInitial];
    // start live tracking
    
    NSLog(@"sssssss2");

    
    
    NSLog(@"sssssss3");

    
}



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
    
    // Save the image to gallary
    UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);
    
    
    
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
        day = [timeArray[2] substringToIndex:1];
        
        
        
        // This is for getting the steps
        
        NSString *dateString = [NSString stringWithFormat:@"%@%@%@%@%@ %@",day,@"-",month,@"-",year,@"00:00:00"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd-MM-yyyy HH:mm:ss";
        NSDate *date3 = [dateFormatter dateFromString:dateString];
        
        NSString *dateString2 = [NSString stringWithFormat:@"%@%@%@%@%@ %@",day,@"-",month,@"-",year,@"23:59:59"];
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        dateFormatter2.dateFormat = @"dd-MM-yyyy HH:mm:ss";
        NSDate *date2 = [dateFormatter2 dateFromString:dateString2];
        
        //NSLog(@"%@",self.pedometer);
        
        //NSLog(@"%d", [CMPedometer isStepCountingAvailable]);
        
        [self.pedometer queryPedometerDataFromDate:date3 toDate:date2 withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            //NSLog(@"sss");
            //NSLog(@"%@",error);
            // this block is called for each live update
            [self updateLabels:pedometerData];
            NSLog(@"%@", pedometerData);
            
        }];

        
        
        
        // Using API to check the location information.
        [self fetchLocation];
        
        //after fetch location 2 second, call fetchWeather(First get the location, then there is weather.)
        [NSTimer scheduledTimerWithTimeInterval:2.0
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


// The timer method

- (void) doSomethingWhenTimeIsUp:(NSTimer*)t {
    
    // Put the information is the textField
    NSString *text = @"This photo contains precious memory. I still remember on that day the weather is";
    text = [NSString stringWithFormat:@"%@ %@%@", text, weather, @"."];
    if (lo == NULL || la == NULL) {
        text = [NSString stringWithFormat:@"%@ %@", text, @"Although I don't know where is was taken."];
    } else {
        text = [NSString stringWithFormat:@"%@ %@ %@%@", text, @"It was taken at",realLocation,@"."];
    }
    
    if (ti == NULL) {
        text = [NSString stringWithFormat:@"%@ %@", text, @"On the other hand I don't know when it were took."];
    } else {
        text = [NSString stringWithFormat:@"%@ %@ %@", text, @"The time was ", ti];
    }
    
    text = [NSString stringWithFormat:@"%@ %@ %@ %@", text, @"I walked", steps, @"steps."];
    self.photoInfor.text = text;

    
}

- (void) doSomethingWhenTimeIsUp2:(NSTimer*)t {
    [self fetchWeather];
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(doSomethingWhenTimeIsUp:)
                                   userInfo:nil
                                    repeats:NO];

}





- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



@end
