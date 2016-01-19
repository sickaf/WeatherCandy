//
//  UIViewController+BlurredSnapshot.m
//  WeatherCandy
//
//  Created by dtown on 9/12/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "UIViewController+BlurredSnapshot.h"
#import "UIView+Snapshot.h"
#import "UIImage+ImageEffects.h"

@implementation UIViewController (BlurredSnapshot)

- (UIImage *)blurredImageOfCurrentView
{
    return [self blurredImageOfCurrentViewWithAlpha:0.5 withRadius:20 withSaturation:1.3];
}

- (UIImage *)blurredImageOfCurrentViewWithAlpha:(CGFloat)alpha withRadius:(CGFloat)radius withSaturation:(CGFloat)saturation
{
    UIImage *snap = [self.view convertViewToImage];
    //UIImage *blurred = [snap applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0 alpha:alpha] saturationDeltaFactor:1.3 maskImage:nil];
    UIImage *blurred = [snap applyBlurWithRadius:radius tintColor:[UIColor colorWithWhite:0 alpha:alpha] saturationDeltaFactor:saturation maskImage:nil];
    return blurred;
}


@end
