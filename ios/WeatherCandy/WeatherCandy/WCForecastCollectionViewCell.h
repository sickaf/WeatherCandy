//
//  WCForecastCollectionViewCell.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCTintedImageView.h"

@interface WCForecastCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet WCTintedImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) UIImage *iconImage;

@end
