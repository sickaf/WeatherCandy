//
//  WCToggleCell.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCToggleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *tempToggle;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@end
