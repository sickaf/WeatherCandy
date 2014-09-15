//
//  WCTitleButton.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/15/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCTitleButton.h"
#import "WCConstants.h"

@implementation WCTitleButton

- (void)awakeFromNib
{
    [self setup];
}

- (id)init
{
    self = [super init];
    if (self) {
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

- (void)setup
{
    self.titleLabel.font = kDefaultFontMedium(18);
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -self.imageView.frame.size.width - 5, 0, self.imageView.frame.size.width + 5);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, self.titleLabel.frame.size.width, 0, -self.titleLabel.frame.size.width);
}

@end
