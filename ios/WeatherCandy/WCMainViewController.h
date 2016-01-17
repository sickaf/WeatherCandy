//
//  ViewController.h
//  WeatherCandy
//
//  Created by dtown on 8/31/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "UIImageViewAligned.h"
#import "WCTitleButtonViewController.h"
#import "WCChooseCategoryViewController.h"

typedef enum {
    WCBackgroundTypeBlue = 1,
    WCBackgroundTypePurple,
    WCBackgroundTypeOrange,
} WCBackgroundType;

@interface WCMainViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, CLLocationManagerDelegate, WCChooseCategoryProtocol>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *mainTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIImageView *bgGradientImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topGradientImageView;

@end

