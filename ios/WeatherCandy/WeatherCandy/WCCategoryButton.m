//
//  WCCategoryButton.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/26/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCCategoryButton.h"
#import "WCConstants.h"

@implementation WCCategoryButton

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.titleLabel.font = kDefaultFontMedium(25);
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
}

@end
