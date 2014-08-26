//
//  IDPSimpleClippingView.h
//  SimpleImageClipping
//
//  Created by 能登 要 on 2014/08/27.
//  Copyright (c) 2014年 com.irimasu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IDPSimpleClippingViewClippingType)
{
     IDPSimpleClippingViewClippingTypeClipping
    ,IDPSimpleClippingViewClippingTypeErase
};

@protocol IDPSimpleClippingViewDelegate;

@interface IDPSimpleClippingView : UIView

@property (strong,nonatomic) UIColor *strokeColor;
@property (strong,nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic,weak) IBOutlet id<IDPSimpleClippingViewDelegate> delegate;

+ (void)maskViewWithPath:(UIBezierPath *)bezierPath targetView:(UIView *)targetView drawArea:(CGRect)drawArea clippingType:(IDPSimpleClippingViewClippingType)clippingType; // View に対してmaskを作成する
+ (void)applyPathWithPath:(UIBezierPath *)bezierPath targetSize:(CGSize)targetSize originalArea:(CGRect)originalArea drawArea:(CGRect)drawArea clippingType:(IDPSimpleClippingViewClippingType)clippingType; //
@end

@protocol IDPSimpleClippingViewDelegate <NSObject>

- (void) simpleClippingView:(IDPSimpleClippingView*)simpleClippingView finishPath:(UIBezierPath*)bezierPath;

@end
