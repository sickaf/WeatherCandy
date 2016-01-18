//
//  WCNotificationBlurViewController.m
//  WeatherCandy
//
//  Created by dtown on 9/12/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCNotificationBlurViewController.h"
#import "WCSettings.h"
#import <Parse/Parse.h>


@interface WCNotificationBlurViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *blurImageView;
@property (weak, nonatomic) IBOutlet UIDatePicker *notificationDatePicker;
- (IBAction)doneChoosingTimeButton:(UIButton *)sender;


@end

@implementation WCNotificationBlurViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blurImageView.image = self.blurImg;

}

- (IBAction)doneChoosingTimeButton:(UIButton *)sender {
        
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = self.notificationDatePicker.date;
    localNotification.alertBody = @"Check the weather!";
    
    //Analytics
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    localNotification.repeatInterval = NSCalendarUnitDay;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
