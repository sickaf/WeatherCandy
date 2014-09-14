//
//  WCCategoryCell.m
//  WeatherCandy
//
//  Created by dtown on 9/13/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCCategoryCell.h"
#import "WCConstants.h"

@implementation WCCategoryCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.categoryLabel.font = kDefaultFontMedium(18);
    self.categoryLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.backgroundColor = kDefaultBackgroundColor;
    
    self.textLabel.font = kDefaultFontMedium(18);
    self.textLabel.textColor = [UIColor whiteColor];
}

@end
