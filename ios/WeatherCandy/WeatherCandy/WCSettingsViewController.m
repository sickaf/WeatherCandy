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
#import "WCAboutCell.h"
#import "WCContactUsCell.h"
#import "WCNotificationsSwitchCell.h"

@interface WCSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MFMailComposeViewController *mailComposer;

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
    [[WCSettings sharedSettings] setNotificationsOn:sender.isOn];
    NSLog(@"notifications are: %@", [[WCSettings sharedSettings] notificationsOn] ? @"ON" : @"OFF");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Options";
        case 1:
            return @"About Sick.AF";
        case 2:
            return @"Hit us up";
    }
    return @"SickAF"; //TODO: better handle this error
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0){
            WCToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ToggleCell" forIndexPath:indexPath];
            cell.tempToggle.selectedSegmentIndex = [[WCSettings sharedSettings] tempUnit];
            return cell;
        } else if (indexPath.row == 1) {
            WCNotificationsSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsSwitchCell" forIndexPath:indexPath];
            //cell.tempToggle.selectedSegmentIndex = [_settings tempUnit];
            return cell;

        }
    }
    else if (indexPath.section == 1)
    {
        WCAboutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell" forIndexPath:indexPath];
        return cell;
        
    }
    else if (indexPath.section == 2)
    {
        WCContactUsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactUsCell" forIndexPath:indexPath];
        return cell;
    
    }
    else if (indexPath.section == 3)
    {
        WCNotificationsSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsSwitchCell" forIndexPath:indexPath];
        return cell;

    }
    NSLog(@"error: asked for cell that we don't know of");
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2 && indexPath.row == 0) {
        
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
    else if (indexPath.section == 1 && indexPath.row == 0){
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
