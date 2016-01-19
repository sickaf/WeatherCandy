//
//  WCChooseCategoryViewController.h
//  WeatherCandy
//
//  Created by dtown on 9/23/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCChooseCategoryProtocol;

@interface WCChooseCategoryViewController : UIViewController

@property (nonatomic, weak) id<WCChooseCategoryProtocol> delegate;

@end

@protocol WCChooseCategoryProtocol <NSObject>

- (void)userDidChooseCategory;

@end
