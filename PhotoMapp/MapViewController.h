//
//  ViewController.h
//  PhotoMapp
//
//  Created by Bob Feng on 7/27/16.
//  Copyright © 2016 Bob Feng. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController<MKMapViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *myMap;

// This information will come from the previous view
@property(nonatomic) NSString *longtitude;
@property(nonatomic) NSString *latitude;
@property (strong, nonatomic) IBOutlet UILabel *notice;

@end
