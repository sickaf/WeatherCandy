//
//  WCNavigationController.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCNavigationController.h"
#import "WCConstants.h"

@interface WCNavigationController ()

@end

@implementation WCNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName: kDefaultTitleFont, NSForegroundColorAttributeName : [UIColor blackColor]};
}

@end
