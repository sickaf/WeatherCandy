//
//  WCTitleButtonViewController.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/3/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCTitleButtonViewController : UIViewController

@property (nonatomic, strong) NSString *titleButtonText;

- (void)pressedTitle:(id)sender;

@end
