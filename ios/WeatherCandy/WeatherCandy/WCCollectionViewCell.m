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
