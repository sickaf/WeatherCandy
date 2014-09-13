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
#import "WCAboutViewController.h"

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


- (IBAction)notificationsSwitchChanged:(UISwitch *)sender
{
    //UIRemoteNotificationType *types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
  
    
    
    if (sender.isOn) {//Switched on
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            NSLog(@"using ios8!");

        } else {
            NSLog(@"not using ios8!");
        }

        
        //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
        
        /*
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
         */
        NSLog(@"about to tell you if the user is registered for notifications but only on iOS8");
        BOOL myBool = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
        if(myBool){
            NSLog(@"it is!");
        } else {
            NSLog(@"it is not!");
        }
        
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        
        if (types & UIRemoteNotificationTypeAlert) //user has opted OUT
        {
            NSLog(@"user already opted out of notifications");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable notifications"
                                                            message:@"Turn on notifications for Weather Candy in settings"
                                                            delegate:self
                                                            cancelButtonTitle:@"Ok"
                                                            otherButtonTitles:nil];
            [alert show];
            [sender setOn:NO animated:YES];
            [[WCSettings sharedSettings] setNotificationsOn:NO]; // TODO: I dont know if I really use this
            return;
        }
        else //User has opted IN to notifications
        {
            WCNotificationBlurViewController *vc = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"NotificationDatePicker"];
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            vc.blurImg = [self blurredImageOfCurrentViewWithAlpha:0.7 withRadius:15 withSaturation:2];
            [self presentViewController:vc animated:YES completion:nil];
        }
        
    } else {//Switched off
        [[UIApplication sharedApplication] cancelAllLocalNotifications]; // TODO: call this when app is opened
    }
    [[WCSettings sharedSettings] setNotificationsOn:sender.isOn]; // TODO: I dont know if I really use this
    NSLog(@"notifications are: %@", [[WCSettings sharedSettings] notificationsOn] ? @"ON" : @"OFF");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 4;
    }
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section) {
        case 0: title = @"Options"; break;
        case 1: title = @"sick.af"; break;
    }
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"Get in touch if you want to have your photos featured in Weather Candy";
    }
    
    return nil;
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
        else if (indexPath.row == 3) //category
        {
            WCPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
            cell.mainLabel.text = @"Category";
            return cell;
        }

    }
    else if (indexPath.section == 1)  //Sick.af section
    {
        if(indexPath.row == 0)  // About
        {
            WCPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
            cell.mainLabel.text = @"About";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        if(indexPath.row == 1)  // Contact us
        {
            WCPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
            cell.mainLabel.text = @"Contact Us";
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 2)  //Clear saved cities
    {
        [[WCSettings sharedSettings] clearSavedCities];
    }
    else if (indexPath.section == 0 && indexPath.row == 3) //category
    {
        //Get rid of back button label for the about section
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: @""
                                       style: UIBarButtonItemStyleBordered
                                       target: nil action: nil];
        [self.navigationItem setBackBarButtonItem: backButton];
        
        //grab and push view controller
        WCAboutViewController *vc = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }

    else if (indexPath.section == 1 && indexPath.row == 0) //About
    {
        
        //Get rid of back button label for the about section
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: @""
                                       style: UIBarButtonItemStyleBordered
                                       target: nil action: nil];
        [self.navigationItem setBackBarButtonItem: backButton];

        //grab and push view controller
        WCAboutViewController *vc = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"About"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.section == 1 && indexPath.row == 1)  // Contact us
    {
        
        if ([MFMailComposeViewController canSendMail])
        {
            if (!self.mailComposer)
            {
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                mailer.mailComposeDelegate = self;
                [mailer setSubject:@"Hi!"];
                NSArray *toRecipients = [NSArray arrayWithObjects:@"whatsgood@sick.af", nil];
                [mailer setToRecipients:toRecipients];
                [self presentViewController:self.mailComposer animated:YES completion:NULL];
            }
        }
        else
        {
            UIAlertView *noEmailAlert = [[UIAlertView alloc] initWithTitle:@"Uh oh"
                                                                   message:@"You don't have mail set up"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles:nil];
            [noEmailAlert show];
            NSLog(@"This device cannot send email");
        }
    }
    

}

#pragma mark - Mail compose delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
