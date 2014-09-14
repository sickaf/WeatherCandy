//
//  WCTintedButton.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/14/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCTintedButton.h"

@implementation WCTintedButton

- (void)awakeFromNib
{
    self.tintColor = [UIColor whiteColor];
    UIImage *new = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [super setImage:new forState:UIControlStateNormal];
}

@end
