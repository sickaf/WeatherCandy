//
//  WCForecastCollectionViewCell.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCForecastCollectionViewCell.h"
#import "WCConstants.h"

@implementation WCForecastCollectionViewCell

- (void)awakeFromNib
{
    self.timeLabel.font = kDefaultFontMedium(14);
    self.tempLabel.font = kDefaultFontMedium(14);
    self.timeLabel.alpha = 0.5;
}

- (void)setIconImage:(UIImage *)iconImage{
    if (_iconImage == iconImage) return;
    _iconImage = iconImage;
    
    self.iconImageView.image = [_iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
