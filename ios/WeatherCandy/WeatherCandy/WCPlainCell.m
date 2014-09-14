//
//  WCAboutCell.m
//  WeatherCandy
//
//  Created by dtown on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCPlainCell.h"
#import "WCConstants.h"

@implementation WCPlainCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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
    self.mainLabel.font = kDefaultFontMedium(18);
    self.mainLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = kDefaultBackgroundColor;
    self.tintColor = [UIColor whiteColor];
}

@end
