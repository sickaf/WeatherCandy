//
//  WCSettingsViewController.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/3/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCSettingsViewController.h"
#import "WCConstants.h"
#import "WCSettings.h"
#import "WCToggleCell.h"
#import "WCPlainCell.h"
#import "WCContactUsCell.h"
#import "WCNotificationsSwitchCell.h"
#import "UIViewController+BlurredSnapshot.h"
#import "WCNotificationBlurViewController.h"

#import "WCAddCityViewController.h"


@interface WCSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MFMailComposeViewController *mailComposer;
@property (weak, nonatomic) IBOutlet UIImageView *settingsBlurImageView;

@end

@implementation WCSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

#pragma mark - Actions

- (IBAction)pressedDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    [[WCSettings sharedSettings] setTempUnit:sender.selectedSegmentIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadTempLabelsNotification object:nil];
}


- (IBAction)notificationsSwitchChanged:(UISwitch *)sender {
    
    if (sender.isOn) {//Switched on
        
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        
        //User opted in to notifications and wants to turn on notifs
        if (YES){ // TODO: finish this
            
            WCNotificationBlurViewController *vc = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"NotificationDatePicker"];
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            vc.blurImg = [self blurredImageOfCurrentViewWithAlpha:0.7 withRadius:15 withSaturation:2];
            self.navigationController.delegate = self;
            [self presentViewController:vc animated:YES completion:nil];
        }
        else {
            NSLog(@"user already opted out of notifications");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable notifications"
                                                                   message:@"Turn on notifications for Weather Candy in settings"
                                                                  delegate:self
                                                         cancelButtonTitle:@"oaight"
                                                         otherButtonTitles:nil];
            [alert show];
            // TODO: make sure switch is off
            //[[WCSettings sharedSettings] setNotificationsOn:NO];
            return;
        }
        
    } else {//Switched off
        [[UIApplication sharedApplication] cancelAllLocalNotifications]; // TODO: call this when app is opened
    }
    [[WCSettings sharedSettings] setNotificationsOn:sender.isOn];
    NSLog(@"notifications are: %@", [[WCSettings sharedSettings] notificationsOn] ? @"ON" : @"OFF");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 3;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section) {
        case 0: title = @"Options"; break;
        case 1: title = @"About Sick.AF"; break;
        case 2: title = @"Hit us up"; break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)  // C|F cell
        {
            WCToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ToggleCell" forIndexPath:indexPath];
            cell.tempToggle.selectedSegmentIndex = [[WCSettings sharedSettings] tempUnit];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if (indexPath.row == 1)  //Notifications cell
        {
            WCNotificationsSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsSwitchCell" forIndexPath:indexPath];
            cell.notificationsSwitch.on = [[WCSettings sharedSettings] notificationsOn];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if (indexPath.row == 2) //clear saved cities
        {
            WCPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
            cell.mainLabel.text = @"Clear saved cities";
            return cell;
        }
    }
    else if (indexPath.section == 1)  //About
    {
        WCPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
        cell.mainLabel.text = @"About";
        return cell;
    }
    else if (indexPath.section == 2) //Contact us
    {
        WCPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
        cell.mainLabel.text = @"Contact Us";
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        [[WCSettings sharedSettings] clearSavedCities];
    }

    if(indexPath.section == 2 && indexPath.row == 0) { // Contact us
        
        if ([MFMailComposeViewController canSendMail])
        {
            
            if (!self.mailComposer) {
                MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                mail.mailComposeDelegate = self;
                [mail setSubject:@"Hey!"];
                [mail setMessageBody:@"I want you to put my tits up there too" isHTML:NO];
                [mail setToRecipients:@[@"acue@mac.com"]];
                self.mailComposer = mail;
            }
            
            [self presentViewController:self.mailComposer animated:YES completion:NULL];
        }
        else
        {
            UIAlertView *noEmailAlert = [[UIAlertView alloc] initWithTitle:@"Uh oh"
                                                                   message:@"You don't have mail set up"
                                                                  delegate:self
                                                         cancelButtonTitle:@"I'm gay"
                                                         otherButtonTitles:nil];
            [noEmailAlert show];
            NSLog(@"This device cannot send email");
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 0){ //About
        UIAlertView *pressedAboutButtonAlert = [[UIAlertView alloc] initWithTitle:@"FAGGOT"
                                                               message:@"Marcus molchany has no dicks"
                                                              delegate:self
                                                     cancelButtonTitle:@"I'm gay"
                                                     otherButtonTitles:nil];
        [pressedAboutButtonAlert show];

    }
    

}

#pragma mark - Mail compose delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
