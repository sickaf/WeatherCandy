//
//  WCLabel.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/4/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCLabel.h"

@implementation WCLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    UIColor *color = [UIColor blackColor];
    self.layer.shadowColor = [color CGColor];
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(2, 2);
    
    self.layer.masksToBounds = NO;

}

@end
