//
//  WCSettingsViewController.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/3/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <Parse/Parse.h>
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
#import "WCCategoryCell.h"
#import "WCAddCityViewController.h"
#import "Apsalar.h"

@interface WCSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MFMailComposeViewController *mailComposer;

@end

@implementation WCSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    self.tableView.tintColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.000];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    //Get rid of back button label for view controllers being pushed
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @""
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateNotificationStatus];
    [self.tableView reloadData]; // to reload selected cell
}

- (void)appBecameActive:(NSNotification *)note
{
    [self updateNotificationStatus];
    [self.tableView reloadData];
}

- (void)updateNotificationStatus
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        UIUserNotificationType enabledTypes = currentSettings.types;
        [[WCSettings sharedSettings] setNotificationsAllowed:(enabledTypes != UIUserNotificationTypeNone)];
    }
    else
    {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        [[WCSettings sharedSettings] setNotificationsAllowed: (types != UIRemoteNotificationTypeNone)];
    }

}

#pragma mark - Actions

- (IBAction)pressedDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    [[WCSettings sharedSettings] setTempUnit:(int)sender.selectedSegmentIndex];
    
    //Analytics
    NSDictionary *analyticsDimensions = @{
                                          @"didChangeTemperatureUnit" : @"1",
                                          @"currentTemperatureUnit" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] tempUnit]],
                                          @"category" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] selectedImageCategory]],
                                          @"notificationsOn" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] notificationsOn]],
                                          };
    // Send the dimensions to Parse
    [Apsalar event:@"weatherEvent_Test" withArgs:analyticsDimensions];

    
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadTempLabelsNotification object:nil];
}


- (IBAction)notificationsSwitchChanged:(UISwitch *)sender
{
    //analytics
    NSDictionary *analyticsDimensions = nil;
    NSString *categoryString = [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] selectedImageCategory]];
    

    
    if (sender.isOn) //Switched on
    {
        if ([[WCSettings sharedSettings] notificationsAllowed]) //app has permission
        {
            [[WCSettings sharedSettings] setNotificationsOn:YES];
            WCNotificationBlurViewController *vc = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"NotificationDatePicker"];
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            vc.blurImg = [self.navigationController blurredImageOfCurrentViewWithAlpha:0.7 withRadius:15 withSaturation:2];
            [self presentViewController:vc animated:YES completion:nil];
        }
        else //no permission
        {
            //analytics
            analyticsDimensions = @{
                                     @"didTurnOn" : @"0",
                                     @"attemptedToTurnOn": @"1",
                                     @"imageCategory" : categoryString
                                                  };
            
            
            [sender setOn:NO animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notifications disabled"
                                                            message:@"Go to Settings to turn on notifications for Weather Candy"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }
    else //Switched off
    {
        //analytics
        analyticsDimensions = @{
                                @"didTurnOn" : @"0",
                                @"attemptedToTurnOn": @"0",
                                @"imageCategory" : categoryString
                                              };
        [[WCSettings sharedSettings] setNotificationsOn:NO];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    // Send the dimensions to Parse
    [Apsalar event:@"notificationEvent_Test" withArgs:analyticsDimensions];

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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section != 1) return 0;
    
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section != 1) return nil;
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    container.backgroundColor = [UIColor clearColor];
    
    UILabel *new = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width - 30, 60)];
    new.font = kDefaultFontMedium(14);
    new.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    new.textAlignment = NSTextAlignmentLeft;
    new.numberOfLines = 0;
    new.lineBreakMode = NSLineBreakByWordWrapping;
    new.text = @"Get in touch if you want to have your photos featured in Weather Candy";
    
    [container addSubview:new];
    return container;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    container.backgroundColor = [UIColor clearColor];

    UILabel *new = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.bounds.size.width - 20, 40)];
    new.font = kDefaultFontMedium(16);
    new.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    new.textAlignment = NSTextAlignmentLeft;
    new.numberOfLines = 0;
    new.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *st;
    
    if (section == 0) {
        st = @"Options";
    }
    else {
        st = @"sick.af";
    }
    new.text = st;
    
    [container addSubview:new];
    return container;
}

- (NSString *)formatTypeToString:(WCImageCategory)formatType
{
   
    NSString *result = nil;
    
    switch(formatType) {
        case 0:
            result = @"Girls";
            break;
        case 1:
            result = @"Guys";
            break;
        case 2:
            result = @"Cute Animals";
            break;
        default:
            result = @"Girls";
            break;
    }
    return result;
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
            cell.backgroundColor = kDefaultBackgroundColor;
            cell.mainLabel.font = kDefaultFontMedium(16);
            cell.mainLabel.textColor = [UIColor whiteColor];
            return cell;
        }
        else if (indexPath.row == 2)  //Notifications cell
        {
            WCNotificationsSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsSwitchCell" forIndexPath:indexPath];
            cell.label.font = kDefaultFontMedium(16);
            cell.label.textColor = [UIColor whiteColor];
            cell.backgroundColor = kDefaultBackgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            if([[WCSettings sharedSettings] notificationsAllowed] && [[WCSettings sharedSettings] notificationsOn])
            {
                [cell.notificationsSwitch setOn:YES];
            }
            else
            {
                [[WCSettings sharedSettings] setNotificationsOn:NO];
                [cell.notificationsSwitch setOn:NO];
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
            }
            return cell;
        }
        else if (indexPath.row == 1) //category
        {
            WCCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
            cell.mainLabel.text = @"Theme";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            WCImageCategory cat = [[WCSettings sharedSettings] selectedImageCategory];
            cell.categoryLabel.text = [self formatTypeToString:cat];
            
            return cell;
        }
        else if (indexPath.row == 3) //clear saved cities
        {
            WCPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
            cell.mainLabel.text = @"Clear saved cities";
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
    
    if (indexPath.section == 0 && indexPath.row == 3)  //Clear saved cities
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure you want to clear your list of saved cities?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [al show];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) //category
    {
        //grab and push view controller
      UIViewController *vc = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CategoryViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    

    else if (indexPath.section == 1 && indexPath.row == 0) //About
    {
        //grab and push view controller
        WCAboutViewController *vc = [[UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"About"];
        [self.navigationController pushViewController:vc animated:YES];
        
        [Apsalar event:@"didPressAbout_Settings"];
    }
    else if(indexPath.section == 1 && indexPath.row == 1)  // Contact us
    {
        [Apsalar event:@"didPressMail_Settings"];

        if ([MFMailComposeViewController canSendMail])
        {
            if (!self.mailComposer)
            {
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                [mailer setSubject:@"What's Good"];
                NSArray *toRecipients = [NSArray arrayWithObjects:@"whatsgood@sick.af", nil];
                [mailer setToRecipients:toRecipients];
                self.mailComposer = mailer;
            }
            [self.mailComposer setMailComposeDelegate:self];
            [self presentViewController:self.mailComposer animated:YES completion:nil];
        }
        else
        {
            UIAlertView *noEmailAlert = [[UIAlertView alloc] initWithTitle:@"Uh oh"
                                                                   message:@"You don't have mail set up"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles:nil];
            [noEmailAlert show];
        }
    }
}

#pragma mark - Mail compose delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mailComposer dismissViewControllerAnimated:YES completion:nil];
        self.mailComposer = nil;
    });
}

#pragma mark - Alert view

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[WCSettings sharedSettings] clearSavedCities];
    }
}

@end
