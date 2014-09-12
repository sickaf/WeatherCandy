//
//  WCNotificationBlurViewController.m
//  WeatherCandy
//
//  Created by dtown on 9/12/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCNotificationBlurViewController.h"

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
    
    //NSDate *dateTmw = [NSDate date];
    //dateTmw  = [dateTmw dateByAddingTimeInterval:5]; //for Testing
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = self.notificationDatePicker.date;
    localNotification.alertBody = @"Check the weather!";

    localNotification.repeatInterval = NSDayCalendarUnit;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"Just scheduled a notification for %@", localNotification.fireDate.description);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];


}
@end