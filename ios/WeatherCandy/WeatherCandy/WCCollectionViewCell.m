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
    RMDownloadIndicator *closedIndicator = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 40)/2, (CGRectGetHeight(self.bounds) - 40)/2 - 10, 40, 40) type:kRMClosedIndicator];
    [closedIndicator setBackgroundColor:[UIColor clearColor]];
    [closedIndicator setFillColor:[UIColor colorWithWhite:0.400 alpha:1.000]];
    [closedIndicator setStrokeColor:[UIColor whiteColor]];
    [self.contentView insertSubview:closedIndicator belowSubview:self.imageView];
    [closedIndicator loadIndicator];
    _downloadIndicator = closedIndicator;
}

- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL == imageURL) return;
    _imageURL = imageURL;
    
    __weak __typeof(self)weakSelf = self;
    [self.imageView setImageWithURL:[NSURL URLWithString:imageURL] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.imageView.image = image;
        [strongSelf.downloadIndicator removeFromSuperview];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        // TODO: handle error
    } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.downloadIndicator updateWithTotalBytes:totalBytesExpectedToRead downloadedBytes:totalBytesRead];
    }];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
    self.imageURL = nil;
}

@end
