//
//  WCSlideBehindModalAnimation.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/3/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WCSlideBehindModalAnimation : NSObject <UIViewControllerAnimatedTransitioning>;

@property (nonatomic, assign) BOOL presenting;

@end