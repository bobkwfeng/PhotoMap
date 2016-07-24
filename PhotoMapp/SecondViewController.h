//
//  SecondViewController.h
//  PhotoMapp
//
//  Created by Bob Feng on 7/19/16.
//  Copyright © 2016 Bob Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *photoInfor;

- (IBAction)takePhoto:(UIButton *)sender;- (IBAction)selectPhoto:(UIButton *)sender;

- (IBAction)shareIt:(UIButton *)sender;

@end

