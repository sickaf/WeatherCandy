//
//  ViewController.h
//  WeatherCandy
//
//  Created by dtown on 8/31/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageViewAligned.h"

@interface WCMainViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageViewAligned *imageView;

@property (weak, nonatomic) IBOutlet UILabel *mainTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *highTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

