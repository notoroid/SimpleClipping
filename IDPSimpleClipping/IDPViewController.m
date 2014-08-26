//
//  IDPViewController.m
//  SimpleImageClipping
//
//  Created by 能登 要 on 2014/08/26.
//  Copyright (c) 2014年 com.irimasu. All rights reserved.
//

#import "IDPViewController.h"
#import "IDPSimpleClippingView.h"

@interface IDPViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,IDPSimpleClippingViewDelegate>
{
    __weak IBOutlet UIImageView *_previewView;
    
    __weak IBOutlet IDPSimpleClippingView *_simpleClippingView;
    UIImage *_originalImage;
    UIBezierPath *_bezierPath;
}
@end

@implementation IDPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)firedImageLoad:(id)sender
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    _bezierPath = nil;
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    const CGSize temporarySize = CGSizeMake(_previewView.frame.size.width * screenScale,_previewView.frame.size.height * screenScale);
    
    CGFloat ratioBaseSize = temporarySize.width / temporarySize.height;
    CGFloat ratioOriginal = _originalImage.size.width / _originalImage.size.height;
    
    CGSize normalizedSize = CGSizeZero;
    CGFloat scale = 1.0;
    if( ratioBaseSize <= ratioOriginal ){
        normalizedSize = CGSizeMake(ceil(temporarySize.width)  , ceil(temporarySize.width * (_originalImage.size.height / _originalImage.size.width) ) );
        scale = temporarySize.width / _originalImage.size.width;
    }else{
        normalizedSize = CGSizeMake(ceil(temporarySize.height * (_originalImage.size.width / _originalImage.size.height) ) , ceil(temporarySize.height) );
        scale = temporarySize.height / _originalImage.size.height;
    }
    
    // 写真サイズを変更
    UIGraphicsBeginImageContext(normalizedSize);
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    [_originalImage drawInRect:CGRectMake(.0f,.0f, normalizedSize.width, normalizedSize.height)];
    
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _previewView.image = resizedImage;
    _previewView.layer.mask = nil;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}


- (void) simpleClippingView:(IDPSimpleClippingView*)simpleClippingView finishPath:(UIBezierPath*)bezierPath
{
    _bezierPath = bezierPath;
    // パスを格納
    
    [IDPSimpleClippingView maskViewWithPath:bezierPath targetView:_previewView drawArea:simpleClippingView.frame clippingType:IDPSimpleClippingViewClippingTypeErase];
    
}

- (IBAction)firedSaveCameraRoll:(id)sender
{
    CGSize imageSize = _originalImage.size;
    
    UIGraphicsBeginImageContext(imageSize);
    
    [[UIColor whiteColor] setFill];
    [[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,imageSize}] fill];
    
    
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    
    
    [IDPSimpleClippingView applyPathWithPath:_bezierPath targetSize:imageSize originalArea:_previewView.frame drawArea:_simpleClippingView.frame clippingType:IDPSimpleClippingViewClippingTypeErase];
    
    [_originalImage drawInRect:CGRectMake(.0f,.0f, imageSize.width, imageSize.height)];
    
    
    UIImage* clippingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(clippingImage, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:) , nil);
}

- (void)savingImageIsFinished:(UIImage*)_image didFinishSavingWithError:(NSError*)_error contextInfo:(void*)_contextInfo {
    
}

@end
