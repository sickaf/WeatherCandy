//
//  WCCollectionViewCell.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSString *imageURL;

@end
