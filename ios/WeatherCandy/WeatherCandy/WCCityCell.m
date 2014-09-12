//
//  WCCityCell.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCCityCell.h"
#import "WCConstants.h"

@implementation WCCityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
    self.textLabel.font = kDefaultFontMedium(16);
    self.textLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = kDefaultBackgroundColor;
}

@end
