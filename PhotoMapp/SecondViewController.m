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
@import ImageIO;

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
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

- (IBAction)shareIt:(UIButton *)sender {
    
   
}



// The helper methon for share button






// After Picking The Photo, show it on the view and share with FaceBook(This need the phone has a native Facebook app)
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    
    // This is what is going to be shared on facebook
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = chosenImage;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    
    // Share the link example
    FBSDKShareLinkContent *content2 = [[FBSDKShareLinkContent alloc] init];
    content2.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
    
    
    // This is for getting the photo's information
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
//             resultBlock:^(ALAsset *asset) {
//                 
//                 ALAssetRepresentation *image_representation = [asset defaultRepresentation];
//                 
//                 // create a buffer to hold image data
//                 uint8_t *buffer = (Byte*)malloc(image_representation.size);
//                 NSUInteger length = [image_representation getBytes:buffer fromOffset: 0.0  length:image_representation.size error:nil];
//                 
//                 if (length != 0)  {
//                     
//                     // buffer -> NSData object; free buffer afterwards
//                     NSData *adata = [[NSData alloc] initWithBytesNoCopy:buffer length:image_representation.size freeWhenDone:YES];
//                     
//                     // identify image type (jpeg, png, RAW file, ...) using UTI hint
//                     NSDictionary* sourceOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)[image_representation UTI] ,kCGImageSourceTypeIdentifierHint,nil];
//                     
//                     // create CGImageSource with NSData
//                     CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef) adata,  (__bridge CFDictionaryRef) sourceOptionsDict);
//                     
//                     // get imagePropertiesDictionary
//                     CFDictionaryRef imagePropertiesDictionary;
//                     imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(sourceRef,0, NULL);
//                     
//                     // get exif data
//                     CFDictionaryRef exif = (CFDictionaryRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyExifDictionary);
//                     NSDictionary *exif_dict = (__bridge NSDictionary*)exif;
//                     NSLog(@"exif_dict: %@",exif_dict);
//                     
//                     // save image WITH meta data
//                     NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                     NSURL *fileURL = nil;
//                     CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0, imagePropertiesDictionary);
//                     
//                     if (![[sourceOptionsDict objectForKey:@"kCGImageSourceTypeIdentifierHint"] isEqualToString:@"public.tiff"])
//                     {
//                         fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.%@",
//                                                           documentsDirectory,
//                                                           @"myimage",
//                                                           [[[sourceOptionsDict objectForKey:@"kCGImageSourceTypeIdentifierHint"] componentsSeparatedByString:@"."] objectAtIndex:1]
//                                                           ]];
//                         
//                         CGImageDestinationRef dr = CGImageDestinationCreateWithURL ((__bridge CFURLRef)fileURL,
//                                                                                     (__bridge CFStringRef)[sourceOptionsDict objectForKey:@"kCGImageSourceTypeIdentifierHint"],
//                                                                                     1,
//                                                                                     NULL
//                                                                                     );
//                         CGImageDestinationAddImage(dr, imageRef, imagePropertiesDictionary);
//                         CGImageDestinationFinalize(dr);
//                         CFRelease(dr);
//                     }
//                     else
//                     {
//                         NSLog(@"no valid kCGImageSourceTypeIdentifierHint found …");
//                     }
//                     
//                     // clean up
//                     CFRelease(imageRef);
//                     CFRelease(imagePropertiesDictionary);
//                     CFRelease(sourceRef);
//                 }
//                 else {
//                     NSLog(@"image_representation buffer length == 0");
//                 }
//             }
//            failureBlock:^(NSError *error) {
//                NSLog(@"couldn't get asset: %@", error);
//            }
//     ];
    
    
    
    NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSDictionary *metadata = rep.metadata;
        NSLog(@"%@", metadata);
        
        NSString *xxx = [metadata objectForKey:@""];
        
        // Put the information is the textField
        self.photoInfor.text = [NSString stringWithFormat:@"my dictionary is %@", metadata];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



@end
