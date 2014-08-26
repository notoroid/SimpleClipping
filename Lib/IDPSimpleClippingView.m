//
//  IDPSimpleClippingView.m
//  SimpleImageClipping
//
//  Created by 能登 要 on 2014/08/27.
//  Copyright (c) 2014年 com.irimasu. All rights reserved.
//

#import "IDPSimpleClippingView.h"

@interface IDPSimpleClippingView ()
{
    CALayer* _maskLayer;
    
    UIBezierPath *_path;
    NSValue* _firstPoint;
    
    UIImage *_innerImage;
    CGPoint _points[5];
    NSUInteger _counter;
}

@end

@implementation IDPSimpleClippingView

- (CALayer*) maskLayer
{
    if( _maskLayer == nil ){
        _maskLayer = [[CALayer alloc] init];
        _maskLayer.bounds = CGRectMake(.0f, .0f, self.frame.size.width, self.frame.size.height );
    }
    return _maskLayer;
}


- (void) setup
{
    [self setMultipleTouchEnabled:NO];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(firedPangesture:)];
    _panGestureRecognizer.delaysTouchesBegan = NO;
        // delay 無し
    [self addGestureRecognizer:_panGestureRecognizer];
    
    _strokeColor = [UIColor redColor];
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    _path = [UIBezierPath bezierPath];
    [_path setLineWidth:2.0];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [_innerImage drawInRect:rect];
    
    [_strokeColor setStroke];
    [_path stroke];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    if (!_innerImage)
    {

    }
    [_innerImage drawAtPoint:CGPointZero];
    [_strokeColor setStroke];
    [_path stroke];
    _innerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

// drawing algorithm by https://github.com/Jagadeeshwar-Reddy/DrawingSample
- (void)firedPangesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _counter = 0;
            _points[0] = [panGestureRecognizer locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint p = [panGestureRecognizer locationInView:self];
            _counter++;
            _points[_counter] = p;
            if (_counter == 4)
            {
                _points[3] = CGPointMake((_points[2].x + _points[4].x)/2.0, (_points[2].y + _points[4].y)/2.0);
                if( _firstPoint == nil ){
                    [_path moveToPoint:_points[0]];
                }
                [_path addCurveToPoint:_points[3] controlPoint1:_points[1] controlPoint2:_points[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                
                // 最初の点を登録
                if( _firstPoint == nil ){
                    _firstPoint = [NSValue valueWithCGPoint:_points[0]];
                }
                
                [self setNeedsDisplay];
                // replace points and get ready to handle the next segment
                _points[0] = _points[3];
                _points[1] = _points[4];
                _counter = 1;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
//            [self drawBitmap];
//            [self setNeedsDisplay];
            
            [_delegate simpleClippingView:self finishPath:[_path copy]];
            
            [self clearDraw];
                // 描画をクリア
            
            [_path removeAllPoints];
            _firstPoint = nil;
            
            _counter = 0;
            
        }
            break;
        default:
            break;
    }
}

- (void)clearDraw
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    _innerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    [self setNeedsDisplay];
}

+ (void)applyPathWithPath:(UIBezierPath *)bezierPath targetSize:(CGSize)targetSize originalArea:(CGRect)originalArea drawArea:(CGRect)drawArea  clippingType:(IDPSimpleClippingViewClippingType)clippingType
{
    bezierPath = [bezierPath copy];
        // 以後複製を使用
    
    CGPoint pointOffset = CGPointMake(drawArea.origin.x - originalArea.origin.x, drawArea.origin.y - originalArea.origin.y );
    CGFloat scale = targetSize.width / originalArea.size.width;
    
    CGAffineTransform affineTransform = CGAffineTransformIdentity;
    affineTransform  = CGAffineTransformScale(affineTransform, scale, scale);
    affineTransform = CGAffineTransformTranslate(affineTransform, pointOffset.x, pointOffset.y);
    
    [bezierPath applyTransform:affineTransform];
        // オフセットを考慮
    
    if( clippingType == IDPSimpleClippingViewClippingTypeErase ){
        UIBezierPath *bezeirImageRect = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,targetSize}];
        [bezeirImageRect appendPath:bezierPath];
        // hittest
        if( [bezeirImageRect containsPoint:CGPointMake(CGRectGetMidX(bezierPath.bounds),CGRectGetMidY(bezierPath.bounds))] == YES ){
            bezeirImageRect = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,targetSize}];
            [bezeirImageRect appendPath:[bezierPath bezierPathByReversingPath] ];
        }
        
        [bezeirImageRect addClip];
    }else{
        [bezierPath addClip];
    }
}


+ (void)maskViewWithPath:(UIBezierPath *)bezierPath targetView:(UIView *)targetView drawArea:(CGRect)drawArea clippingType:(IDPSimpleClippingViewClippingType)clippingType
{
    bezierPath = [bezierPath copy];
        // 以後複製を使用
    
    CGSize sizeTarget = targetView.frame.size;
    
    CGPoint pointOffset = CGPointMake(drawArea.origin.x - targetView.frame.origin.x, drawArea.origin.y - targetView.frame.origin.y );
    [bezierPath applyTransform:CGAffineTransformMakeTranslation(pointOffset.x, pointOffset.y) ];
        // オフセットを考慮
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sizeTarget.width ,sizeTarget.height ) , NO , [UIScreen mainScreen].scale );
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIColor* color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    [color setFill];
    
    if( clippingType == IDPSimpleClippingViewClippingTypeErase ){
        UIBezierPath *bezeirImageRect = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,sizeTarget}];
        [bezeirImageRect appendPath:bezierPath];
        // hittest
        if( [bezeirImageRect containsPoint:CGPointMake(CGRectGetMidX(bezierPath.bounds),CGRectGetMidY(bezierPath.bounds))] == YES ){
            bezeirImageRect = [UIBezierPath bezierPathWithRect:(CGRect){CGPointZero,sizeTarget}];;
            [bezeirImageRect appendPath:[bezierPath bezierPathByReversingPath] ];
        }
        
        
        [bezeirImageRect fill];
    }else{
        [bezierPath fill];
    }
    
    
    CGContextRestoreGState(context);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.bounds = CGRectMake(.0f, .0f, targetView.frame.size.width, targetView.frame.size.height );
    maskLayer.contents = (__bridge id)(image.CGImage);
    maskLayer.position = CGPointMake(targetView.frame.size.width * .5f, targetView.frame.size.height * .5f);
    
    targetView.layer.mask = maskLayer;
        // マスクとして適用
    
}


@end
