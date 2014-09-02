//
//  ViewController.h
//  WeatherCandy
//
//  Created by dtown on 8/31/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageViewAligned.h"

@interface WCMainViewController : UIViewController <UICollectionViewDataSource, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageViewAligned *imageView;

@end

