//
//  ViewController.m
//  PhotoMapp
//
//  Created by Bob Feng on 7/27/16.
//  Copyright © 2016 Bob Feng. All rights reserved.
//

#import "MapViewController.h"
@import CoreLocation;


@interface MapViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation MapViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [self.locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    [self.locationManager startUpdatingLocation];
    
    
    
    // Set the control to itself
    [self.myMap setDelegate:self];
    
    // Set self location
    [self.myMap setShowsUserLocation:YES];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.myMap setCenterCoordinate: self.myMap.userLocation.location.coordinate animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        // Printout the current location
        NSLog(@"hehaha");
        NSLog([NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
        NSLog([NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
//        CLLocationCoordinate2D noLocation;
//        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500);
//        MKCoordinateRegion region = [self.myMap regionThatFits:viewRegion];
        
        MKCoordinateRegion region;
        
        // If No GPS Location Passed, just show the current position of the user
        if (self.latitude == NULL || self.longtitude == NULL) {
            region.center.latitude = currentLocation.coordinate.latitude;
            region.center.longitude = currentLocation.coordinate.longitude;
        } else {
            region.center.latitude = [self.latitude doubleValue];
            region.center.longitude = [self.longtitude doubleValue];
        }
        
        region.span.latitudeDelta = 0.03;
        region.span.longitudeDelta = 0.03;
        
        //Set the pin
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(region.center.latitude, region.center.longitude);
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:coord];
        
        
        [self.myMap setRegion:region animated:YES];
        
        if (self.latitude != NULL && self.longtitude != NULL) {
            [self.myMap addAnnotation:annotation];
        } else {
            self.notice.text = @"No picture selected, here is you current location";
        }
    }
}




@end
