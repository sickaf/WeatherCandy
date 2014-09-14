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
#import "WCCategoryCell.h"

#import "WCAddCityViewController.h"


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
    
    //Get rid of back button label for view controllers being pushed
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @""
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData]; // to reload selected cell
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


//////////////////
- (IBAction)notificationsSwitchChanged:(UISwitch *)sender
{
    //UIRemoteNotificationType *types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];

    if (sender.isOn) {//Switched on
                
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

////////////////////////////

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 3;
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
    new.font = kDefaultFontMedium(15);
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
    new.font = kDefaultFontMedium(18);
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
            result = @"Hot Girls";
            break;
        case 1:
            result = @"Cute Animals";
            break;
        default:
            result = @"Hot Girls";
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
            cell.mainLabel.font = kDefaultFontMedium(18);
            cell.mainLabel.textColor = [UIColor whiteColor];
            return cell;
        }
        else if (indexPath.row == 1)  //Notifications cell
        {
            WCNotificationsSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsSwitchCell" forIndexPath:indexPath];
            cell.notificationsSwitch.on = [[WCSettings sharedSettings] notificationsOn];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = kDefaultBackgroundColor;
            return cell;
        }
        else if (indexPath.row == 1) //category
        {
            WCCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
            cell.mainLabel.text = @"Category";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            WCImageCategory cat = [[WCSettings sharedSettings] selectedImageCategory];
            cell.categoryLabel.text = [self formatTypeToString:cat];
            
            return cell;
        }
        else if (indexPath.row == 2) //clear saved cities
        {
            WCPlainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell" forIndexPath:indexPath];
            cell.mainLabel.text = @"Clear saved cities";
            cell.mainLabel.font = kDefaultFontMedium(18);
            cell.mainLabel.textColor = [UIColor whiteColor];
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
    }
    else if(indexPath.section == 1 && indexPath.row == 1)  // Contact us
    {
        
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
