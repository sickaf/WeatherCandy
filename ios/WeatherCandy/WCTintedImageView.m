//
//  WCTintedImageView.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/4/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCTintedImageView.h"

@implementation WCTintedImageView

- (void)awakeFromNib
{
    self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
