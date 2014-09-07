//
//  WCCollectionViewCell.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

@implementation WCCollectionViewCell

- (void)awakeFromNib
{
//    RMDownloadIndicator *closedIndicator = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 50)/2, (CGRectGetHeight(self.bounds) - 50)/2, 50, 50) type:kRMClosedIndicator];
//    [closedIndicator setBackgroundColor:[UIColor clearColor]];
//    [closedIndicator setFillColor:[UIColor colorWithRed:16./255 green:119./255 blue:234./255 alpha:1.0f]];
//    [closedIndicator setStrokeColor:[UIColor colorWithRed:16./255 green:119./255 blue:234./255 alpha:1.0f]];
//    closedIndicator.radiusPercent = 0.45;
//    [self.contentView addSubview:closedIndicator];
//    [closedIndicator loadIndicator];
//    _downloadIndicator = closedIndicator;
}

- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL == imageURL) return;
    _imageURL = imageURL;
        
    [self.imageView setImageWithURL:[NSURL URLWithString:imageURL]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
    self.imageURL = nil;
}

@end
