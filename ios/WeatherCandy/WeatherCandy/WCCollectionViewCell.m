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
#import "WCConstants.h"

@implementation WCCollectionViewCell

- (void)awakeFromNib
{
    RMDownloadIndicator *closedIndicator = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 40)/2, (CGRectGetHeight(self.bounds) - 40)/2 - 10, 40, 40) type:kRMClosedIndicator];
    [closedIndicator setBackgroundColor:[UIColor clearColor]];
    [closedIndicator setFillColor:[UIColor colorWithWhite:0.400 alpha:1.000]];
    [closedIndicator setStrokeColor:[UIColor whiteColor]];
    [self.contentView insertSubview:closedIndicator belowSubview:self.imageView];
    [closedIndicator setHidden:YES];
    [closedIndicator loadIndicator];
    _downloadIndicator = closedIndicator;
}

- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL == imageURL) return;
    _imageURL = imageURL;
    
    [_downloadIndicator setHidden:NO];
    
    __weak __typeof(self)weakSelf = self;
    [self.imageView setImageWithURL:[NSURL URLWithString:imageURL] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        UIImage *reflectedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationDownMirrored];
        
        strongSelf.imageView.image = image;
        strongSelf.reflectionView.image = reflectedImage;
        [strongSelf.downloadIndicator setHidden:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kImageDownloadedNotification object:nil];
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
    self.reflectionView.image = nil;
    self.imageURL = nil;
    [self.downloadIndicator updateWithTotalBytes:0.0f downloadedBytes:10.0f];
}

@end
