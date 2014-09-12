//
//  UIViewController+BlurredSnapshot.h
//  WeatherCandy
//
//  Created by dtown on 9/12/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BlurredSnapshot)

- (UIImage *)blurredImageOfCurrentView;
- (UIImage *)blurredImageOfCurrentViewWithAlpha:(CGFloat)alpha withRadius:(CGFloat)radius withSaturation:(CGFloat)saturation;

@end
