//
//  WCNotificationsSwitchCell.h
//  WeatherCandy
//
//  Created by dtown on 9/9/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCNotificationsSwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end
