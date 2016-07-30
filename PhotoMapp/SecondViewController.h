//
//  SecondViewController.h
//  PhotoMapp
//
//  Created by Bob Feng on 7/19/16.
//  Copyright © 2016 Bob Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface SecondViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITextView *photoInfor;
- (IBAction)takePhoto:(UIButton *)sender;- (IBAction)selectPhoto:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *Tracking;

@property (strong, nonatomic) CMPedometer *pedometer;

@property (strong, nonatomic) CLGeocoder *geo;


@end

