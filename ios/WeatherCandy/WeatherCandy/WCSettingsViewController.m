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

@interface WCSettingsViewController () {
    WCSettings *_settings;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WCSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _settings = [WCSettings new];
}

#pragma mark - Actions

- (IBAction)pressedDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    [_settings setTempUnit:sender.selectedSegmentIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadTempLabelsNotification object:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Units";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ToggleCell" forIndexPath:indexPath];
    cell.tempToggle.selectedSegmentIndex = [_settings tempUnit];
    return cell;
}

@end
